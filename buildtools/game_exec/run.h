#pragma once

#define TEMP_PREFIX "flora_oac2026_1-" // prefixo dos diretorios temporarios do programa

#include <stdlib.h>
#include "bundler.h"

bool adquirir_caminho_self(char * out, size_t out_tamanho);
bool adquirir_footer(Footer * out, FILE * executavel);
bool adquirir_diretorio_temporario(char * out, size_t out_tamanho);
bool cleanup_diretorios_temporarios();
 
#ifdef WIN32
        #define comando "src\\fpgrars-x86_64-pc-windows-gnu.exe src\\main.s"
#else
        #define comando "sem suporte." /* TODO: Adicionar executavel linux */ 
#endif