# Arquivo que guarda as definicoes sobre entidades,
# como a tabela utilizada pela administracao de 
# cada.

# TIPOS DE ENTIDADES EM SI (sempre um numero positivo!!!)
.eqv ENTIDADE_PROJETIL_COMUM                            0
#.eqv ENTIDADE_EXEMPLO                                  1

.data

lista_entidades:
        # tipo, tamanho, funcao de criacao, funcao por frame, funcao de desenhar
        .word ENTIDADE_PROJETIL_COMUM,        
        .word PROJETIL_COMUM.TAMANHO_STRUCT
        .word PROJETIL_COMUM.NOVO
        .word PROJETIL_COMUM.PROC
        .word PROJETIL_COMUM.DRAW

        #.word ENTIDADE_EXEMPLO
        #.word EXEMPLO.TAMANHO_STRUCT
        #.word EXEMPLO.NOVO
        #.word EXEMPLO.PROC
        #.word EXEMPLO.DRAW

        .word -1 # fim

        .eqv lista_entidades.BYTES_POR_ENTRADA 20       # sao 5 words por entrada!

        # localizacao de cada atributo por entrada
        .eqv lista_entidades.TIPO_ENTRADA               0
        .eqv lista_entidades.TAMANHO_STRUCT_ENTRADA     4
        .eqv lista_entidades.PROC_DE_CRIACAO            8
        .eqv lista_entidades.PROC_POR_FRAME             12
        .eqv lista_entidades.PROC_DESENHAR              16

struct_basica_entidade:
        .eqv entidade.STRUCT_ESPECIFICA                 0       # referencia para a struct especifica da entidade
        .eqv entidade.X                                 4       # posicao X
        .eqv entidade.Y                                 8       # posicao Y
        .eqv entidade.LARGURA                           12      # largura em pixeis
        .eqv entidade.ALTURA                            16      # altura em pixeis
        .eqv entidade.COLIDIVEL                         20      # se a entidade colide com o jogador e projeteis
        .eqv entidade.HOSTIL                            24      # se a entidade eh hostil ao jogador
        # adicione mais atributos conforme necessario e atualize o tamanho
        
        .eqv struct_basica_entidade.TAMANHO             28      # quantidade de bytes necessaria por atributo (1 word por atr)

# aqui eh onde as referencias para cada entidade serah guardada
# 3 words por entidade:
#       - referencia ah struct basica para ela
#       - proc a ser chamada todo frame (logica de movimento, colisao, etc)
#       - proc de desenho todo frame (impressao de textura, efeitos especiais da entidade, etc)
array_entidades: .space 1024   
        array_quantidade_entidades: .word 0             # quantas entidades foram registradas ateh agora
        .eqv array_entidades.BYTES_POR_ENTRADA 12       # 3 words por entrada

        .eqv array_entidades.STRUCT_BASICA              0
        .eqv array_entidades.PROC_POR_FRAME             4
        .eqv array_entidades.PROC_DESENHAR              8