# PROC_ATUALIZA_ANIMACAO_SCHNOZ

# administra a maquina de estados do schnoz. Serah mais simples que a do jogador, visto que so tem um padrao
# de animacao

# argumentos:

# a0: struct basica do schnoz

# retornos:

# -- SEM RETORNOS --

PROC_ATUALIZAR_ANIMACAO_SCHNOZ:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lw s0, SCHNOZ.ANIMACAO_CONTROLLER(t0)

    lb t1, SCHNOZ.SPAWN(t0)
    beqz t1, P_AA2_SEM_SPAWN

P_AA2_SPAWN:

    mv a0, s0
    la a1, SCHNOZ.ANIMACAO.SPAWN
    jal PROC_DEFINIR_ANIMACAO
    j P_AA2_FIM

P_AA2_SEM_SPAWN:

    mv a0, s0
    la a1, SCHNOZ.ANIMACAO.ANDAR
    jal PROC_DEFINIR_ANIMACAO

P_AA2_FIM:
    mv a0, s0
    jal PROC_EXECUTAR_ANIMACAO

P_AA2_RET:
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret