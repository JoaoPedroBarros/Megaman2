// Fernando de Almeida

#include "util.h"
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <ctype.h>

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
                if (v->quantidade == v->capacidade)
                        if (!vetor_reservar(v, v->capacidade*2)) return false;
                
                // copia data para o vetor
                memcpy(
                        v->dados + (v->quantidade * v->tamanho_elemento),
                        data,
                        v->tamanho_elemento
                );
                v->quantidade++;
                return true;
        }

        void inline vetor_clear(Vetor * v){v->quantidade = 0;}

        void vetor_free(Vetor * v){
                free(v->dados);
                v->capacidade = 0;
                v->quantidade = 0;
                v->dados = NULL;
        }

        void vetor_free_elementos(Vetor * v, void (*free_por_elemento)(void *)){
                size_t lim = v->quantidade * v->tamanho_elemento;
                for(int p = 0; p < lim; p+= v->tamanho_elemento){
                        free_por_elemento((void*) (v->dados + p));
                }
                vetor_free(v);
        }

        size_t inline vetor_tamanho(const Vetor * v) {return v->quantidade;}
        bool inline vetor_vazio(const Vetor * v) {return v->quantidade == 0;}
        size_t inline vetor_capacidade(const Vetor * v) {return v->capacidade;}
        void * vetor_at(const Vetor *v, size_t i){
                if (i < 0 || i >= v->quantidade) return NULL;
                return v->dados + (i * v->tamanho_elemento);
        }
        void inline * vetor_ultimo(const Vetor * v){return vetor_at(v, v->quantidade-1);}
        void inline * vetor_dados(const Vetor * v){
                return v->dados;
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
                        if (tolower(a.ptr[i]) != tolower(b.ptr[i])) return false;
                return true;
        }

        bool string_view_equals_cstr_ignore_case(StringView a, const char *b){
                for (size_t i = 0; i < a.len; i++){
                        if (tolower(a.ptr[i]) != tolower(b[i])) return false;
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
                        else if (*atual == '\"' && !aspas){
                                aspas = false;
                        }
                        else if (eh_espaco(*atual) || aspas) continue;

                        if(!vetor_push(out, &(StringView){comeco_token, atual - comeco_token})) return false;
                        aspas = false;
                        token = false;
                }
                if (aspas) return false; //aspas nao fechadas
                return token ? vetor_push(out, &(StringView){comeco_token, atual - comeco_token}) : true;
        }
#pragma endregion