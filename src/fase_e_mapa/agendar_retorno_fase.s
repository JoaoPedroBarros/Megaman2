# PROC_AGENDAR_RETORNO_FASE
#
# Prepara para sair da fase com um valor de retorno especifico.
#
# Argumento:
# a0 - valor de retorno
# a1 - quantos frames no futuro (0: imediatamente)
#
# Sem retornos.

.text
PROC_AGENDAR_RETORNO_FASE:
        addi sp, sp, -4
        sw ra, (sp)

        lw t0, frame_counter
        add a2, a1, t0          # (a1 original) frames no futuro
        mv a1, a0
        la a0, SUBPROC_FINALIZAR
        jal PROC_ADICIONAR_EVENTO       # agenda a execucao da subproc para retornar com o valor desejado

        lw ra, (sp)
        addi sp, sp, 4
        ret

# arg: a0 - valor
SUBPROC_FINALIZAR:
        sb a0, flagretornofase, t0
        ret