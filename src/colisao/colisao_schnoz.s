# o schnoz tera uma colisao basica: pegarah, a cada gameloop, o bloco da frente e o segundo inferior. Isso serve
# para garantir que ele nao se matarah em buracos, mas ainda podendo cair pequenas alturas. Caso for identificada 
# alguma colisao, basta inverter a velocidade.

## ARGUMENTOS ##

# a0 - struct basica do schnoz

## RETORNO ##

# SEM RETORNOS - o proprio procedimento trata a inversao de valores do schnoz

PROC_COLISAO_SCHNOZ:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0 # sempre manter a referencia pra struct basica do schnoz

    # a seguir, calcular a tile a frente e a segunda abaixo dela.

    lw a0, entidade.X_Q12(s0)
    lw a1, entidade.Y_Q12(s0)
    lw t0, entidade.STRUCT_ESPECIFICA(s0)

    lb t0, SCHNOZ.DIRECAO(t0)

    srai a0, a0, 12
    srai a1, a1, 12

    blt t0, zero, AJUSTA_SCHNOZ_ESQUERDA
    addi a0, a0, 32

AJUSTA_SCHNOZ_ESQUERDA:

    jal CALCULA_TILE

    beq a0, zero, INVERTE_SCHNOZ
    li t0, 2
    beq a0, t0, INVERTE_SCHNOZ
    li t0, 9
    beq a0, t0, INVERTE_SCHNOZ

    lw a0, entidade.X_Q12(s0)
    lw a1, entidade.Y_Q12(s0)
    lb t0, SCHNOZ.DIRECAO(s0)

    srai a0, a0, 12
    srai a1, a1, 12

    blt t0, zero, AJUSTA_SCHNOZ_ESQUERDA_BAIXO
    addi a0, a0, 32

AJUSTA_SCHNOZ_ESQUERDA_BAIXO:

    addi a1, a1, 64

    jal CALCULA_TILE

    li t0, 1
    beq a0, t0, INVERTE_SCHNOZ
    j RETURN_COLISAO_SCHNOZ

INVERTE_SCHNOZ:

    lw t0, entidade.STRUCT_ESPECIFICA(s0)
    lw t1, entidade.VELOCIDADE_X_Q12(s0)
    lb t2, SCHNOZ.DIRECAO(t0)

    neg t1, t1
    neg t2, t2

    sb t2, SCHNOZ.DIRECAO(t0)
    sw t1, entidade.VELOCIDADE_X_Q12(s0)
    j RETURN_COLISAO_SCHNOZ

RETURN_COLISAO_SCHNOZ:

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret
    











