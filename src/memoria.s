# MEMORIA DO JOGO

.data
        .eqv TAMANHO_TILE 32            # tamanho do lado de um tile (32, no caso) -- importante ser uma potencia de 2
        .eqv AREA_TILE 1024             # tamanho do lado de um tile, ao quadrado (32*32, no caso)
        .eqv LOG2_TAMANHO_TILE 5        # 2^LOG2_TAMANHO_TILE = TAMANHO_TILE -- importante manter
                                        # a existencia de LOG2_TAMANHO_TILE permite substituir muitos divs e muls por
                                        # srais e sllis

        .eqv LARGURA_VGA 320
        .eqv ALTURA_VGA 240
        .eqv CENTRO_VGA_X 160
        .eqv CENTRO_VGA_Y 120

        .eqv FRAME_0 0xFF000000
        .eqv FRAME_0_FIM 0xFF012C00
        .eqv FRAME_1 0xFF100000
        .eqv FRAME_1_FIM 0xFF112C00

        .eqv COR_TRANSPARENTE 0xC7

.data

        # FRAME_BUFFER eh o frame que nao estah sendo mostrado atualmente
        FRAME_BUFFER_PTR: .word FRAME_1
        FRAME_BUFFER_FIM_PTR: .word FRAME_1_FIM

        # FRAME_ATUAL eh o frame que ESTAH sendo mostrado atualmente (0 ou 1)
        FRAME_ATUAL:      .word 0


        # onde uma versao modificavel do mapa fica guardada
        tilemap: .word 0 0 
        .space 4096

        tilemap_colisao: .word 0 0
        .space 4096

        # qual textura estah atualmente carregada para os tiles da fase
        textura_mapa: .word 0

        # tecla atualmente pressionada nesse ciclo
        # util enquanto estivermos rodando no fpgrars...
        TECLA_PRESSIONADA: .word 0

        # x e y do canto superior esquerdo da camera
        .eqv camera_x 0
        .eqv camera_y 4
        camera:
                .word 0 0


        .word 0xF0CAF0FA