# lista_entidades
# onde a lista de entidades eh guardada.

# (tipos de entidade em definicoes_entidades.s)

.data

lista_entidades:
        # tipo, tamanho, funcao de criacao, funcao por frame, funcao de desenhar
        .word ENTIDADE_PROJETIL_COMUM,        
        .word PROJETIL_COMUM.TAMANHO_STRUCT
        .word PROJETIL_COMUM.NOVO
        .word PROJETIL_COMUM.PROC
        .word PROJETIL_COMUM.DRAW

        .word ENTIDADE_EXEMPLO
        .word EXEMPLO.TAMANHO_STRUCT
        .word EXEMPLO.NOVO
        .word EXEMPLO.PROC
        .word EXEMPLO.DRAW

        .word ENTIDADE_JOGADOR
        .word JOGADOR.TAMANHO_STRUCT
        .word JOGADOR.NOVO
        .word JOGADOR.PROC
        .word JOGADOR.DRAW

        .word -1 # fim

        .eqv lista_entidades.BYTES_POR_ENTRADA 20       # sao 5 words por entrada!

        # localizacao de cada atributo por entrada
        .eqv lista_entidades.TIPO_ENTRADA               0
        .eqv lista_entidades.TAMANHO_STRUCT_ENTRADA     4
        .eqv lista_entidades.PROC_DE_CRIACAO            8
        .eqv lista_entidades.PROC_POR_FRAME             12
        .eqv lista_entidades.PROC_DESENHAR              16