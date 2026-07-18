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
        void inline * vetor_ultimo(const Vetor *);

        bool vetor_remove(Vetor *, size_t i);
        bool vetor_remove_swap(Vetor *, size_t i);
        bool vetor_remove_free_elem(Vetor * v, size_t i, void (*free_elem)(void*));
        bool vetor_remove_swap_free_elem(Vetor * v, size_t i, void (*free_elem)(void*));

        bool vetor_init(Vetor *, size_t capacidade_inicial, size_t tamanho_elemento);
        bool vetor_reservar(Vetor *, size_t nova_capacidade);
        void inline vetor_clear(Vetor *);
        void vetor_free(Vetor *);
        void vetor_free_elementos(Vetor *, void (*free_por_elemento)(void *));
        bool inline vetor_vazio(const Vetor *);
        size_t inline vetor_tamanho(const Vetor *);
        size_t inline vetor_capacidade(const Vetor *);
        void inline * vetor_dados(const Vetor *);
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

        bool string_view_equals(StringView, StringView);
        bool string_view_equals_ignore_case(StringView, StringView);

        bool string_view_equals_cstr(StringView, const char *);
        bool string_view_equals_cstr_ignore_case(StringView, const char *);

        char * criar_copia_stringview(StringView);

        bool parse_linha(const char * linha, Vetor * out); // retorna os argumentos de uma linha
#pragma endregion

