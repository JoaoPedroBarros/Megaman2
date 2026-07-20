// Fernando de Almeida

#include <stdlib.h>
#include <stdio.h>
#include <zlib.h>
#include <string.h>
#include <windows.h> 
#include <stdbool.h>
#include <ctype.h>
#include "archive.h"
#include "util.h"

// ARCHIVE: Arquiva todos os arquivos em argv[1]/assets e argv[1]/src, junto com argv[1]/readme, em um unico arquivo de .archive
int main(int argc, char ** argv){

        if (argc != 3) {
                printf("Uso: %s arquivo_manifest nome_arquivo_output\n\n", argv[0]);
                printf("Exemplo: %s archive.manifest out.archive\n", argv[0]);
                printf("Veja MANIFEST_FORMAT.md para informacoes sobre o formato do manifesto.\n");
                return EXIT_SUCCESS;
        }

        // contadores de bytes
        uint64_t qtd_bytes_bruto = 0;
        uint64_t qtd_bytes_comprimido = 0;

        // Manifesto fornecido
        char * manifesto_path = argv[1];
        Manifesto * manifesto = carregar_manifesto(manifesto_path);
        if (!manifesto) return EXIT_FAILURE;

        // header do projeto
        HeaderProjeto header;
        header.numero_magico = NUMERO_MAGICO;
        header.versao = VERSAO;
        header.quantidade_arquivos = 0;

        printf("Coletando arquivos...\n");

        // vetor com todos os arquivos fornecidos pelo manifesto!
        Vetor arquivos;
        if(!vetor_init(&arquivos, 8, sizeof(char*)) ||   // inicia o vetor de arquivos
        !coletar_arquivos(&arquivos, manifesto)){        // coloca todos os arquivos que foram incluidos e nao foram excluidos!
                liberar_vetor_de_strings(&arquivos);
                liberar_vetor_de_strings(&manifesto->includes);
                liberar_vetor_de_strings(&manifesto->excludes);
                free(manifesto->root);
                free(manifesto->path);
                free(manifesto);
                return EXIT_FAILURE;
        }

        size_t arquivos_quantidade = vetor_tamanho(&arquivos);
        if (!arquivos_quantidade) {
                arquivos_quantidade = 1; // necessario para a inicializacao dos Variable Length Arrays
                printf("Nao encontrei nenhum arquivo que satisfaca as regras. Certifique-se que pelo menos um arquivo foi incluso e que exista pelo menos um arquivo que nao foi excluido pelo comando exclude.\n");
        } else printf("%d arquivo(s) coletado(s).\n", arquivos_quantidade);

        HeaderArquivo headers_de_arquivo[arquivos_quantidade];

        Dados dadoscomprimidos[arquivos_quantidade];
        Dados raw_bytes;

        int valor_retorno = EXIT_FAILURE; // valor que vamos retornar no final da main. por padrao, houve falha. isso simplifica o trabalho de labels

        if (vetor_vazio(&arquivos)) goto cleanup; // nenhum arquivo encontrado: houve um erro

        
        printf("Comprimindo...");

        static size_t last_len_printf = 0; // ultima quantidade de caracteres impressos

        for(size_t i = 0; i < arquivos_quantidade; i++){

                const char * caminho = vetor_get_as(&arquivos, i, const char *); // caminho do arquivo i

                // imprime sem passar de linha, limpando o espaco anteriormente ocupado
                size_t len = printf("\r\033[KComprimindo arquivo %u de %u: %s",
                        i + 1,
                        arquivos_quantidade,
                        caminho);
                while ((size_t)len < last_len_printf) {
                        putchar(' ');
                        len++;
                }
                last_len_printf = len;
                fflush(stdout);
                 
                // pega toda a informacao do arquivo
                raw_bytes = ler_arquivo_projeto(manifesto->root, caminho);
                if (!raw_bytes.bytes) goto cleanup;
                qtd_bytes_bruto += raw_bytes.tamanho;

                // comprime toda a informacao
                dadoscomprimidos[i] = comprimir(raw_bytes);
                if (!dadoscomprimidos[i].bytes) {
                        free(raw_bytes.bytes);
                        goto cleanup;
                } 
                qtd_bytes_comprimido += dadoscomprimidos[i].tamanho;

                // cria o header de arquivo
                strncpy(headers_de_arquivo[i].caminho, caminho, sizeof(headers_de_arquivo[i].caminho));
                headers_de_arquivo[i].caminho[sizeof(headers_de_arquivo[i].caminho) - 1] = '\0'; // null-termination
                headers_de_arquivo[i].tamanho_original = raw_bytes.tamanho;
                headers_de_arquivo[i].tamanho_comprimido = dadoscomprimidos[i].tamanho;
                headers_de_arquivo[i].checksum = crc_bytes(raw_bytes.bytes, raw_bytes.tamanho);

                header.quantidade_arquivos++;

                free(raw_bytes.bytes);
        }

        header.quantidade_arquivos = arquivos.quantidade;
        calcular_offsets(header, headers_de_arquivo);

        header.checksum = crc_bytes(headers_de_arquivo, arquivos.quantidade * sizeof(HeaderArquivo));
        if (!arquivar(argv[2], header, headers_de_arquivo, dadoscomprimidos)) goto cleanup;

        int len = printf("\rPronto! Arquivei %d arquivo(s) em %s.", header.quantidade_arquivos, argv[2]);
        while ((size_t)len < last_len_printf) {
                putchar(' ');
                len++;
        } last_len_printf = len;

        printf("\nTamanho bruto: %llu.\nTamanho comprimido: %llu.\nTaxa de compressao: %.2lf%%.",
                qtd_bytes_bruto,
                qtd_bytes_comprimido,
                (1.0 - (double)qtd_bytes_comprimido/(double)qtd_bytes_bruto)*100
        );

        valor_retorno = EXIT_SUCCESS;

        cleanup: 
        for(size_t i = 0; i < header.quantidade_arquivos; i++) free(dadoscomprimidos[i].bytes);
        liberar_vetor_de_strings(&arquivos);
        destruir_manifesto(manifesto);
        return valor_retorno;
}

Manifesto * carregar_manifesto(const char * path){
        FILE * fmanifesto = fopen(path, "r");
        if (!fmanifesto) {
                fprintf(stderr, "ERRO: Falha ao abrir o manifesto %s: %s\n", path, strerror(errno));
                return NULL;
        }

        Manifesto * manifesto = calloc(1, sizeof(Manifesto));
        if (!manifesto) goto erro_mem;
        manifesto->path = strdup(path);
        if (!manifesto->path) 
                goto erro_mem;
        

        manifesto->root = NULL;
        Vetor args = (Vetor){0, 0, 0, 0};

        if (!vetor_init(&manifesto->includes, 8, sizeof(char*)) 
         || !vetor_init(&manifesto->excludes, 8, sizeof(char*))) goto erro_mem;

        if (!vetor_init(&args, 4, sizeof(StringView))) goto erro_mem;
                
        char buffer[2048];

        size_t linha;
        for(linha = 1;fgets(buffer, sizeof(buffer), fmanifesto);linha++){
                vetor_clear(&args);
                if (parse_linha(buffer, &args)){
                        if (vetor_vazio(&args))continue;// faz nada se nao tiver comando na linha

                        int status = processar_comando(&args, manifesto);
                        if (status != COMANDO_OK){
                                fprintf(stderr, "ERRO: Erro na linha %u: %s", linha, strerr_comando(status));
                                destruir_manifesto( manifesto);
                                vetor_free(&args);
                                fclose(fmanifesto);
                                return NULL;
                        }
                } 
        }
        fclose(fmanifesto);
        vetor_free(&args);
        return manifesto;

        erro_mem:
                fprintf(stderr, "ERRO: Falha ao alocar espaco para o manifesto.\n");
                fclose(fmanifesto);
                destruir_manifesto(manifesto);
                return NULL;
}

void destruir_manifesto(Manifesto * manifesto){
        liberar_vetor_de_strings(&manifesto->includes);
        liberar_vetor_de_strings(&manifesto->excludes);
        free(manifesto->root);
        free(manifesto->path);
        free(manifesto);
}

ComandoStatus processar_comando(const Vetor * linha, Manifesto * manifesto){
        StringView comando = vetor_get_as(linha, 0, StringView);

        if (string_view_equals_cstr_ignore_case(comando, "from")){
                if (vetor_tamanho(linha) != 2) 
                        return COMANDO_MALFORMADO;
                
                if (manifesto->root)  // duplicado!!!!!!!!!!!!!! Nao pode!!!!!
                        return COMANDO_DUPLICADO;
                
                char * arg = criar_copia_stringview(vetor_get_as(linha, 1, StringView)); // root dado
                if(!arg) return COMANDO_ERRO_DE_MEMORIA;

                if (!eh_caminho_absoluto(arg)) {
                        char buffer[TAMANHO_MAX_CAMINHO_ARQUIVO];

                        obter_diretorio_de_arquivo(buffer, sizeof(buffer), manifesto->path);

                        if(!juntar_caminhos(buffer, sizeof(buffer), buffer, arg)){ // transforma o caminho fornecido em um caminho relativo ao working directory em vez de relativo ao manifesto

                                free(arg);
                                return COMANDO_CAMINHO_LONGO_DEMAIS;    
                        } 

                        free(arg);
                                    
                        if(!caminho_absoluto(buffer, buffer, sizeof(buffer))){ // agora transforma em caminho absoluto
                                return COMANDO_CAMINHO_LONGO_DEMAIS; // se o caminho absoluto exceder o maximo, retorna que eh longo demais...      
                        }; 

                        // coloca o novo caminho
                        arg = strdup(buffer);
                        if (!arg) return COMANDO_ERRO_DE_MEMORIA;
                }

                manifesto->root = arg;
                return COMANDO_OK;
        }
        if (string_view_equals_cstr_ignore_case(comando, "include")){
                if (!manifesto->root) return COMANDO_SEM_ROOT;
                StringView * views = vetor_dados(linha);

                char * arg;
                for (int i = 1; i < linha->quantidade; i++){
                        arg = criar_copia_stringview(views[i]);
                        ComandoStatus status = incluir_caminho(manifesto, &manifesto->includes, arg);
                        free(arg);
                        if (status != COMANDO_OK) return status;
                }
                return COMANDO_OK;
        }
        if (string_view_equals_cstr_ignore_case(comando, "exclude")){
                if (!manifesto->root) return COMANDO_SEM_ROOT;
                StringView * views = vetor_dados(linha);

                char * arg;
                for (int i = 1; i < linha->quantidade; i++){
                        arg = criar_copia_stringview(views[i]);
                        ComandoStatus status = incluir_caminho(manifesto, &manifesto->excludes, arg);
                        free(arg);
                        if (status != COMANDO_OK) return status;
                }
                return COMANDO_OK;
        }
        return COMANDO_DESCONHECIDO;
}

ComandoStatus incluir_caminho(Manifesto * manifesto, Vetor * vetor, const char * caminho){
        char real[TAMANHO_MAX_CAMINHO_ARQUIVO];
        if(!juntar_caminhos(real, sizeof(real), manifesto->root, caminho)) return COMANDO_CAMINHO_LONGO_DEMAIS;

        // Agora eh descobrir se eh diretorio ou nao.
        DWORD attrs = GetFileAttributesA(real);
        if (attrs == INVALID_FILE_ATTRIBUTES) return COMANDO_CAMINHO_NAO_ENCONTRADO; // nao existe ou ocorreu um erro

        char * filestr = strdup(caminho);
        if (!filestr) return COMANDO_ERRO_DE_MEMORIA;
        if (vetor_push(vetor, &filestr)) return COMANDO_OK;
        free(filestr);
        return COMANDO_ERRO_DE_MEMORIA;
}

bool coletar_arquivos(Vetor * out, const Manifesto * src){
        char ** inclusos = vetor_dados(&src->includes);
        size_t qtd_inclusos = vetor_tamanho(&src->includes);

        for (int i = 0; i < qtd_inclusos; i++){
                if(!adicionar_caminho_com_regras(out, inclusos[i], src)) return false;
        }
        return true;
}

bool adicionar_caminho_com_regras(Vetor * out, const char * caminho, const Manifesto * manifesto){
        char caminho_real[TAMANHO_MAX_CAMINHO_ARQUIVO];
        if(!juntar_caminhos(caminho_real, sizeof(caminho_real), manifesto->root, caminho)) return false;
        
        DWORD attrs = GetFileAttributesA(caminho_real);
        if (attrs == INVALID_FILE_ATTRIBUTES) return false; // ocorreu um erro

        char ** exclusos = vetor_dados(&manifesto->excludes);
        size_t qtd_exclusos = vetor_tamanho(&manifesto->excludes);

        char caminho_excluso[TAMANHO_MAX_CAMINHO_ARQUIVO];
        for (size_t i = 0; i < qtd_exclusos; i++){
                if (caminho_contem(exclusos[i], caminho)) return true; // nao inclui, mas retorna sucesso 
        }
        
        if (attrs & FILE_ATTRIBUTE_DIRECTORY) {
                // agr vamos adicionar todos os arquivos dentro da funcao
                WIN32_FIND_DATA fdFile;
                HANDLE hFind = NULL;

                char buff[TAMANHO_MAX_CAMINHO_ARQUIVO];
                snprintf(buff, sizeof(buff), "%s/*.*", caminho_real); // padrao para procurar todos os arquivos

                if((hFind = FindFirstFile(buff, &fdFile)) == INVALID_HANDLE_VALUE) return false;

                // procura pelos proximos arquivos
                do{
                        if (strcmp(fdFile.cFileName, ".") == 0 ||
                        strcmp(fdFile.cFileName, "..") == 0) continue; // pula "." e "..", que nao sao arquivos!

                        snprintf(buff, sizeof(buff), "%s/%s", caminho, fdFile.cFileName); // pega o caminho (RELATIVO, NAO REAL)pro proximo arquivo. Lembre-se que todo arquivo sendo adicionado vai ser concatenado com manifesto->root depois. Sim, eh importante que isso continue: Quando o archive for extraido, nao queremos que ele seja extraido para C:/users/userpc/projetos/projeto1, mas para o diretorio alvo passado para o script de descompressao... E dahi, com os paths relativos, podemos extrair para o diretorio fornecido 
                        if (!adicionar_caminho_com_regras(out, buff, manifesto)){
                                FindClose(hFind);
                                return false;
                        }; // recursivamente adiciona os outros
                }while(FindNextFile(hFind, &fdFile));
                FindClose(hFind);
                return true;
        }
        // senao, eh arquivo
        char * caminho_dup = strdup(caminho);
        if (!caminho_dup) return false; 
        if(vetor_push(out, &caminho_dup)) return true;
        free(caminho_dup);
        return false;

}

void liberar_vetor_de_strings(Vetor * v){
        for (size_t i = 0; i < v->quantidade; i++)
                free(vetor_get_as(v, i, char*));
        vetor_free(v);
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

void calcular_offsets(const HeaderProjeto headerprojeto, HeaderArquivo * headerarquivo){
        uint64_t offset_atual = sizeof(HeaderProjeto) + (headerprojeto.quantidade_arquivos * sizeof(HeaderArquivo));

        for (size_t i = 0; i < headerprojeto.quantidade_arquivos; i++){
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

bool arquivar(const char * caminho_out, const HeaderProjeto headerprojeto, const HeaderArquivo headers_de_arquivo[], const Dados dadoscomprimidos[]){
        FILE * out = fopen(caminho_out, "wb");
        if (!out) {
                fprintf(stderr, "ERRO: Falha ao criar arquivo .archive: %s\n", strerror(errno));
                goto arquivar_falha;
        }

        if (!fwrite(&headerprojeto, sizeof(headerprojeto), 1, out)) goto arquivar_erro;
        if (!fwrite(headers_de_arquivo, sizeof(HeaderArquivo), headerprojeto.quantidade_arquivos,  out)) goto arquivar_erro;
        for(size_t i = 0; i < headerprojeto.quantidade_arquivos; i++){
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

