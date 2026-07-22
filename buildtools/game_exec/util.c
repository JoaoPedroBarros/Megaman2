// Fernando de Almeida

#include "util.h"
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include <ctype.h>
#include <limits.h>
#include <fcntl.h>          
#include <sys/stat.h>
#include <direct.h>
#include <errno.h>

#ifdef WIN32
        #include <windows.h>
#else
        #include <ftw.h>
#endif

#pragma region Vetores
        bool vetor_init(Vetor * v, size_t capacidade_inicial, size_t tamanho_elemento){
                v->dados = NULL;
                v->capacidade = capacidade_inicial;
                v->quantidade = 0;
                v->tamanho_elemento = tamanho_elemento;
                return (capacidade_inicial > 0) ? vetor_reservar(v, capacidade_inicial) : true;
        }

        bool vetor_reservar(Vetor * v, size_t nova_capacidade){
                void * novoarr = realloc(
                        v->dados,
                        nova_capacidade * v->tamanho_elemento
                );
                if (!novoarr) return false;
                v->dados = (uint8_t*) novoarr;
                v->capacidade = nova_capacidade;
                return true;
        }

        bool vetor_push(Vetor * v, const void * data){
                if (v->quantidade == v->capacidade){
                        size_t nova_capacidade = (v->capacidade == 0) ? 1 : v->capacidade * 2;
                        if (!vetor_reservar(v, nova_capacidade)) return false;
                }
                
                // copia data para o vetor
                memcpy(
                        v->dados + (v->quantidade * v->tamanho_elemento),
                        data,
                        v->tamanho_elemento
                );
                v->quantidade++;
                return true;
        }

        void vetor_free(Vetor * v){
                free(v->dados);
                v->capacidade = 0;
                v->quantidade = 0;
                v->dados = NULL;
        }

        void vetor_free_elementos(Vetor * v, void (*free_por_elemento)(void *)){
                size_t lim = v->quantidade * v->tamanho_elemento;
                for(int p = 0; p < lim; p+= v->tamanho_elemento){
                        free_por_elemento( *(void**)(v->dados + p));
                }
                vetor_free(v);
        }

        void * vetor_at(const Vetor *v, size_t i){
                if (i >= v->quantidade) return NULL;
                return v->dados + (i * v->tamanho_elemento);
        } 

        bool vetor_remove(Vetor * v, size_t i){
                if (i >= v->quantidade) return false;

                char *base = (char*)v->dados;
                char *elemptr = base + i * v->tamanho_elemento;
                memmove(elemptr, elemptr+v->tamanho_elemento, v->tamanho_elemento*(v->quantidade-i-1));
                v->quantidade--;
                return true;
        };
        bool vetor_remove_swap(Vetor * v, size_t i){
                if (i >= v->quantidade) return false;
                memcpy(
                        (void*)((uint8_t*)v->dados + (i*v->tamanho_elemento)), 
                        (void*)((uint8_t*)v->dados + ((v->quantidade-1)*v->tamanho_elemento)), 
                        v->tamanho_elemento);
                v->quantidade--;
                return true;
        };
        bool vetor_remove_free_elem(Vetor * v, size_t i, void (*free_elem)(void*)){
                if (i >= v->quantidade) return false;

                uint8_t **base = (uint8_t**)v->dados;
                void **elemptr = (void**)(base + i * v->tamanho_elemento);
                free_elem(*elemptr);
                memmove((void*)elemptr, (void*)elemptr+v->tamanho_elemento, v->tamanho_elemento*(v->quantidade-i-1));
                v->quantidade--;
                return true;
        }
        bool vetor_remove_swap_free_elem(Vetor * v, size_t i, void (*free_elem)(void*)){
                if (i >= v->quantidade) return false;
                void ** elemptr = (void**)((uint8_t*)v->dados + (i*v->tamanho_elemento));
                free_elem(*elemptr);
                memcpy(
                        (void*)elemptr,
                        (void*)((uint8_t*)v->dados + ((v->quantidade-1)*v->tamanho_elemento)), 
                        v->tamanho_elemento);
                v->quantidade--;
                return true;
        }

#pragma endregion

