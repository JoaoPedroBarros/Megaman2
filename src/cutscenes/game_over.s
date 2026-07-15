# PROC_GAME_OVER
#
# Mostra a tela de game over.
#
# (SEM ARGUMENTOS, RETORNOS)

.data

REINICIAR_STR: .asciz "1. Reiniciar"

SAIR_STR: .asciz "ESC. Sair"

.text

PROC_GAME_OVER:
        addi sp, sp, -4
        sw ra, (sp)

        # imprimir string de game over lentamente
        la a0, gameover
        la a1, narrador1nome
        li a2, 5
        jal PROC_ADICIONAR_DIALOGO
        # imprimir opcoes 

P_GO1_LOOP:
        # limpa a tela, preenchendo de preto
        li a0, 0x00
        lw a1, FRAME_ATUAL
        seqz a1, a1     # pega o frame NAO atual (seqz 1 = 0, seqz 0 = 1)
        li a7, 148
        ecall

        li a0, 0
        jal PROC_PROCESSAR_ENTRADAS

        lw t0, TECLA_PRESSIONADA
        li t1, '1'
        beq t0, t1, P_GO_REINICIAR
        li t1, 27
        beq t0, t1, P_GO_FIM

        la a0, REINICIAR_STR
        li a1, 103
        li a2, 120
        li a3, 0xFF
        jal PROC_IMPRIMIR_STRING

        la a0, SAIR_STR
        li a1, 103
        li a2, 160
        li a3, 0xFF
        jal PROC_IMPRIMIR_STRING

        jal PROC_DIALOGOS_MANAGER

        jal PROC_DESENHAR

        jal PROC_SLEEP

        j P_GO1_LOOP

P_GO_REINICIAR:
        lw ra, (sp)
        addi sp, sp, 4
        ret

P_GO_FIM:
        li a7, 10
        ecall