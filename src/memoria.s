# MEMORIA DO JOGO

.data
        .eqv TAMANHO_TILE 32    # tamanho do lado de um tile (32, no caso)
        .eqv AREA_TILE 1024     # tamanho do lado de um tile, ao quadrado (32*32, no caso)

        .eqv LARGURA_VGA 320
        .eqv ALTURA_VGA 240

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
        .space 1000

        # qual textura estah atualmente carregada para os tiles da fase
        textura_mapa: .word textura_teste

        # struct, com posicao de cada atributo
        .eqv jogador_x 0
        .eqv jogador_y 4
        .eqv jogador_direcao 8
        jogador: 
                .space 12

        # x e y do canto superior esquerdo da camera
        .eqv camera_x 0
        .eqv camera_y 4
        camera:
                .space 8

        # definicoes e memoria adicional
        .include "fase_e_mapa/definicoes_mapas.s"
        .include "administracao_de_memoria/heap.s"
        .include "entidades/definicoes_entidades.s"

        # ASSETS UTILIZADOS
        .include "../assets/mapa1.data"
        .include "../assets/textura_teste.data"

        # ENTIDADES NO JOGO
        .include "entidades/exemplo.s"

        # OUTROS
        .include "entidades/lista_entidades.s"
