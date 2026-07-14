# PROC_CRIAR_ANIMACAO_CONTROLLER
#
# Retorna um controller de animacao dinamicamente alocado.
# Lembre-se de dar free nele quando nao for mais o utilizar!
#
# (sem argumentos)
# Retorno: a0 - ponteiro para o controller de animacao

PROC_CRIAR_ANIMACAO_CONTROLLER:
        addi sp, sp, -4
        sw ra, (sp)

        li a0, struct_animacao_controller.TAMANHO
        jal PROC_MALLOC # aloca a struct

        sw zero, struct_animacao_controller.PC(a0)
        sw zero, struct_animacao_controller.ANIMACAO(a0)
        sw zero, struct_animacao_controller.SPRITE(a0)
        sw zero, struct_animacao_controller.PALETA(a0)
        sw zero, struct_animacao_controller.FRAME(a0)
        sw zero, struct_animacao_controller.WAIT_TIMER(a0)

P_CA1_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret