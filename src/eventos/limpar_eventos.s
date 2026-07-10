# PROC_LIMPAR_EVENTOS
#
# Apaga todos os eventos existentes.
#
# (sem argumentos, retornos)

PROC_LIMPAR_EVENTOS:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        la s0, array_eventos
        lw t0, qtd_de_eventos
        slli t0, t0, 2
        add s1, t0, s0
P_LE1_FOR_LOOP:                 # for (Evento** e = &eventos[0]; e < &eventos[qtd_de_eventos]; e++) free(*e);
                bge s0, s1, P_LE1_FOR_LOOP_FIM

                lw a0, (s0)
                jal PROC_FREE

                addi s0, s0, 4
                j P_LE1_FOR_LOOP
P_LE1_FOR_LOOP_FIM:
        sw zero, qtd_de_eventos, t0     # qtd_de_eventos = 0;

P_LE1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret

#. for (Evento** e : eventos) free(*e);
#. qtd_de_eventos = 0;