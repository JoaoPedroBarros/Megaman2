# PROC_PROCESSAR_ENTRADAS
# administra entradas do usuario no teclado
# Argumentos: a0 - entidade jogador

PROC_PROCESSAR_ENTRADAS:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)

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

        li t0, 10
        beq t1, t0, P_PE1_ENTER

        li t0, 27
        beq t1, t0, P_PE1_ESC

        j P_PE1_RET

P_PE1_W:
        lw t1, entidade.Y(a0)
        addi t1, t1, -4
        sw t1, entidade.Y(a0)

        j P_PE1_RET

P_PE1_A:
        lw t1, entidade.X(a0)
        addi t1, t1, -4
        sw t1, entidade.X(a0)

        lw t1, entidade.STRUCT_ESPECIFICA(a0)
        li t0, -1
        sb t0, JOGADOR.DIRECAO(t1)      # salva para tras

        j P_PE1_RET

P_PE1_S:
        lw t1, entidade.Y(a0)
        addi t1, t1, 4
        sw t1, entidade.Y(a0)

        j P_PE1_RET

P_PE1_D:
        lw t1, entidade.X(a0)
        addi t1, t1, 4
        sw t1, entidade.X(a0)

        li t0, 1
        lw t1, entidade.STRUCT_ESPECIFICA(a0)
        sb t0, JOGADOR.DIRECAO(t1)      # salva para frente

        j P_PE1_RET

P_PE1_ENTER:
        mv s0, a0                       # guarda a entidade jogador

        lw a1, entidade.X(s0)
        lw a2, entidade.Y(s0)
        li a0, ENTIDADE_PROJETIL_COMUM
        jal PROC_ADICIONAR_ENTIDADE

        # a0 - entidade 
        li a1, 10
        lw t0, entidade.STRUCT_ESPECIFICA(s0)
        lb t1, JOGADOR.DIRECAO(t0)
        MULTIPLY (a1, a1, t1)           
        jal PROJETIL_COMUM.SET_VELOCIDADE_X

        j P_PE1_RET

P_PE1_ESC:
        # termina execucao
        li a7, 10
        ecall

P_PE1_RET:
        lw ra, (sp)
        sw s0, 4(sp)
        addi sp, sp, 8
        ret
