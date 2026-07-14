# procedimento que analisa se a entidade saiu da tela do jogador. Para isso, compara com a coordenada do jogador
# e ve se a diferenca em modulo eh maior que a resolucao/2 + offset (polimento visual).

# ARGUMENTOS - 

# a0 - struct basica do inimigo

# RETORNO -

# a0 - 0 se inimigo deve ser reciclado (mostra que a entidade morreu), 1 caso contrario

PROC_RECICLA_ENTIDADE:

    la t0, jogador
    lw t0, 0(t0)

    lw t1, entidade.X_Q12(t0)
    lw t2, entidade.Y_Q12(t0)

    srai t1, t1, 12
    srai t2, t2, 12

    lw t3, entidade.X_Q12(a0)
    lw t4, entidade.Y_Q12(a0)

    srai t3, t3, 12
    srai t4, t4, 12

    li t5, 180
    li t6, 140

    sub t1, t1, t3
    bgtz t1, P_RE_CORRIGE_X
    sub t1, zero, t1

P_RE_CORRIGE_X: 

    bgt t1, t5, P_RE_MATA_ENTIDADE

    sub t2, t2, t4
    bgtz t2, P_RE_CORRIGE_Y
    sub t2, zero, t2

P_RE_CORRIGE_Y:

    bgt t2, t6, P_RE_MATA_ENTIDADE

    li a0, 1
    j P_RE_RET

P_RE_MATA_ENTIDADE:

    li a0, 0

    la t0, MONSTER_CONTROLLER
    lb t1, 0(t0)
    addi t1, t1, -1
    sb t1, 0(t0)

P_RE_RET:

    ret

    