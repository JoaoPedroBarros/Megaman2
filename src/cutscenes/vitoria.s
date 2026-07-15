# PROC_VITORIA
#
# Mostra a tela de game over.
#
# (SEM ARGUMENTOS, RETORNOS)

PROC_VITORIA:
        addi sp, sp, -4
        sw ra, (sp)

        # imprimir string de game over lentamente
        la a0, vitoria
        la a1, narrador1nome
        li a2, 7
        jal PROC_ADICIONAR_DIALOGO
        # imprimir opcoes 

P_VI_LOOP:
        # limpa a tela, preenchendo de branco
        li a0, 0xFF
        lw a1, FRAME_ATUAL
        seqz a1, a1     # pega o frame NAO atual (seqz 1 = 0, seqz 0 = 1)
        li a7, 148
        ecall

        mv a0,zero
        jal PROC_PROCESSAR_ENTRADAS

        lw t0, TECLA_PRESSIONADA
        li t1, 27
        beq t0, t1, P_VI_FIM
        
        jal PROC_DIALOGOS_MANAGER

        jal PROC_DESENHAR

        jal PROC_SLEEP

        j P_VI_LOOP

        lw ra, (sp)
        addi sp, sp, 4
        ret

P_VI_FIM:
        li a7, 10
        ecall