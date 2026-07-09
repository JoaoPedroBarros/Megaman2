# Arquivo que guarda as informacoes sobre o mapa.

        # TIPOS DE TILES VISUAIS
        .eqv TILE_VOID        0

        # TIPOS DE TILES DE COLISAO
        .eqv TILE_COLISAO_TRANSPONIVEL  0
        .eqv TILE_COLISAO_SOLIDO        1
        .eqv TILE_COLISAO_PLATAFORMA    2
        .eqv TILE_COLISAO_PERIGO        3
        .eqv TILE_COLISAO_MORTE         4
        .eqv TILE_TRANSICAO_BOSS        5

        # FLAGS DIRECIONAIS DE TILES DE COLISAO 
        flags_tile_colisao:
        .eqv FLAG_COLISAO_BAIXO         0x1     # bit 0
        .eqv FLAG_COLISAO_ESQUERDA      0x2     # bit 1
        .eqv FLAG_COLISAO_CIMA          0x4     # bit 2
        .eqv FLAG_COLISAO_DIREITA       0x8     # bit 3

        # FRICCAO
        .eqv FATOR_FRICCAO_AR           4       # velocidade decresce por 2^(-5) = 1/32 por frame (desaceleracao proporcional ah velocidade)
        .eqv FATOR_FRICCAO_CHAO         3       # velocidade decresce por 2^(-3) = 1/8 por frame (desaceleracao proporcional ah velocidade)
        .eqv FRICCAO_CONSTANTE_CHAO_Q12 128     # velocidade decresce em 0.03125 px/frame todo frame (desaceleracao constante)

        .byte   0x0  # 0000     - sem colisao
        .byte   0xF  # 1111     - colisao total
        .byte   0x4  # 0010     - apenas de cima
        .byte   0x0  # 0000     - sem colisao
        .byte   0x0  # 0000     - sem colisao