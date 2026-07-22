#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include "archive.h"
#include "extract.h"
#include "util.h"

ExtrairStatus extrair_projeto_de_arquivo(FILE * arquivo_fonte, const char * diretorio_alvo){
        Archive archive;
        archive.stream = arquivo_fonte;

        int64_t pos = tell64(arquivo_fonte);
        if (pos == -1) return EXTRAIR_ERRO_DE_LEITURA;

        archive.offset_base = (uint64_t) pos;
        
        ExtrairStatus status = extrair_header_projeto(&archive.header, &archive);
        if (status != EXTRAIR_OK) return status;

        // extrai headers de arquivo
        HeaderArquivo * headers = malloc(archive.header.quantidade_arquivos * sizeof(HeaderArquivo));
        if (!headers) return EXTRAIR_ERRO_DE_MEMORIA;

        status = extrair_headers(headers, &archive);
        if (status == EXTRAIR_OK) status = extrair_arquivos(diretorio_alvo, headers, &archive);

        for(int i = 0; i < archive.header.quantidade_arquivos; i++)
                free(headers[i].caminho);
        free(headers);
        return status;
}

ExtrairStatus extrair_projeto(const char * arquivo_a_extrair, const char * diretorio_alvo){
        Archive archive;

        archive.stream = fopen(arquivo_a_extrair, "rb");

        if (!archive.stream) return EXTRAIR_ARQUIVO_NAO_ENCONTRADO;

        archive.offset_base = 0; // inicio do arquivo

        ExtrairStatus status = extrair_header_projeto(&archive.header, &archive);
        if (status != EXTRAIR_OK) {
                fclose(archive.stream); return status;
        };

        // extrai headers de arquivo
        HeaderArquivo * headers = malloc(archive.header.quantidade_arquivos * sizeof(HeaderArquivo));
        if (!headers) {
                fclose(archive.stream); return EXTRAIR_ERRO_DE_MEMORIA;
        }

        status = extrair_headers(headers, &archive);

        if (status == EXTRAIR_OK) status = extrair_arquivos(diretorio_alvo, headers, &archive);

        free(headers);
        fclose(archive.stream);
        return status;
}

ExtrairStatus extrair_header_projeto(HeaderProjeto * out, Archive * archive){
        if(!fread(out, sizeof(HeaderProjeto), 1, archive->stream)) return EXTRAIR_ERRO_DE_LEITURA;

        if(out->numero_magico != NUMERO_MAGICO) return EXTRAIR_ARQUIVO_INVALIDO_OU_CORROMPIDO;

        return EXTRAIR_OK;
}

ExtrairStatus extrair_headers(HeaderArquivo headers[], Archive * archive){
        ExtrairStatus retorno = EXTRAIR_OK;

        uint32_t extraidos = 0;
        for (uint32_t i = 0; i < archive->header.quantidade_arquivos; i++){
                if (!fread(&headers[i], sizeof(HeaderArquivo)-sizeof(headers->caminho), 1, archive->stream)){
                        retorno = EXTRAIR_ERRO_DE_LEITURA;
                        goto erro;
                }

                if (headers[i].offset + headers[i].tamanho_comprimido < headers[i].tamanho_comprimido) {
                        retorno = EXTRAIR_ARQUIVO_INVALIDO_OU_CORROMPIDO;
                        goto erro;
                } // se offset + tamanho_comprimido dah overflow, considerando que sao uint64_t, o razoavel foi extrapolado. Algo foi corrompido ou o arquivo eh invalido.

                char * caminho = malloc(headers[i].caminho_tamanho * sizeof(char) + 1);
                if (!caminho) {
                        retorno = EXTRAIR_ERRO_DE_MEMORIA;
                        goto erro;
                }
                if (fread(caminho, sizeof(char), headers[i].caminho_tamanho, archive->stream) < headers[i].caminho_tamanho){
                        retorno = EXTRAIR_ERRO_DE_LEITURA;
                        free(caminho);
                        goto erro;
                }
                caminho[headers[i].caminho_tamanho] = '\0'; // null-termina
                headers[i].caminho = caminho;

                extraidos++;
        }

        // agora checar o CRC
        if (archive->header.checksum != checksum_headers(headers, archive->header.quantidade_arquivos)){
                retorno = EXTRAIR_ARQUIVO_INVALIDO_OU_CORROMPIDO;
                goto erro;
        }
        
        return EXTRAIR_OK;

        erro:
        for (uint32_t i = 0; i < extraidos; i++){
                free(headers[i].caminho);
        }
        return retorno;
}

