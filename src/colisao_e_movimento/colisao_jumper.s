# procedimentos para controlar colisao do jumper. Bem simples, basta analisar a coordenada futura e cortar a velocidade caso
# seja identificada uma colisao. Por isso, eh apenas um metodo.

# ARGUMENTOS

# a0 - struct basica do jumper

# RETORNO

# nao ha retornos obrigatorios: o tratamento de velocidade serah abordado neste metodo

PROC_COLISAO_JUMPER:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    lw t0, entidade.VELOCIDADE_X_Q12(a0)
    lw t1, entidade.X_Q12(a0)

    mv s0, a0 # mantem referencia a struct basica

    srai t0, t0, 12
    srai t1, t1, 12

    add a0, t0, t1

    lw t0, entidade.VELOCIDADE_Y_Q12(s0)
    lw t1, entidade.Y_Q12(s0)

    srai t0, t0, 12
    srai t1, t1, 12

    add a1, t0, t1

    jal CALCULA_TILE

    li t0, 1
    beq a0, t0, COLISAO_JUMPER_RET

    sw zero, entidade.VELOCIDADE_X_Q12(s0)
    sw zero, entidade.VELOCIDADE_Y_Q12(s0) # zera ambas as velocidades

COLISAO_JUMPER_RET:

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret