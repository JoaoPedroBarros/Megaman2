# PROC_DEFINIR_ANIMACAO
#
# Muda para uma animacao se ela jah nao estah
# ativa.
#
# Argumentos:
# a0 - controller de animacao
# a1 - animacao para mudar

PROC_DEFINIR_ANIMACAO:
        lw t0, struct_animacao_controller.ANIMACAO(a0)
        beq t0, a1, P_DA1_RET
        sw a1, struct_animacao_controller.ANIMACAO(a0)
        sw a1, struct_animacao_controller.PC(a0)
        sw zero, struct_animacao_controller.WAIT_TIMER(a0)
P_DA1_RET:
        ret