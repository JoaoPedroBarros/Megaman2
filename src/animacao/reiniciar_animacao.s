# PROC_REINICIAR_ANIMACAO
#
# Muda para uma animacao incondicionalmente.
#
# Argumentos:
# a0 - controller de animacao
# a1 - animacao para mudar

PROC_REINICIAR_ANIMACAO:
        sw a1, struct_animacao_controller.ANIMACAO(a0)
        sw a1, struct_animacao_controller.PC(a0)
        sw zero, struct_animacao_controller.WAIT_TIMER(a0)
P_RA1_RET:
        ret