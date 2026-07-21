#define _FILE_OFFSET_BITS 64 // necessario para ftello

#include "bundler.h"
#include "archive.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <sys/types.h>

#ifdef WIN32
        #include <windows.h>
#endif

int main(int argc, char ** argv){
        if (argc != 4){
                printf("Uso: %s archive runscript output\n\n", argv[0]);
                printf("Exemplo1: %s proj.archive run.exe proj.exe\n", argv[0]);
                printf("Exemplo2: %s flora.archive run.exe jogoflora.exe", argv[0]);
                return EXIT_SUCCESS;
        }

        FILE * archive = fopen(argv[1], "rb");
        if (!archive){
                fprintf(stderr, "ERRO: Falha ao abrir arquivo %s: %s.\n", argv[1], strerror(errno));
                return EXIT_FAILURE;
        }

        FILE * runscript = fopen(argv[2], "rb");
        if (!runscript){
                fprintf(stderr, "ERRO: Falha ao abrir arquivo %s: %s.\n", argv[2], strerror(errno));
                fclose(archive);
                return EXIT_FAILURE;
        }

        FILE * output = fopen(argv[3], "wb");
        if (!output){
                fprintf(stderr, "ERRO: Falha ao criar arquivo %s: %s", argv[3], strerror(errno));
                fclose(archive);
                fclose(runscript);
                return EXIT_FAILURE;
        }

        int exit_code = EXIT_FAILURE; // ao menos que tudo deh certo, saimos com erro

        Footer footer;
        footer.numero_magico = NUMERO_MAGICO;
        footer.versao = VERSAO;

        if (copiar_arquivo(output, runscript) == 0){
                fprintf(stderr, "ERRO: Falha ao juntar arquivos: %s\n", strerror(errno));
                goto cleanup;
        }


        #ifdef __MINGW32__
                __int64 archive_pos = ftello64(output);
        #elif defined(WIN32)
                __int64 archive_pos = _ftelli64(output);
        #else
                off_t archive_pos = ftello(output);
        #endif
        
        if (archive_pos < 0){
                fprintf(stderr, "ERRO: Falha ao obter offset do arquivo de archive: %s\n", strerror(errno));
                goto cleanup;
        }

        footer.archive_offset = (uint64_t) archive_pos;

        footer.archive_tamanho = copiar_arquivo(output, archive);
        if (footer.archive_tamanho == 0){
                fprintf(stderr, "ERRO: Falha ao juntar arquivos: %s\n", strerror(errno));
                goto cleanup;
        }

        if(fwrite(&footer, sizeof(Footer), 1, output) != 1){
                fprintf(stderr, "ERRO: Erro ao escrever footer no arquivo %s: %s", argv[3], strerror(errno));
                goto cleanup;
        }
        
        printf("Arquivo %s criado com sucesso.\n", argv[3]);

        exit_code = EXIT_SUCCESS;

        cleanup:
        fclose(archive);
        fclose(runscript);
        fclose(output);
        if (exit_code != EXIT_SUCCESS) remove(argv[3]); //tira o output defeituoso
        return exit_code;
}

uint64_t copiar_arquivo(FILE*dest, FILE*src){
    uint8_t buffer[8192];
    uint64_t total = 0;

    size_t n;
    while ((n = fread(buffer, sizeof(uint8_t), sizeof(buffer), src)) > 0) {
        if (fwrite(buffer, sizeof(uint8_t), n, dest) < n) return 0;
        total += n;
    }
    if(ferror(src)) return 0; // erro
    return total;
}