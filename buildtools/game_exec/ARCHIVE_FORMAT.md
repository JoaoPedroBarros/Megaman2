1 HeaderProjeto:
        (uint32_t) numero_magico
        (uint32_t) versao
        (uint32_t) quantidade_arquivos
        (uLong) checksum

(HeaderProjeto.quantidade_arquivos) HeaderArquivo:
        (char[TAMANHO_MAX_CAMINHO_ARQUIVO]) caminho
        (uint64_t) tamanho_original;
        (uint64_t) tamanho_comprimido;
        (uint64_t) offset;
        (uLong) checksum;                       

Data:
        blobs comprimidos