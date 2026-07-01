# lista_entidades
# onde a lista de entidades eh guardada.

# (tipos de entidade em definicoes_entidades.s)

.data

lista_entidades:
        # tipo, tamanho, funcao de criacao, funcao por frame, funcao de desenhar, funcao de colisao
        .word ENTIDADE_PROJETIL_COMUM,        
        .word PROJETIL_COMUM.TAMANHO_STRUCT
        .word PROJETIL_COMUM.NOVO
        .word PROJETIL_COMUM.PROC
        .word PROJETIL_COMUM.DRAW
        .word PROJETIL_COMUM.COLISAO

        .word ENTIDADE_EXEMPLO
        .word EXEMPLO.TAMANHO_STRUCT
        .word EXEMPLO.NOVO
        .word EXEMPLO.PROC
        .word EXEMPLO.DRAW
        .word NULL_PROC

        .word ENTIDADE_JOGADOR
        .word JOGADOR.TAMANHO_STRUCT
        .word JOGADOR.NOVO
        .word JOGADOR.PROC
        .word JOGADOR.DRAW
        .word NULL_PROC

        .word ENTIDADE_SCHNOZ
        .word SCHNOZ.TAMANHO_STRUCT
        .word SCHNOZ.NOVO
        .word SCHNOZ.PROC
        .word SCHNOZ.DRAW
        .word SCHNOZ.COLISAO

        .word ENTIDADE_JUMPER
        .word JUMPER.TAMANHO_STRUCT
        .word JUMPER.NOVO
        .word JUMPER.PROC
        .word JUMPER.DRAW
        .word JUMPER.PULA

        .word ENTIDADE_PROJETIL_INIMIGO,
        .word PROJETIL_INIMIGO.TAMANHO_STRUCT
        .word PROJETIL_INIMIGO.NOVO
        .word PROJETIL_INIMIGO.PROC
        .word PROJETIL_INIMIGO.DRAW

        .word -1 # fim

        .eqv lista_entidades.BYTES_POR_ENTRADA 24       # sao 6 words por entrada!

        # localizacao de cada atributo por entrada
        .eqv lista_entidades.TIPO_ENTRADA               0
        .eqv lista_entidades.TAMANHO_STRUCT_ENTRADA     4
        .eqv lista_entidades.PROC_DE_CRIACAO            8
        .eqv lista_entidades.PROC_POR_FRAME             12
        .eqv lista_entidades.PROC_DESENHAR              16
        .eqv lista_entidades.PROC_COLISAO               20