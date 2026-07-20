#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include "archive.h"
#include "extract.h"

ExtrairStatus extrair_projeto(const char * arquivo_a_extrair, const char * diretorio_alvo){
        FILE * archive = fopen(arquivo_a_extrair, "rb");
        if (!archive) return EXTRAIR_ARQUIVO_NAO_ENCONTRADO;

        // extrai header de projeto
        HeaderProjeto projeto;

        ExtrairStatus status = extrair_header_projeto(&projeto, archive);
        if (status != EXTRAIR_OK) {
                fclose(archive); return status;
        };

        // extrai headers de arquivo
        HeaderArquivo * headers = malloc(projeto.quantidade_arquivos * sizeof(HeaderArquivo));
        if (!headers) {
                fclose(archive); return EXTRAIR_ERRO_DE_MEMORIA;
        }
        status = extrair_headers(headers, &projeto, archive);

        if (status == EXTRAIR_OK) status = extrair_arquivos(diretorio_alvo, &projeto, headers, archive);

        free(headers);
        fclose(archive);
        return status;
}

ExtrairStatus extrair_header_projeto(HeaderProjeto * out, FILE * archive){
        if(!fread(out, sizeof(HeaderProjeto), 1, archive)) return EXTRAIR_ERRO_DE_LEITURA;

        if(out->numero_magico != NUMERO_MAGICO) return EXTRAIR_ARQUIVO_INVALIDO_OU_CORROMPIDO;
        if(out->versao < VERSAO)

        return EXTRAIR_OK;
}

ExtrairStatus extrair_headers(HeaderArquivo headers[], const HeaderProjeto * headerProjeto, FILE * archive){
        // "mas nao seria melhor trocar por um so fread?"
        // no futuro proximo, o formato de header vai ter footprint de memoria variavel.
        // em vez de um buffer gigante para o nome do arquivo, vai ser guardado, junto com ele, 
        // a string de nome de arquivo, somente com o tamanho necessario. entao o loop ta em 
        // lugar jah pra facilitar o refactoring depois.
        for (uint32_t i = 0; i < headerProjeto->quantidade_arquivos; i++){
                if (!fread(&headers[i], sizeof(HeaderArquivo), 1, archive)) return EXTRAIR_ERRO_DE_LEITURA;

                if (headers[i].offset + headers[i].tamanho_comprimido < headers[i].tamanho_comprimido) return EXTRAIR_ARQUIVO_INVALIDO_OU_CORROMPIDO; // se offset + tamanho_comprimido dah overflow, considerando que sao uint64_t, o razoavel foi extrapolado. Algo foi corrompido ou o arquivo eh invalido.
        }

        // agora checar o CRC
        if (headerProjeto->checksum != crc_bytes(headers, headerProjeto->quantidade_arquivos * sizeof(HeaderArquivo)))
                return EXTRAIR_ARQUIVO_INVALIDO_OU_CORROMPIDO;

        return EXTRAIR_OK;
}

ExtrairStatus extrair_arquivos(const char * diretorio_alvo, const HeaderProjeto * headerProjeto, const HeaderArquivo * headers, FILE * archive){
        for (uint32_t i = 0; i < headerProjeto->quantidade_arquivos; i++){
                ExtrairStatus status = extrair_arquivo(diretorio_alvo, &headers[i], archive);
                if (status != EXTRAIR_OK) return status;
        }
        return EXTRAIR_OK;
}

ExtrairStatus extrair_arquivo(const char * diretorio_alvo, const HeaderArquivo * header, FILE * archive){

        const char * caminho_relativo = header->caminho;
        if (eh_caminho_absoluto(caminho_relativo)) return EXTRAIR_CAMINHO_INVALIDO;
        // checar para ver se o arquivo "escapa" do diretorio base?

        char buffer[TAMANHO_MAX_CAMINHO_ARQUIVO];

        // pega o caminho onde devemos colocar o arquivo
        if (snprintf(buffer, sizeof(buffer), "%s/%s", diretorio_alvo, header->caminho) >= sizeof(buffer)) return EXTRAIR_DIRETORIO_ALVO_MUITO_LONGO;

        if (fseek(archive, header->offset, SEEK_SET) < 0) return EXTRAIR_ERRO_DE_LEITURA; // offset onde devemos encontrar o arquivo

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
        if (fread(dados_comprimidos.bytes, sizeof(uint8_t), dados_comprimidos.tamanho, archive) < header->tamanho_comprimido) {
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