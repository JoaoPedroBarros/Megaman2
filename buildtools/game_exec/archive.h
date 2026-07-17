/*
Archive

Contem as funcoes usadas para gerar o arquivo .archive do jogo.
*/

#pragma once

#define NUMERO_MAGICO 0xF102A
#define VERSAO 0x0100   // v0.1.0.0 - 2026.16.07
#define TAMANHO_MAX_CAMINHO_ARQUIVO 2048

#include <stdio.h>
#include <stdint.h>

typedef struct VetorArquivos {
    size_t quantidade;
    size_t capacidade;
    char ** caminhos;
} VetorArquivos;

typedef struct Dados {
    uint64_t tamanho;
    uint8_t * bytes;
} Dados;

typedef struct HeaderJogo {
    uint32_t numero_magico;  
    uint32_t versao;  
    uint32_t quantidade_arquivos;
    uLong checksum;                           
} HeaderJogo;

typedef struct HeaderArquivo {
    char caminho[TAMANHO_MAX_CAMINHO_ARQUIVO]; // TODO - Refatorar isso aqui. eh bom tem um uint16_t tamanho_nome e um char nome[] no final. no arquivo a gente escreve o nome de acordo com o tamanho. ai n tem que gastar TAMANHO_MAX_CAMINHO_ARQUIVO bytes toda vez.
    uint64_t tamanho_original;
    uint64_t tamanho_comprimido;
    uint64_t offset;
    uLong checksum;                       
} HeaderArquivo;

bool get_arquivos(VetorArquivos * dest, const char * diretorio_real, const char * diretorio_relativo);
bool adicionar_arquivos(VetorArquivos * dest, const VetorArquivos src);
bool adicionar_arquivo(VetorArquivos * v, const char * src);

Dados ler_arquivo(const char *);
Dados ler_arquivo_projeto(const char * diretorio_raiz, const char * caminho_relativo);
Dados comprimir(const Dados);
void liberar_vetor_arquivos(VetorArquivos *);

void calcular_offsets(const HeaderJogo, HeaderArquivo[]);

uLong crc_bytes(void * arquivo, size_t);

VetorArquivos get_arquivos_fonte(const char * diretorio_raiz);
bool arquivar(const char * caminho_out, const HeaderJogo, const HeaderArquivo[], const Dados dadoscomprimidos[]);