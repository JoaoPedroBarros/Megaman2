// Fernando de Almeida

#include <stdlib.h>
#include <stdio.h>
#include <zlib.h>
#include <string.h>
#include <windows.h> 
#include <stdbool.h>
#include "archive.h"

// ARCHIVE: Arquiva todos os arquivos em argv[1]/assets e argv[1]/src, junto com argv[1]/readme, em um unico arquivo de .archive
int main(int argc, char ** argv){

        if (argc != 3) {
                printf("Uso: %s diretorio_raiz_do_projeto nome_arquivo_output\n\n", argv[0]);
                printf("Exemplo1: %s C:\\Projetos\\Projeto1 out.archive\n", argv[0]);
                printf("Exemplo2: %s ..\\..\\ proj\n", argv[0]);
                printf("Exemplo3: %s . out\n", argv[0]);
                printf("Exemplo4: %s .\\jogo jogo.archive\n", argv[0]);

                return 0;
        }

        char * diretorio_raiz = argv[1];

        uint64_t qtd_bytes_bruto = 0;
        uint64_t qtd_bytes_comprimido = 0;

        VetorArquivos arquivos = get_arquivos_fonte(diretorio_raiz);
        if (!arquivos.quantidade) return EXIT_FAILURE;
        HeaderJogo header;
        header.numero_magico = NUMERO_MAGICO;
        header.versao = VERSAO;

        HeaderArquivo headers_de_arquivo[arquivos.quantidade];

        Dados dadoscomprimidos[arquivos.quantidade];
        Dados raw_bytes;

        for(size_t i = 0; i < arquivos.quantidade; i++){
                raw_bytes = ler_arquivo_projeto(diretorio_raiz, arquivos.caminhos[i]);
                if (!raw_bytes.bytes) goto error;
                qtd_bytes_bruto += raw_bytes.tamanho;

                dadoscomprimidos[i] = comprimir(raw_bytes);
                if (!dadoscomprimidos[i].bytes) {
                        free(raw_bytes.bytes);
                        goto error;
                } 
                qtd_bytes_comprimido += dadoscomprimidos[i].tamanho;

                strncpy(headers_de_arquivo[i].caminho, arquivos.caminhos[i], sizeof(headers_de_arquivo[i].caminho));
                headers_de_arquivo[i].tamanho_original = raw_bytes.tamanho;
                headers_de_arquivo[i].tamanho_comprimido = dadoscomprimidos[i].tamanho;
                headers_de_arquivo[i].checksum = crc_bytes(raw_bytes.bytes, raw_bytes.tamanho);

                free(raw_bytes.bytes);
        }

        header.quantidade_arquivos = arquivos.quantidade;
        calcular_offsets(header, headers_de_arquivo);

        header.checksum = crc_bytes(headers_de_arquivo, arquivos.quantidade * sizeof(HeaderArquivo));
        if (!arquivar(argv[2], header, headers_de_arquivo, dadoscomprimidos)) goto error;

        printf("Pronto! Arquivei %d arquivo(s) em %s.\n", header.quantidade_arquivos, argv[2]);
        printf("Tamanho bruto: %llu.\nTamanho comprimido: %llu.\nTaxa de compressao: %.2lf%%.",
                qtd_bytes_bruto,
                qtd_bytes_comprimido,
                (1.0 - (double)qtd_bytes_comprimido/(double)qtd_bytes_bruto)*100
        );

        for(size_t i = 0; i < header.quantidade_arquivos; i++) free(dadoscomprimidos[i].bytes);
        liberar_vetor_arquivos(&arquivos);

        return EXIT_SUCCESS;

        error: 
        for(size_t i = 0; i < header.quantidade_arquivos; i++) free(dadoscomprimidos[i].bytes);
        liberar_vetor_arquivos(&arquivos);
        exit(EXIT_FAILURE);
}

