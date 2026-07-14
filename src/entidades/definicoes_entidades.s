# Arquivo que guarda as definicoes sobre entidades,
# como o array utilizada pela administracao de 
# cada.

# TIPOS DE ENTIDADES EM SI (sempre um numero positivo!!!)
.eqv ENTIDADE_PROJETIL_COMUM                            0
.eqv ENTIDADE_EXEMPLO                                   1
.eqv ENTIDADE_JOGADOR                                   2
.eqv ENTIDADE_SCHNOZ                                    3
.eqv ENTIDADE_JUMPER                                    4
.eqv ENTIDADE_PROJETIL_INIMIGO                          5
.eqv ENTIDADE_BOSS                                      6
.eqv ENTIDADE_PROJETIL_VENTO                            7
.eqv ENTIDADE_POWERUP                                   8
.eqv ENTIDADE_FOGO                                      9

.data

# TODO: Transformar colidivel, hostil e no_chao em flags
struct_basica_entidade:
        .eqv entidade.TIPO                              0       # tipo da entidade, que nem mais em cima
        .eqv entidade.FLAGS                             4       # flags (ver secao mais embaixo)
        .eqv entidade.X_Q12                             8       # posicao X (Fixed-point Q12!!!)
        .eqv entidade.Y_Q12                             12      # posicao Y (Fixed-point Q12!!!)
        .eqv entidade.VELOCIDADE_X_Q12                  16      # velocidade X (Fixed-point Q12!!!)
        .eqv entidade.VELOCIDADE_Y_Q12                  20      # velocidade Y (Fixed-point Q12!!!)
        .eqv entidade.HITBOX_DESLOCAMENTO_X             24      # deslocamento em X int da hitbox em pixeis (desde o canto superior esquerdo)
        .eqv entidade.HITBOX_DESLOCAMENTO_Y             28      # deslocamento em Y int da hitbox em pixeis (desde o canto superior esquerdo)
        .eqv entidade.HITBOX_LARGURA                    32      # largura da hitbox em pixeis
        .eqv entidade.HITBOX_ALTURA                     36      # altura da hitbox em pixeis
        .eqv entidade.COLIDIVEL                         40      # se a entidade colide com outras entidades
        .eqv entidade.HOSTIL                            44      # se a entidade eh hostil ao jogador
        .eqv entidade.NO_CHAO                           48      # se a entidade estah no chao atualmente ou nao (relevante
                                                                # apenas se a entidade sofrer gravidade)
        
        .eqv entidade.STRUCT_ESPECIFICA                 52       # referencia para a struct especifica da entidade

        # adicione mais atributos conforme necessario e atualize o tamanho
        
        .eqv struct_basica_entidade.TAMANHO             56      # quantidade de bytes necessaria para a struct (1 word por atr)

# aqui eh onde as referencias para cada entidade serah guardada
# 3 words por entidade:
#       - referencia ah struct basica para ela
#       - proc a ser chamada todo frame (logica de movimento, colisao, etc)
#       - proc de desenho todo frame (impressao de textura, efeitos especiais da entidade, etc)

.eqv ESPACO_ARRAY_ENTIDADES 4096
array_entidades: .byte 0:ESPACO_ARRAY_ENTIDADES   
        tamanho_array_entidades: .word 0             # quantas entidades foram registradas ateh agora
        .eqv array_entidades.BYTES_POR_ENTRADA 16       # 4 words por entrada
                                                        # importante manter o numero de bytes como multiplo de 4.

        .eqv array_entidades.STRUCT_BASICA              0
        .eqv array_entidades.PROC_POR_FRAME             4
        .eqv array_entidades.PROC_DESENHAR              8
        .eqv array_entidades.PROC_COLISAO               12

# FLAGS PARA ENTIDADES

        # 32 bits
        .eqv FLAG_ENTIDADE_IGNORAR_PLATAFORMAS  0x1             # bit 1 (0000 .. 0001)
        .eqv FLAG_ENTIDADE_DELECAO_PENDENTE     0x2             # bit 2 (0000 .. 0010)
        .eqv FLAG_EXEMPLO3                      0x4             # bit 3 (0000 .. 0100)
        .eqv FLAG_EXEMPLO4                      0x8             # bit 4 (0000 .. 1000)
        #...
        .eqv FLAG_EXEMPLO32                     0x80000000      # bit 32 (1000 .. 0000)