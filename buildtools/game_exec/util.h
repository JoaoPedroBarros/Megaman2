#pragma once

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <zlib.h>
#include <basetyps.h>

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
        void static inline * vetor_ultimo(const Vetor * v){return vetor_at(v, v->quantidade-1);}

        bool vetor_remove(Vetor *, size_t i);
        bool vetor_remove_swap(Vetor *, size_t i);
        bool vetor_remove_free_elem(Vetor * v, size_t i, void (*free_elem)(void*));
        bool vetor_remove_swap_free_elem(Vetor * v, size_t i, void (*free_elem)(void*));

        bool vetor_init(Vetor *, size_t capacidade_inicial, size_t tamanho_elemento);
        bool vetor_reservar(Vetor *, size_t nova_capacidade);
        void static inline vetor_clear(Vetor * v){v->quantidade = 0;}
        void vetor_free(Vetor *);
        void vetor_free_elementos(Vetor *, void (*free_por_elemento)(void *));
        bool static inline vetor_vazio(const Vetor * v){return !v->quantidade;};
        size_t static inline vetor_tamanho(const Vetor * v) {return v->quantidade;}
        size_t static inline vetor_capacidade(const Vetor * v) {return v->capacidade;}
        void static inline * vetor_dados(const Vetor * v){return v->dados;}     

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

#pragma region Arquivos
        bool caminho_absoluto(const char *input, char *output, size_t output_size);
        bool eh_caminho_absoluto(const char *);

        // retorna se o primeiro caminho contem o segundo ou nao
        bool caminho_contem(const char * caminho_base, const char * caminho_analizado);

        bool obter_diretorio_de_arquivo(char * out, size_t out_tamanho, const char * path);
        bool juntar_caminhos(char * out, size_t out_tamanho, const char * base, const char * relativo_ah_base);

        FILE * criar_arquivo(const char * path, const char * mode);
#pragma endregion

#pragma region CRC
        // retorna um numero de checksum unico para um dado array de bytes (e.g. int, struct, string, arquivo binario, etc...)
        uLong crc_bytes(void *, size_t);
        uLong static inline crc_dados(const Dados dados){return crc_bytes(dados.bytes, dados.tamanho);}
#pragma endregion       

#pragma region GUID
        void guid_to_str(char * out, size_t out_tamanho, GUID guid);
#pragma endregion