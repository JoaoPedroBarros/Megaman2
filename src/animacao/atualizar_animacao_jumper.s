# PROC_ATUALIZA_ANIMACAO_JUMPER

# administra a maquina de estados do Jumper. A mais simples, visto que soh tem 3 sprites, jah contando com o spawn

# argumentos:

# a0: struct basica do jumper

# retornos:

# -- SEM RETORNOS --

PROC_ATUALIZAR_ANIMACAO_JUMPER:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lw s0, JUMPER.ANIMACAO_CONTROLLER(t0)

    lb t1, JUMPER.SPAWN(t0)
    beqz t1, P_AAJ_SEM_SPAWN

P_AAJ_SPAWN:

    mv a0, s0
    la a1, JUMPER.ANIMACAO.SPAWN
    jal PROC_DEFINIR_ANIMACAO
    j P_AAJ_FIM

P_AAJ_SEM_SPAWN:

    mv a0, s0
    la a1, JUMPER.ANIMACAO.PULO
    jal PROC_DEFINIR_ANIMACAO

P_AAJ_FIM:
    mv a0, s0
    jal PROC_EXECUTAR_ANIMACAO

P_AAJ_RET:
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret