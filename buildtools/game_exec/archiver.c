//Fernando de almeida

#include "archive.h"
#include "util.h"
#include <stdio.h>
#include <stdlib.h>

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