bool get_arquivos(VetorArquivos * dest, const char * diretorio_real, const char * diretorio_relativo){
        WIN32_FIND_DATA fdFile;
        HANDLE hFind = NULL;

        char real[TAMANHO_MAX_CAMINHO_ARQUIVO];
        char relativo[TAMANHO_MAX_CAMINHO_ARQUIVO];
        snprintf(real, sizeof(real), "%s\\*.*", diretorio_real); // pega absolutamente tudo
        strncpy(relativo, diretorio_real, sizeof(relativo));

        if((hFind = FindFirstFile(real, &fdFile)) == INVALID_HANDLE_VALUE) return false;

        // procura pelos proximos arquivos
        do{

                if (strcmp(fdFile.cFileName, ".") == 0 ||
                   strcmp(fdFile.cFileName, "..") == 0) continue; // pula "." e "..", que nao sao arquivos!

                // caminho do arquivo atual
                snprintf(real, sizeof(real), "%s\\%s", diretorio_real, fdFile.cFileName);
                snprintf(relativo, sizeof(relativo), "%s\\%s", diretorio_relativo, fdFile.cFileName);

                // verifica se encontramos um diretorio ou arquivo
                if(fdFile.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
                {
                        VetorArquivos subdiretorio = {0};
                        if(get_arquivos(&subdiretorio, real, relativo))
                                adicionar_arquivos(dest, subdiretorio); // recursivamente acrescenta tudo nos diretorios
                        liberar_vetor_arquivos(&subdiretorio);
                }
                else{
                        adicionar_arquivo(dest, relativo);
                }
        }while(FindNextFile(hFind, &fdFile));

        FindClose(hFind);
        return true;
}

void liberar_vetor_arquivos(VetorArquivos * v){
        for (size_t i = 0; i < v->quantidade; i++)
                free(v->caminhos[i]);
        free(v->caminhos);
        v->caminhos = NULL;
        v->quantidade = 0;
        v->capacidade = 0;
}

bool adicionar_arquivos(VetorArquivos * dest, const VetorArquivos src){
        bool sucesso = true;
        for (size_t i = 0; i < src.quantidade; i++)
                sucesso &= adicionar_arquivo(dest, src.caminhos[i]);
        return sucesso;
}

bool adicionar_arquivo(VetorArquivos * v, const char * src){
        if (v->quantidade == v->capacidade){
                size_t nova_capacidade =
                v->capacidade == 0 ? 8 : v->capacidade * 2;

                char ** novo = realloc(
                        v->caminhos,
                        nova_capacidade * sizeof(char *)
                );
                if (!novo) {
                        fprintf(stderr, "ERRO: Falha ao aumentar capacidade de vetor de arquivos de %u para %u: Realocacao de memoria falhou.\n", v->capacidade, nova_capacidade);
                        return false;
                }
                v->caminhos = novo;
                v->capacidade = nova_capacidade;
        }

        // copia o caminho de src pro vetor
        size_t tamanho_src = strlen(src);
        char * copia = malloc(tamanho_src + 1);
        if (!copia) {
                fprintf(stderr, "ERRO: Falha ao alocar memoria ao copiar string de tamanho %u: %s.\n", tamanho_src, strerror(errno));
                return false;
        }
        strcpy(copia, src);
        v->caminhos[v->quantidade++] = copia;
        return true;
}

VetorArquivos get_arquivos_fonte(const char * diretorio_raiz){
        VetorArquivos arquivos_src = {0}, arquivos_assets = {0}, ret = {0};

        char path[TAMANHO_MAX_CAMINHO_ARQUIVO];

        snprintf(path, sizeof(path), "%s\\src", diretorio_raiz);
        if (!get_arquivos(&arquivos_src, path, "src")) goto get_arquivos_fonte_falha;

        snprintf(path, sizeof(path), "%s\\assets", diretorio_raiz);
        if (!get_arquivos(&arquivos_assets, path, "assets")) goto get_arquivos_fonte_falha;

        adicionar_arquivos(&ret, arquivos_src);
        adicionar_arquivos(&ret, arquivos_assets);
        liberar_vetor_arquivos(&arquivos_src);
        liberar_vetor_arquivos(&arquivos_assets);

        if (!adicionar_arquivo(&ret, "README.md")) goto get_arquivos_fonte_falha;

        return ret;

        get_arquivos_fonte_falha:
                fprintf(stderr, "ERRO: Falha ao adicionar arquivo/diretorio %s.\n", path);
                return (VetorArquivos){0,0,NULL};
}

Dados ler_arquivo_projeto(const char * diretorio_raiz, const char * caminho_relativo){
    char caminho[TAMANHO_MAX_CAMINHO_ARQUIVO];

    snprintf(
        caminho,
        sizeof(caminho),
        "%s\\%s",
        diretorio_raiz,
        caminho_relativo
    );

    return ler_arquivo(caminho);
}

Dados ler_arquivo(const char * caminho){
        Dados retorno = {0};
        
        FILE * arquivo = fopen(caminho, "rb");
        if (!arquivo){
                fprintf(stderr, "ERRO: Falha ao abrir o arquivo %s: %s.\n", caminho, strerror(errno));
                goto ler_arquivo_ret;
        }

        int seekstatus = fseek(arquivo, 0, SEEK_END);
        if (seekstatus != 0) {
                fprintf(stderr, "ERRO: Erro no posicionamento do cursor durante leitura do arquivo %s: %s\n", caminho, strerror(errno));
                goto ler_arquivo_ret;
        }

        long tamanho_arquivo_long = ftell(arquivo);
        if (tamanho_arquivo_long < 0){
                fprintf(stderr, "ERRO: Falha ao obter tamanho do arquivo %s: %s", caminho, strerror(errno));
                goto ler_arquivo_ret;
        }
        size_t tamanho_arquivo = (size_t) tamanho_arquivo_long;


        rewind(arquivo); // volta ao comeco do arquivo para leitura

        retorno.bytes = malloc(tamanho_arquivo * sizeof(uint8_t)); 
        if (!retorno.bytes) {
                fprintf(stderr, "ERRO: Erro na alocacao do array de bytes durante a leitura do arquivo %s.\n", caminho);
                goto ler_arquivo_ret;
        }
        retorno.tamanho = tamanho_arquivo;
        size_t bytes_lidos = fread(retorno.bytes, sizeof(uint8_t), tamanho_arquivo, arquivo); // le todos os bytes
        if (bytes_lidos != tamanho_arquivo) {
                if (ferror(arquivo)){
                        fprintf(stderr, "ERRO: Falha ao ler o arquivo %s: %s\n", caminho, strerror(errno));
                        goto ler_arquivo_ret;
                }
                if (feof(arquivo)){
                        fprintf(stderr, "ERRO: O arquivo %s terminou antes do esperado.\n", caminho);
                        goto ler_arquivo_ret;
                }
        }

        fclose(arquivo);
        return retorno;
        ler_arquivo_ret:
                if(arquivo)fclose(arquivo);
                free(retorno.bytes);
                return retorno;
}

void calcular_offsets(const HeaderJogo headerjogo, HeaderArquivo * headerarquivo){
        uint64_t offset_atual = sizeof(HeaderJogo) + (headerjogo.quantidade_arquivos * sizeof(HeaderArquivo));

        for (size_t i = 0; i < headerjogo.quantidade_arquivos; i++){
                headerarquivo[i].offset = offset_atual;
                offset_atual += headerarquivo[i].tamanho_comprimido;
        }
}

Dados comprimir(const Dados original){
        if (original.tamanho > ULONG_MAX) {
                fprintf(stderr, "ERRO: Arquivo muito grande para compress2().\n");
                return (Dados){0};
        }

        Dados retorno;
        retorno.tamanho = compressBound(original.tamanho);
        retorno.bytes = malloc(retorno.tamanho * sizeof(uint8_t));

        if (!retorno.bytes) {
                fprintf(stderr, "ERRO: Erro ao comprimir dados: Alocacao de buffer de %llu bytes falhou.\n", retorno.tamanho);
                return (Dados){0, 0};
        }
        uLongf tamanhobuff = retorno.tamanho;

        int status = compress2(
                retorno.bytes,
                &tamanhobuff,
                original.bytes,
                (uLong)original.tamanho,
                Z_BEST_COMPRESSION
        );

        switch (status){
        case Z_OK:
                retorno.tamanho = tamanhobuff;
                return retorno;
        case Z_MEM_ERROR:
                fprintf(stderr, "ERRO: Falha ao alocar bytes durante compressao de buffer de tamanho %llu.\n", original.tamanho);
                free(retorno.bytes);
                return (Dados){0, 0};
        default:
                fprintf(stderr, "ERRO: Compressao de buffer de %llu bytes retornou status %d. Esperado: %d.\n", original.tamanho, status, Z_OK);
                free(retorno.bytes);
                return (Dados){0, 0};
        }
}

uLong crc_bytes(void * dados, size_t tamanho){
        uLong crcInicial = crc32(0L, Z_NULL, 0);
        return crc32(crcInicial, (Bytef *) dados, tamanho);
}

bool arquivar(const char * caminho_out, const HeaderJogo headerjogo, const HeaderArquivo headers_de_arquivo[], const Dados dadoscomprimidos[]){
        FILE * out = fopen(caminho_out, "wb");
        if (!out) {
                fprintf(stderr, "ERRO: Falha ao criar arquivo .archive: %s\n", strerror(errno));
                goto arquivar_falha;
        }

        if (!fwrite(&headerjogo, sizeof(headerjogo), 1, out)) goto arquivar_erro;
        if (!fwrite(headers_de_arquivo, sizeof(HeaderArquivo), headerjogo.quantidade_arquivos,  out)) goto arquivar_erro;
        for(size_t i = 0; i < headerjogo.quantidade_arquivos; i++){
                if (!fwrite(dadoscomprimidos[i].bytes, sizeof(uint8_t), dadoscomprimidos[i].tamanho, out)) goto arquivar_erro;
        }

        fclose(out);
        return true;

        arquivar_erro:  
                fprintf(stderr, "ERRO: Falha ao escrever no arquivo .archive: %s", strerror(errno));
        arquivar_falha:
                fclose(out);
                return false;
}

