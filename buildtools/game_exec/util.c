// Fernando de Almeida

#include "util.h"
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

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

        void vetor_clear(Vetor * v){v->quantidade = 0;}

        void vetor_free(Vetor * v){
                free(v->dados);
                v->capacidade = 0;
                v->quantidade = 0;
                v->dados = NULL;
        }

        size_t vetor_tamanho(const Vetor * v) {return v->quantidade;}
        bool vetor_vazio(const Vetor * v) {return v->quantidade == 0;}
        size_t vetor_capacidade(const Vetor * v) {return v->capacidade;}
        void * vetor_at(const Vetor *v, size_t i){
                if (i < 0 || i >= v->quantidade) return NULL;
                return v->dados + (i * v->tamanho_elemento);
        }
        void * vetor_ultimo(const Vetor * v){return vetor_at(v, v->quantidade-1);}
#pragma endregion

#pragma region Parsing
        static bool eh_espaco(char c){
                return c == ' ' || c == '\t' || c == '\r';
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