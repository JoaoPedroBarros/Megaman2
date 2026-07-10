# metodos de animacao de jogador

# PARAMETROS

# a0 - struct do jogador

# RETORNO

# a0 - referencia pro sprite escolhido

# os procedimentos a seguir modificam, a depender da passagem do gameloop, para qual sprite esta apontando.

PROC_ANIMACAO_JOGADOR:

    lw t0, entidade.STRUCT_ESPECIFICA(a0)

    lb t1, JOGADOR.FLAG_VASSOURA(t0)
    bgtz t1, RETORNA_SPRITE_VASSOURA_JOGADOR

    lb t1, JOGADOR.COOLDOWN_PROJETIL(t0)
    li t2, 10
    bne t1, t2, RETORNA_SPRITE_ATIRANDO_JOGADOR

    lw t1, entidade.VELOCIDADE_Y_Q12(a0)
    

    lw t1, entidade.VELOCIDADE_X_Q12(a0)
    bnez t1, RETORNA_SPRITE_MOVIMENTACAO_JOGADOR

    j RETORNA_SPRITE_IDLE_JOGADOR

RETORNA_SPRITE_VASSOURA_JOGADOR:

    la a0, sprite_bruxa_voando
    j PROC_ANIMACAO_JOGADOR_RET

RETORNA_SPRITE_ATIRANDO_JOGADOR:

    la a0, sprite_bruxa_feitico5
    j PROC_ANIMACAO_JOGADOR_RET

RETORNA_SPRITE_MOVIMENTACAO_JOGADOR:

    lb t1, JOGADOR.MARCADOR_ANIMACAO(t0)

    lb t2, JOGADOR.COOLDOWN_MOVIMENTACAO(t0)
    bnez t2, SEM_CORRECAO_MARCADOR_ANIMACAO

    li t2, 12
    sb t2, JOGADOR.COOLDOWN_MOVIMENTACAO(t0)

    addi t1, t1, 1

    li t2, 3
    ble t1, t2, SEM_CORRECAO_MARCADOR_ANIMACAO
    mv t1, zero

SEM_CORRECAO_MARCADOR_ANIMACAO:

    sb t1, JOGADOR.MARCADOR_ANIMACAO(t0)

    addi t2, t2, -1
    sb t2, JOGADOR.COOLDOWN_MOVIMENTACAO(t0)

    la a0, sprite_bruxa_andando1
    li t2, 1024
    mul t2, t1, t2
    add a0, a0, t2

    j PROC_ANIMACAO_JOGADOR_RET

RETORNA_SPRITE_IDLE_JOGADOR:

    la a0, sprite_bruxa_feitico1

PROC_ANIMACAO_JOGADOR_RET:

    ret

