# PROC_PROCESSAR_ENTRADAS
# administra entradas do usuario no teclado
# (sem argumentos)

PROC_PROCESSAR_ENTRADAS:
        li      t0, KDMMIO_Ctrl
        lw     	t1, 0(t0)   			# le o bit de flag do teclado
        andi 	t1, t1, 0x0001			# mascara bit 0
        beqz    t1, P_PE1_RET             	# nenhuma tecla precionada - termina
        lw 	t1, 4(t0)			# le o ascii da tecla pressionada

        li t0, 'W'
        beq t1, t0, P_PE1_W
        li t0, 'w'
        beq t1, t0, P_PE1_W

        li t0, 'A'
        beq t1, t0, P_PE1_A
        li t0, 'a'
        beq t1, t0, P_PE1_A

        li t0, 'S'
        beq t1, t0, P_PE1_S
        li t0, 's'
        beq t1, t0, P_PE1_S

        li t0, 'D'
        beq t1, t0, P_PE1_D
        li t0, 'd'
        beq t1, t0, P_PE1_D

        li t0, 27
        beq t1, t0, P_PE1_ESC

        j P_PE1_RET

P_PE1_W:
        la t0, jogador
        lw t1, jogador_y(t0)
        addi t1, t1, -10
        sw t1, jogador_y(t0)
        j P_PE1_RET

P_PE1_A:
        la t0, jogador
        lw t1, jogador_x(t0)
        addi t1, t1, -10
        sw t1, jogador_x(t0)
        j P_PE1_RET

P_PE1_S:
        la t0, jogador
        lw t1, jogador_y(t0)
        addi t1, t1, 10
        sw t1, jogador_y(t0)
        j P_PE1_RET

P_PE1_D:
        la t0, jogador
        lw t1, jogador_x(t0)
        addi t1, t1, 10
        sw t1, jogador_x(t0)
        j P_PE1_RET

P_PE1_ESC:
        # termina execucao
        li a7, 10
        ecall

P_PE1_RET:
        ret
