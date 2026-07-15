# lista_entidades
# onde a lista de entidades eh guardada.

# (tipos de entidade em definicoes_entidades.s)

.data

lista_entidades:
        # tipo, tamanho, funcao de criacao, funcao por frame, funcao de desenhar, funcao de colisao, funcao de destrutor
        .word ENTIDADE_PROJETIL_COMUM,        
        .word PROJETIL_COMUM.TAMANHO_STRUCT
        .word PROJETIL_COMUM.NOVO
        .word PROJETIL_COMUM.PROC
        .word PROJETIL_COMUM.DRAW
        .word PROJETIL_COMUM.COLISAO
        .word NULL_PROC

        .word ENTIDADE_EXEMPLO
        .word EXEMPLO.TAMANHO_STRUCT
        .word EXEMPLO.NOVO
        .word EXEMPLO.PROC
        .word EXEMPLO.DRAW
        .word NULL_PROC
        .word EXEMPLO.DESTRUTOR

        .word ENTIDADE_JOGADOR
        .word JOGADOR.TAMANHO_STRUCT
        .word JOGADOR.NOVO
        .word JOGADOR.PROC
        .word JOGADOR.DRAW
        .word JOGADOR.COLISAO
        .word JOGADOR.DESTRUTOR

        .word ENTIDADE_SCHNOZ
        .word SCHNOZ.TAMANHO_STRUCT
        .word SCHNOZ.NOVO
        .word SCHNOZ.PROC
        .word SCHNOZ.DRAW
        .word SCHNOZ.COLISAO
        .word NULL_PROC

        .word ENTIDADE_JUMPER
        .word JUMPER.TAMANHO_STRUCT
        .word JUMPER.NOVO
        .word JUMPER.PROC
        .word JUMPER.DRAW
        .word JUMPER.COLISAO
        .word NULL_PROC

        .word ENTIDADE_PROJETIL_INIMIGO
        .word PROJETIL_INIMIGO.TAMANHO_STRUCT
        .word PROJETIL_INIMIGO.NOVO
        .word PROJETIL_INIMIGO.PROC
        .word PROJETIL_INIMIGO.DRAW
        .word PROJETIL_INIMIGO.COLISAO
        .word NULL_PROC

        .word ENTIDADE_BOSS
        .word BOSS.TAMANHO_STRUCT
        .word BOSS.NOVO
        .word BOSS.PROC
        .word BOSS.DRAW
        .word BOSS.COLISAO
        .word BOSS.DESTRUTOR

        .word ENTIDADE_PROJETIL_VENTO
        .word PROJETIL_VENTO.TAMANHO_STRUCT
        .word PROJETIL_VENTO.NOVO
        .word PROJETIL_VENTO.PROC
        .word PROJETIL_VENTO.DRAW
        .word PROJETIL_VENTO.COLISAO
        .word NULL_PROC

        .word ENTIDADE_POWERUP
        .word ENTIDADE_POWERUP.TAMANHO_STRUCT
        .word ENTIDADE_POWERUP.NOVO
        .word ENTIDADE_POWERUP.PROC
        .word ENTIDADE_POWERUP.DRAW
        .word ENTIDADE_POWERUP.COLISAO
        .word NULL_PROC

        .word ENTIDADE_FOGO
        .word FOGO.TAMANHO_STRUCT
        .word FOGO.NOVO
        .word FOGO.PROC
        .word FOGO.DRAW
        .word FOGO.COLISAO
        .word NULL_PROC

        .word -1 # fim

        .eqv lista_entidades.BYTES_POR_ENTRADA 28       # sao 7 words por entrada!

        # localizacao de cada atributo por entrada
        .eqv lista_entidades.TIPO_ENTRADA               0
        .eqv lista_entidades.TAMANHO_STRUCT_ENTRADA     4
        .eqv lista_entidades.PROC_DE_CRIACAO            8
        .eqv lista_entidades.PROC_POR_FRAME             12
        .eqv lista_entidades.PROC_DESENHAR              16
        .eqv lista_entidades.PROC_COLISAO               20
        .eqv lista_entidades.PROC_DESTRUTOR             24