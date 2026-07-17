#pragma once

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#pragma region Vetores
        typedef struct Vetor {
        size_t quantidade;
        size_t capacidade;
        size_t tamanho_elemento;
        uint8_t * dados; // array de bytes
        } Vetor;

        bool vetor_push(Vetor *, const void * data);
        void * vetor_at(const Vetor *, size_t i);
        #define vetor_at_as(v, i, T) ((T)vetor_at((v), (i)))
        #define vector_get(v, i) (*vetor_at((v), (i)))
        #define vetor_get_as(v, i, T) (*(T *)vetor_at((v), (i)))
        void * vetor_ultimo(const Vetor *);

        bool vetor_init(Vetor *, size_t capacidade_inicial, size_t tamanho_elemento);
        bool vetor_reservar(Vetor *, size_t nova_capacidade);
        void vetor_clear(Vetor *);
        void vetor_free(Vetor *);
        bool vetor_vazio(const Vetor *);
        size_t vetor_tamanho(const Vetor *);
        size_t vetor_capacidade(const Vetor *);
#pragma endregion

#pragma region Dados
        typedef struct Dados {
                uint64_t tamanho;
                uint8_t * bytes;
        } Dados;
#pragma endregion

#pragma region Parsing
        typedef struct StringView {
                const char *ptr;
                size_t len;
        } StringView;

        static bool eh_espaco(char c);
        bool parse_linha(const char * linha, Vetor * out); // retorna os argumentos de uma linha
#pragma endregion

