#pragma once

#include <stdbool.h>
#include <zlib.h>
#include "archive.h"
#include "util.h"

typedef enum ExtrairStatus {
        EXTRAIR_OK,
        EXTRAIR_CHECKSUM_INVALIDA,
        EXTRAIR_ARQUIVO_NAO_ENCONTRADO,
        EXTRAIR_ARQUIVO_INVALIDO_OU_CORROMPIDO,
        EXTRAIR_VERSAO_NAO_SUPORTADA,
        EXTRAIR_ERRO_DE_LEITURA,
        EXTRAIR_ERRO_DE_ESCRITA,
        EXTRAIR_DIRETORIO_ALVO_MUITO_LONGO,
        EXTRAIR_ERRO_DE_MEMORIA,
        EXTRAIR_CAMINHO_INVALIDO
} ExtrairStatus;

ExtrairStatus extrair_projeto(const char * arquivo_a_extrair, const char * diretorio_alvo);
ExtrairStatus extrair_projeto_de_arquivo(FILE * arquivo_fonte, const char * diretorio_alvo);

ExtrairStatus extrair_header_projeto(HeaderProjeto * out, Archive * archive);
ExtrairStatus extrair_headers(HeaderArquivo headers[], Archive * archive);
ExtrairStatus extrair_arquivos(const char * diretorio_alvo, const HeaderArquivo * headers, Archive * archive);
ExtrairStatus extrair_arquivo(const char * diretorio_alvo, const HeaderArquivo * header, Archive * archive);

const char * strerr_extrair(ExtrairStatus numeroerro);

// extrai dados comprimidos pela z library
ExtrairStatus extrair_dados(const Dados * in, Dados * out, uint64_t tamanho_original);