#pragma region Parsing
        static inline bool eh_espaco(char c){
                return c == ' ' || c == '\t' || c == '\r';
        }

        bool string_view_equals(StringView a, StringView b){
                if (a.len != b.len) return false;
                for (size_t i = 0; i < a.len; i++)
                        if (a.ptr[i] != b.ptr[i]) return false;
                return true;
        }

        bool string_view_equals_cstr(StringView a, const char *b){
                for (size_t i = 0; i < a.len; i++)
                        if (a.ptr[i] != b[i]) return false;
                
                return !b[a.len];
        }

        bool string_view_equals_ignore_case(StringView a, StringView b){
                if (a.len != b.len) return false;
                for (size_t i = 0; i < a.len; i++)
                        if (tolower((unsigned char)a.ptr[i]) != tolower((unsigned char)b.ptr[i])) return false;
                return true;
        }

        bool string_view_equals_cstr_ignore_case(StringView a, const char *b){
                for (size_t i = 0; i < a.len; i++){
                        if (tolower((unsigned char)a.ptr[i]) != tolower((unsigned char)b[i])) return false;
                }
                return !b[a.len];
        }

        char * criar_copia_stringview(StringView src){
                char * output = malloc(src.len + 1);
                if (!output) return NULL;
                memcpy(output, src.ptr, src.len);
                output[src.len] = '\0';
                return output;
        }

        bool parse_linha(const char * linha, Vetor * out){
                bool token = false; // se estamos em um token
                bool aspas = false; // se temos aspas abertas

                const char * comeco_token = linha; // comeco do token atual sendo atualizado
                const char * atual = linha; // caractere sendo analizado

                // analiza caractere por caractere
                for(;*atual && *atual != '\n'; atual++){
                        if (*atual == '#' && !aspas) break; // significa que o resto da linha eh comentario
                        if (!token) {
                                if (*atual == ' ') continue;
                                if (*atual == '\"') {
                                        aspas = true;
                                        comeco_token = atual + 1;
                                } 
                                else 
                                        comeco_token = atual;
                                token = true;
                                continue;
                        }
                        else if (*atual == '\"' && aspas){
                                aspas = false;
                        }
                        else if (aspas || !eh_espaco(*atual)) continue;

                        if(!vetor_push(out, &(StringView){comeco_token, atual - comeco_token})) return false;
                        aspas = false;
                        token = false;
                }
                if (aspas) return false; //aspas nao fechadas
                return token ? vetor_push(out, &(StringView){comeco_token, atual - comeco_token}) : true;
        }
#pragma endregion

