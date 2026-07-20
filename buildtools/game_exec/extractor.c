#include "util.h"
#include "archive.h"
#include "extract.h"
#include <stdio.h>

int main(int argc, char ** argv){
        if (argc != 3){
                printf("Uso: %s arquivo_a_extrair diretorio_alvo\n\n", argv[0]);
                printf("Exemplo1: %s file.archive ../..\n");
                printf("Exemplo2: %s proj.archive /usr/docs/proj\n", argv[0]);
                return EXIT_SUCCESS;
        }

        printf("Extraindo...\n");
        ExtrairStatus status = extrair_projeto(argv[1], argv[2]);
        if (status == 0) {
                printf("Arquivo(s) extraidos com sucesso.\n");
                return EXIT_SUCCESS;
        }
        printf("Erro ao extrair arquivo: %s\n", strerr_extrair(status));
        return EXIT_FAILURE;
}