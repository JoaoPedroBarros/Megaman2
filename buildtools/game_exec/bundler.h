#pragma once
#include <stdint.h> 
#include <stdio.h>

typedef struct Footer{
        uint32_t numero_magico;  
        uint32_t versao;  
        uint64_t archive_offset;
        uint64_t archive_tamanho;
}Footer;

uint64_t copiar_arquivo(FILE*dest, FILE*src);