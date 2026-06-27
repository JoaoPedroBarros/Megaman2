# Arquivo que guarda as informacoes sobre o mapa.

        # TIPOS DE TILES VISUAIS
        .eqv TILE_VOID        0

        # TIPOS DE TILES DE COLISAO
        .eqv TILE_COLISAO_TRANSPONIVEL  0
        .eqv TILE_COLISAO_SOLIDO        1
        .eqv TILE_COLISAO_PLATAFORMA    2
        .eqv TILE_COLISAO_PERIGO        3
        .eqv TILE_COLISAO_MORTE         4

        # FLAGS DIRECIONAIS DE TILES DE COLISAO 
        flags_tile_colisao:
        .eqv FLAG_COLISAO_BAIXO         0x1     # bit 0
        .eqv FLAG_COLISAO_ESQUERDA      0x2     # bit 1
        .eqv FLAG_COLISAO_CIMA          0x4     # bit 2
        .eqv FLAG_COLISAO_DIREITA       0x8     # bit 3

        # FRICCAO
        .eqv FATOR_FRICCAO_AR           3       # velocidade decresce por 2^(-3) = 1/8 por frame
        .eqv FATOR_FRICCAO_CHAO         2       # velocidade decresce por 2^(-2) = 1/4 por frame

        .byte   0x0  # 0000     - sem colisao
        .byte   0xF  # 1111     - colisao total
        .byte   0x4  # 0010     - apenas de cima
        .byte   0x0  # 0000     - sem colisao
        .byte   0x0  # 0000     - sem colisao