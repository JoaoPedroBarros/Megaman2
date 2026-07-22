// gcc -o run.exe run.c util.c extract.c archive.c -Wl,-Bstatic -lz -lole32 -Wl,-Bdynamic -O3

#include "util.h"
#include "run.h"
#include "extract.h"
#include <errno.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>

#ifdef WIN32
        #include <windows.h>
        #include <objbase.h> 
#elif defined(__APPLE__)
        #include <mach-o/dyld.h>
#endif

int main(){
        if(!cleanup_diretorios_temporarios()){
                fprintf(stderr, "Erro ao limpar diretorios anteriores: %s\n", strerror(errno));
                return EXIT_FAILURE;
        }; // limpa outros diretorios temporarios deixados pela ferramenta anteriormente que nao foram deletados (e.g. por um crash do programa)

        char path[2048];
        if (!adquirir_caminho_self(path, sizeof(path))) {
                fprintf(stderr, "Erro ao extrair: %s\n",strerror(errno));
                return EXIT_FAILURE;
        }

        FILE * self = fopen(path, "rb");
        if (!self) goto erro_adquirir_dados;

        Footer footer;
        if (!adquirir_footer(&footer, self)) goto erro_adquirir_dados;

        if (seek64(self, footer.archive_offset, SEEK_SET) != 0) goto erro_adquirir_dados;

        char caminho_diretorio_temporario[TAMANHO_MAX_CAMINHO_ARQUIVO];
        if (!adquirir_diretorio_temporario(caminho_diretorio_temporario, sizeof(caminho_diretorio_temporario))) {
                fprintf(stderr, "Erro ao criar diretorio temporario: %s", strerror(errno));
                goto fail;
        };

        ExtrairStatus status = extrair_projeto_de_arquivo(self, caminho_diretorio_temporario);

        if (status != EXTRAIR_OK) {
                fprintf(stderr, "Erro ao extrair arquivos: %s", strerr_extrair(status));
                goto self_destruct;
        }

        // hack temporario!!!
        char shell_comando[2048];
        sprintf(shell_comando, "pushd \"%s\" && " comando, caminho_diretorio_temporario);
        system(shell_comando);

        self_destruct:
                remover_diretorio_recursivamente(caminho_diretorio_temporario);
                fclose(self);
                if (status != EXTRAIR_OK) return EXIT_FAILURE;
                return EXIT_SUCCESS;

        erro_adquirir_dados:
                fprintf(stderr, "Erro ao adquirir dados: %s", strerror(errno));
        fail:
                if(self) fclose(self);
                return EXIT_FAILURE;
}

bool adquirir_caminho_self(char * out, size_t out_tamanho){
        #ifdef WIN32
                DWORD len = GetModuleFileNameA(NULL, out, out_tamanho);
                return (len && len < out_tamanho);
        #elif defined(__APPLE__)
                return (_NSGetExecutablePath(out, &out_tamanho) == 0)
        #else
                ssize_t len = readlink("/proc/self/exe", out, out_tamanho - 1);
                if (len == -1) return false;
                out[len] = '\0';
                return true;
        #endif
}

bool adquirir_footer(Footer * out, FILE * executavel){
        int64_t status = seek64(executavel, -(long) sizeof(Footer), SEEK_END); // pega no final

        if (status != 0) return false;
        size_t lidos = fread(out, sizeof(Footer), 1, executavel);
        return lidos == 1;
}

bool adquirir_diretorio_temporario(char * out, size_t out_tamanho){
        #ifdef WIN32
                char temp[out_tamanho];
                GetTempPathA(out_tamanho, temp);

                GUID guid;
                CoCreateGuid(&guid);

                char guidstr[64];
                guid_to_str(guidstr, sizeof(guidstr), &guid);

                if (snprintf(out, out_tamanho, "%s" TEMP_PREFIX "%s", temp, guidstr) >= out_tamanho) return false;

                return CreateDirectoryA(out, NULL);
        #else
                char dir[] = "/tmp/" TEMP_PREFIX "XXXXXX";

                if (sizeof(dir) > out_tamanho) return false;

                if (mkdtemp(dir) == NULL) return false;

                strncpy(out, dir, out_tamanho);      
                
                return true;
        #endif
}

bool cleanup_diretorios_temporarios(){
        #ifdef WIN32
                char temp[TAMANHO_MAX_CAMINHO_ARQUIVO];
                DWORD len = GetTempPathA(sizeof(temp), temp);

                char padrao[TAMANHO_MAX_CAMINHO_ARQUIVO];
                snprintf(padrao, sizeof(padrao), "%s" TEMP_PREFIX "*", temp);

                WIN32_FIND_DATAA data;
                HANDLE h = FindFirstFileA(padrao, &data);

                do {
                        if (!(data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
                                continue;

                        char diretorio_alvo[TAMANHO_MAX_CAMINHO_ARQUIVO];
                        if (snprintf(diretorio_alvo, sizeof(diretorio_alvo), "%s%s", temp, data.cFileName) >= sizeof(diretorio_alvo)) return false;

                        if (!remover_diretorio_recursivamente(diretorio_alvo)) return false;

                } while (FindNextFileA(h, &data));
                return true;
        #endif
}