ExtrairStatus extrair_arquivos(const char * diretorio_alvo, const HeaderArquivo * headers, Archive * archive){
        for (uint32_t i = 0; i < archive->header.quantidade_arquivos; i++){
                ExtrairStatus status = extrair_arquivo(diretorio_alvo, &headers[i], archive);
                if (status != EXTRAIR_OK) return status;
        }
        return EXTRAIR_OK;
}

ExtrairStatus extrair_arquivo(const char * diretorio_alvo, const HeaderArquivo * header, Archive * archive){

        const char * caminho_relativo = header->caminho;
        if (eh_caminho_absoluto(caminho_relativo)) return EXTRAIR_CAMINHO_INVALIDO;
        // checar para ver se o arquivo "escapa" do diretorio base?

        char buffer[TAMANHO_MAX_CAMINHO_ARQUIVO];

        // pega o caminho onde devemos colocar o arquivo
        if (snprintf(buffer, sizeof(buffer), "%s/%s", diretorio_alvo, header->caminho) >= sizeof(buffer)) return EXTRAIR_DIRETORIO_ALVO_MUITO_LONGO;

        if (seek64(archive->stream, archive->offset_base + header->offset, SEEK_SET) < 0) return EXTRAIR_ERRO_DE_LEITURA; // offset onde devemos encontrar o arquivo

        FILE * arquivo = criar_arquivo(buffer, "wb"); // abre o arquivo para descompressao
        if (!arquivo) return EXTRAIR_ERRO_DE_ESCRITA;

        // pega todos os dados comprimidos do arquivo
        Dados dados_comprimidos;
        dados_comprimidos.tamanho = header->tamanho_comprimido;
        dados_comprimidos.bytes = malloc(dados_comprimidos.tamanho);
        if (!dados_comprimidos.bytes) {
                fclose(arquivo);
                remove(buffer);
                return EXTRAIR_ERRO_DE_MEMORIA;
        }
        int l;
        if (l = fread(dados_comprimidos.bytes, sizeof(uint8_t), dados_comprimidos.tamanho, archive->stream) < header->tamanho_comprimido) {
                free(dados_comprimidos.bytes);
                fclose(arquivo);
                remove(buffer);
                return EXTRAIR_ERRO_DE_LEITURA;
        }

        Dados dados_originais;
        dados_originais.tamanho = header->tamanho_original;

        if(dados_originais.tamanho == 0){
                free(dados_comprimidos.bytes);
                fclose(arquivo);
                return EXTRAIR_OK; // vazio
        }
        dados_originais.bytes = malloc(header->tamanho_original);

        if (!dados_originais.bytes) {
                free(dados_comprimidos.bytes);
                fclose(arquivo);
                remove(buffer);
                return EXTRAIR_ERRO_DE_MEMORIA;
        }

        ExtrairStatus status = extrair_dados(&dados_comprimidos, &dados_originais, header->tamanho_original);

        if(status != EXTRAIR_OK) goto cleanup;

        uLong checksum = crc_dados(dados_originais);
        if (checksum != header->checksum) {
                status = EXTRAIR_CHECKSUM_INVALIDA;
                goto cleanup;
        }

        size_t escritos = fwrite(dados_originais.bytes, sizeof(uint8_t), dados_originais.tamanho, arquivo);
         
        if (escritos < dados_originais.tamanho){
                status = EXTRAIR_ERRO_DE_ESCRITA;
                goto cleanup;
        }
        status = EXTRAIR_OK;

        cleanup:
                free(dados_comprimidos.bytes);
                free(dados_originais.bytes);
                fclose(arquivo);

                if (status != EXTRAIR_OK) remove(buffer);
                return status;
}

ExtrairStatus extrair_dados(const Dados * in, Dados * out, uint64_t tamanho_original){

        uLongf len = (uLongf) tamanho_original;

        int status = uncompress(out->bytes, &len, in->bytes, in->tamanho);

        if (len < tamanho_original) return EXTRAIR_ARQUIVO_INVALIDO_OU_CORROMPIDO;

        switch (status)
        {
        case Z_OK:
                return EXTRAIR_OK;
        case Z_MEM_ERROR :
                return EXTRAIR_ERRO_DE_MEMORIA;
        default:
                return EXTRAIR_ARQUIVO_INVALIDO_OU_CORROMPIDO;
        }
}

const char * strerr_extrair(ExtrairStatus numeroerro){
    static char erro[10][38] = {
        "extracao concluida com sucesso", "arquivo corrompido", "arquivo nao encontrado", "arquivo invalido ou corrompido", "versao nao suportada", "erro ao ler arquivo", "erro ao escrever arquivos", "caminho ao diretorio alvo muito longo",
        "erro ao alocar memoria", "caminho de extracao invalido"
    };

    return erro[numeroerro];
}