#pragma region Arquivos
        bool caminho_absoluto(const char * in, char * out, size_t out_tamanho){
                #ifdef WIN32
                        // no windowszz
                        DWORD len = GetFullPathNameA(
                                in,
                                (DWORD) out_tamanho,
                                out,
                                NULL
                        ); 
                        return (len && len < out_tamanho);
                #else
                        // em sistemas POSIX / UNIX
                        char * caminho = realpath(in, NULL);
                        if (!caminho) return false;
                        
                        if (strlen(caminho) >= out_tamanho) {
                                free(caminho);
                                return false;
                        }
                        strncpy(out, caminho, out_tamanho);
                        free(caminho);
                        return true;
                #endif
        }

        bool eh_caminho_absoluto(const char *p){
                // Letra de drive: C:\...
                if (isalpha((unsigned char)p[0]) &&
                        p[1] == ':' &&
                        (p[2] == '\\' || p[2] == '/'))
                                return true;

                // caminho UNC: \\pasta1\pasta2\...
                if (p[0] == '\\' && p[1] == '\\') 
                        return true;

                // caminho POSIX relativo ao root: \home\user\...
                if (p[0] == '/') return true;

                return false;
        }

        bool caminho_contem(const char * caminho_base, const char * caminho_analizado){
                if (strcmp(caminho_base, caminho_analizado) == 0) return true;

                // compara os caminhos 
                size_t len = strlen(caminho_base);

                if (len > strlen(caminho_analizado))
                        return false;

                if (memcmp(caminho_base, caminho_analizado, len) != 0)
                        return false;

                return caminho_analizado[len] == '\0' || caminho_analizado[len] == '/' || caminho_analizado[len] == '\\';
        }

        bool obter_diretorio_de_arquivo(char * out, size_t out_tamanho, const char * path){
                strncpy(out, path, out_tamanho);
                out[out_tamanho - 1] = '\0';

                char *p = strrchr(out, '\\');
                if (!p)
                        p = strrchr(out, '/');

                if (!p){
                        strncpy(out, "./", out_tamanho);
                        return true;
                }
                *p = '\0';
                return true;
        }

        bool juntar_caminhos(char * out, size_t out_tamanho, const char * base, const char * relativo_ah_base){ 
                char ultimochar = base[strlen(base)-1];
                if (ultimochar == '\\' || ultimochar == '/') return snprintf(out, out_tamanho, "%s%s", base, relativo_ah_base) < out_tamanho;
                return snprintf(out, out_tamanho, "%s/%s", base, relativo_ah_base) < out_tamanho;
        }

        FILE * criar_arquivo(const char * path, const char * mode){
                size_t sizeof_path = strlen(path);

                char * p;
                char buff[sizeof_path+1]; // os caminhos para os diretorios pai nunca vao ser maiores que o caminho do arquivo
                strcpy(buff, path); // coloca o path no buffer
                
                // vai criando os diretorios conforme os encontramos
                size_t len = strlen(path);
                for(int i = 0; i < len; i++){
                        if (path[i] == '/' || path[i] == '\\') {
                                buff[i] = '\0';
                                #ifdef WIN32
                                        if(_mkdir(buff) < 0 && errno != EEXIST) return NULL;
                                #else
                                        // Modo Ler/escrever/executar pro owner, Ler/executar para grupo e outros (0755)
                                        mode_t mode = S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH;
                                        if(mkdir(buff, mode) < 0 && errno != EEXIST) return NULL;
                                #endif
                                buff[i] = '/';
                        }
                }


                return fopen(path, mode);
        }

        #ifndef WIN32
                static int remover_callback(const char *fpath, const struct stat *sb,
                int typeflag, struct FTW *ftwbuf) {
                        switch (typeflag) {
                        case FTW_F:
                        case FTW_SL:
                        case FTW_SLN:
                                return unlink(fpath);
                        case FTW_DP:
                                return rmdir(fpath);
                        default:
                                return 0;
                        }
                }
        #endif

        bool remover_diretorio_recursivamente(const char * dir){
        #ifdef WIN32

                char padrao[TAMANHO_MAX_CAMINHO_ARQUIVO];
                if (snprintf(padrao, sizeof(padrao), "%s\\*", dir) >= sizeof(padrao)) return false;

                WIN32_FIND_DATAA find_data;
                HANDLE h = FindFirstFileA(padrao, &find_data);

                if (h == INVALID_HANDLE_VALUE){
                        SetLastError(ERROR_BUFFER_OVERFLOW);
                        return false;
                }

                do {
                        const char *name = find_data.cFileName;

                        if (strcmp(name, ".") == 0 || strcmp(name, "..") == 0)
                        continue;

                        char child[MAX_PATH];
                        if (snprintf(child, sizeof(child), "%s\\%s", dir, name) >= sizeof(child)) {
                        FindClose(h);
                        SetLastError(ERROR_BUFFER_OVERFLOW);
                        return false;
                        }

                        DWORD attr = find_data.dwFileAttributes;

                        bool is_directory = (attr & FILE_ATTRIBUTE_DIRECTORY) != 0;
                        bool is_reparse   = (attr & FILE_ATTRIBUTE_REPARSE_POINT) != 0;

                        if (is_directory && !is_reparse) {
                                if (!remover_diretorio_recursivamente(child)) {
                                        FindClose(h);
                                        return false;
                                }
                        } else {
                                if (!DeleteFileA(child)) {
                                        FindClose(h);
                                        return false;
                                }
                        }

                } while (FindNextFileA(h, &find_data));

                DWORD err = GetLastError();

                FindClose(h);

                if (err != ERROR_NO_MORE_FILES) {
                        SetLastError(err);
                        return false;
                }

                return RemoveDirectoryA(dir);
        #else
                return nftw(dir, remover_callback, max_open_fds, FTW_DEPTH | FTW_PHYS) == 0;
        #endif
        }




#pragma endregion

#pragma region CRC
        uLong crc_bytes(void * dados, size_t tamanho){
                uLong crcInicial = crc32(0L, Z_NULL, 0);
                return crc32(crcInicial, (Bytef *) dados, tamanho);
        }
#pragma endregion

#pragma region GUID
void guid_to_str(char * out, size_t out_tamanho, GUID guid){
        snprintf(out, sizeof(out_tamanho),
                "%08lX-%04X-%04X-%04X-%012llX",
                guid.Data1,
                guid.Data2,
                guid.Data3,
                (guid.Data4[0] << 8) | guid.Data4[1],
                ((unsigned long long)guid.Data4[2] << 40) |
                ((unsigned long long)guid.Data4[3] << 32) |
                ((unsigned long long)guid.Data4[4] << 24) |
                ((unsigned long long)guid.Data4[5] << 16) |
                ((unsigned long long)guid.Data4[6] << 8) |
                guid.Data4[7]);
}
#pragma endregion