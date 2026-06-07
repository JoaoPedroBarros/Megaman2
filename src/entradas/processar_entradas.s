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
        beqz    t1, P_PE1_SEM_TECLA             # nenhuma tecla precionada - termina
        lw 	t1, 4(t0)			# le o ascii da tecla pressionada

        sw t1, TECLA_PRESSIONADA, t0            # salva a tecla!

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
        lw t0, entidade.NO_CHAO(a0)
        safe_print_int_ln(t0)
        beqz t0, P_PE1_RET      # nao deixa pular se estiver no ar

        lw t1, entidade.VELOCIDADE_Y_Q12(a0)
        li t0, -10
        slli t0, t0, 12
        add t1, t0, t1
        sw t1, entidade.VELOCIDADE_Y_Q12(a0)
        sw zero, entidade.NO_CHAO(a0)

        j P_PE1_RET

P_PE1_A:
        addi sp, sp, -8
        sw a0, 0(sp) # guarda a referencia pra entidade basica
        sw ra, 4(sp) # return adress

        jal PROC_COLISAO_MAPA_ESQUERDA 
        mv t0, a0 # move o resultado do procedimento pra t0
        lw a0, 0(sp) # restaura a entidade basica
        lw ra, 4(sp) # restaura o return adress
        addi sp, sp, 8

        beq t0, zero, SEM_MOVIMENTO_ESQUERDA # se t0 for 0, identificou uma colisao: nao move

        lw t1, entidade.X_Q12(a0) # caso contrario, pega o endereco do t1 e adiciona, em Q12, o movimento
        li t0, -4 # quantidade do movimento
        slli t0, t0, 12 # colocando o t0 em Q12
        add t1, t0, t1 # adicionando o movimento
        sw t1, entidade.X_Q12(a0) # salvando o movimento na struct

SEM_MOVIMENTO_ESQUERDA:

        li t0, -1
        lw t1, entidade.STRUCT_ESPECIFICA(a0)
        sb t0, JOGADOR.DIRECAO(t1)      # salva para frente

        j P_PE1_RET

P_PE1_S:
        # oq?
        j P_PE1_RET

P_PE1_D:
        addi sp, sp, -8
        sw a0, 0(sp) # guarda a referencia pra entidade basica
        sw ra, 4(sp) # return adress

        jal PROC_COLISAO_MAPA_DIREITA 
        mv t0, a0 # move o resultado do procedimento pra t0
        lw a0, 0(sp) # restaura a entidade basica
        lw ra, 4(sp) # restaura o return adress
        addi sp, sp, 8

        beq t0, zero, SEM_MOVIMENTO_DIREITA # se t0 for 0, identificou uma colisao: nao move

        lw t1, entidade.X_Q12(a0) # caso contrario, pega o endereco do t1 e adiciona, em Q12, o movimento
        li t0, 4 # quantidade do movimento
        slli t0, t0, 12 # colocando o t0 em Q12
        add t1, t0, t1 # adicionando o movimento
        sw t1, entidade.X_Q12(a0) # salvando o movimento na struct

SEM_MOVIMENTO_DIREITA:

        li t0, 1
        lw t1, entidade.STRUCT_ESPECIFICA(a0)
        sb t0, JOGADOR.DIRECAO(t1)      # salva para frente

        j P_PE1_RET

P_PE1_ENTER:
        lb t0, JOGADOR.COOLDOWN_PROJETIL(a0)
        li t1, 10
        bne t0, t1, P_PE1_RET

        li t0, 0
        sb t0, JOGADOR.COOLDOWN_PROJETIL(a0)
        mv s0, a0                       # guarda a entidade jogador

        lw a1, entidade.X_Q12(s0)
        srai a1, a1, 12         # corrige para inteiro
        lw a2, entidade.Y_Q12(s0)
        srai a2, a2, 12         # corrige para inteiro
        li a0, ENTIDADE_PROJETIL_COMUM
        jal PROC_ADICIONAR_ENTIDADE

        # a0 - entidade 
        li a1, 10 # velocidade inteira
        slli a1, a1, 12 # para q12

        lw t0, entidade.STRUCT_ESPECIFICA(s0)
        lb t1, JOGADOR.DIRECAO(t0)
        MULTIPLY (a1, a1, t1)           
        jal PROJETIL_COMUM.SET_VELOCIDADE_X

        j P_PE1_RET

P_PE1_ESC:
        # termina execucao
        li a7, 10
        ecall

P_PE1_SEM_TECLA:
        sw zero, TECLA_PRESSIONADA, t0

P_PE1_RET:
        lw ra, (sp)
        sw s0, 4(sp)
        addi sp, sp, 8
        ret
