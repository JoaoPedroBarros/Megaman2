/*
Archive

Contem as funcoes usadas para gerar o arquivo .archive do jogo.
*/

#pragma once

#define NUMERO_MAGICO 0xF102A
#define VERSAO 0x0300   // v0.3.0.0 - 2026.22.07

#include <stdio.h>
#include <stdint.h>
#include <zlib.h>
#include "util.h"

typedef struct HeaderProjeto {
    uint32_t numero_magico;  
    uint32_t versao;  
    uint32_t quantidade_arquivos;
    uint32_t reserved;
    uint64_t checksum;                           
} HeaderProjeto;

typedef struct HeaderArquivo {
    uint64_t tamanho_original;
    uint64_t tamanho_comprimido;
    uint64_t offset;
    uint64_t checksum;    
    uint32_t caminho_tamanho;        
    char * caminho;           
} HeaderArquivo;

typedef struct Manifesto {
    char * path; // caminho para o manifesto
    char * root; // raiz do manifesto
    Vetor includes; // arquivos/diretorios inclusos
    Vetor excludes; // REGRAS de remocao
} Manifesto;

// status de um comando sendo processado
typedef enum ComandoStatus {
    COMANDO_OK,
    COMANDO_MALFORMADO,
    COMANDO_DESCONHECIDO,
    COMANDO_CAMINHO_NAO_ENCONTRADO,
    COMANDO_CAMINHO_LONGO_DEMAIS,
    COMANDO_ERRO_DE_MEMORIA,
    COMANDO_DUPLICADO,
    COMANDO_SEM_ROOT
} ComandoStatus;

typedef struct Archive {
    FILE * stream;
    uint64_t offset_base;
    HeaderProjeto header;
} Archive;

ComandoStatus processar_comando(const Vetor * vetor, Manifesto * manifesto);
const char * strerr_comando(ComandoStatus numeroerro);

Dados ler_arquivo(const char *);
Dados ler_arquivo_projeto(const char * diretorio_raiz, const char * caminho_relativo);
Dados comprimir(const Dados);
void liberar_vetor_arquivos(Vetor *);
void liberar_vetor_de_strings(Vetor *);

void calcular_offsets(const HeaderProjeto, HeaderArquivo[]);

Manifesto * carregar_manifesto(const char * caminho);
void destruir_manifesto(Manifesto * manifesto);
bool coletar_arquivos(Vetor * out, const Manifesto * src);
ComandoStatus incluir_caminho(Manifesto *, Vetor *, const char * caminho);
bool adicionar_caminho_com_regras(Vetor * out, const char * caminho, const Manifesto * manifesto);

bool arquivar(const char * caminho_out, const HeaderProjeto, const HeaderArquivo[], const Dados dadoscomprimidos[]);
uLong checksum_headers(const HeaderArquivo headers[], size_t quantidade_arquivos);