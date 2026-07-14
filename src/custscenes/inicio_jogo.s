# PROC_FASE: roda o jogo
# (sem argumentos e retorno)

.data

    TITULO_JOGO: .asciz "FLORA, THE WITCH"
    INICIAR_JOGO: .asciz "1 - Iniciar jogo"
    SAIR_JOGO:  .asciz "ESC - Sair do Jogo"

.text

PROC_MENU:
        addi sp, sp, -4
        sw ra, (sp)

        la a0, narrador1monologo
        la a1, narrador1nome
        li a2, 2
        jal PROC_ADICIONAR_DIALOGO

        la a0, narrador2monologo
        la a1, narrador1nome
        li a2, 2
        jal PROC_ADICIONAR_DIALOGO

        la a0, narrador3monologo
        la a1, narrador1nome
        li a2, 2
        jal PROC_ADICIONAR_DIALOGO

P_MENU_LOOP:
        li a0, 0x00
        lw a1, FRAME_ATUAL
        seqz a1, a1
        li a7, 148
        ecall

        jal PROC_DIALOGOS_MANAGER
        
        mv a0, zero
        jal PROC_PROCESSAR_ENTRADAS

        jal PROC_DESENHAR

        la a0, TITULO_JOGO
        li a1, 103
        li a2, 120
        li a3, 0x14
        lw a4, FRAME_ATUAL
        li a7, 104
        ecall

        la a0, INICIAR_JOGO
        li a1, 103
        li a2, 160
        li a3, 0xFF
        lw a4, FRAME_ATUAL
        li a7, 104
        ecall

        la a0, SAIR_JOGO
        li a1, 97
        li a2, 180
        li a3, 0xFF
        lw a4, FRAME_ATUAL
        li a7, 104
        ecall

        la t0, frame_counter
        lw t1, (t0)
        addi t1, t1, 1
        sw t1, (t0)                             

        jal PROC_SLEEP

        j P_MENU_LOOP

        lw ra, (sp)
        addi sp, sp, 4
        ret

