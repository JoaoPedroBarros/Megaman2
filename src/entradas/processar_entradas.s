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

        li t0, 'V'
        beq t1, t0, P_PE1_V
        li t0, 'v'
        beq t1, t0, P_PE1_V

        li t0, 10
        beq t1, t0, P_PE1_ENTER

        li t0, 27
        beq t1, t0, P_PE1_ESC

        j P_PE1_RET

P_PE1_W:

        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        lb t1, JOGADOR.FLAG_VASSOURA(t0)

        bltz t1, JOGADOR_PULA

        lw t1, entidade.VELOCIDADE_Y_Q12(a0)
        li t0, JOGADOR.ACELERACAO_Q12
        neg t0, t0
        add t1, t0, t1
        sw t1, entidade.VELOCIDADE_Y_Q12(a0)

        j P_PE1_RET

JOGADOR_PULA:

        lw t0, entidade.NO_CHAO(a0)
        beqz t0, P_PE1_RET      # nao deixa pular se estiver no ar

        lw t1, entidade.VELOCIDADE_Y_Q12(a0)
        li t0, -13
        slli t0, t0, 12
        add t1, t0, t1
        sw t1, entidade.VELOCIDADE_Y_Q12(a0)

        j P_PE1_RET

P_PE1_A:
        lw t1, entidade.VELOCIDADE_X_Q12(a0) # caso contrario, pega o endereco do t1 e adiciona, em Q12, o movimento
        li t0, JOGADOR.ACELERACAO_Q12
        neg t0, t0
        add t1, t0, t1 # acelera
        sw t1, entidade.VELOCIDADE_X_Q12(a0) # salvando o movimento na struct

        li t0, -1
        lw t1, entidade.STRUCT_ESPECIFICA(a0)
        sb t0, JOGADOR.DIRECAO(t1)      # salva para frente

        j P_PE1_RET
P_PE1_S:

        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        lb t1, JOGADOR.FLAG_VASSOURA(t0)

        bltz t1, JOGADOR_DESCE

        lw t1, entidade.VELOCIDADE_Y_Q12(a0)
        li t0, JOGADOR.ACELERACAO_Q12
        add t1, t0, t1
        sw t1, entidade.VELOCIDADE_Y_Q12(a0)

        j P_PE1_RET

JOGADOR_DESCE:
 
        lw t0, entidade.VELOCIDADE_Y_Q12(a0)
        li t1, GRAVIDADE_PADRAO    
        add t0, t0 ,t1 	# dobra o efeito da gravidade
        sw t0, entidade.VELOCIDADE_Y_Q12(a0)

        # ativa a flag de ignorar plataforma apenas por 5 frames.
        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        li t1, 5
        sb t1, JOGADOR.TEMPORIZADOR_IGNORAR_PLATAFORMA(t0)
        
        j P_PE1_RET

P_PE1_D:
        lw t1, entidade.VELOCIDADE_X_Q12(a0) 
        li t0, JOGADOR.ACELERACAO_Q12
        add t1, t0, t1 # acelera
        sw t1, entidade.VELOCIDADE_X_Q12(a0) # salvando o movimento na struct

        li t0, 1
        lw t1, entidade.STRUCT_ESPECIFICA(a0)
        sb t0, JOGADOR.DIRECAO(t1)      # salva para frente

        j P_PE1_RET

P_PE1_ENTER:
        lw t2, entidade.STRUCT_ESPECIFICA(a0)
        lb t0, JOGADOR.COOLDOWN_PROJETIL(t2)
        li t1, 10
        bne t0, t1, P_PE1_RET

        li t0, 0
        sb t0, JOGADOR.COOLDOWN_PROJETIL(t2)
        mv s0, a0                       # guarda a entidade jogador

        lw a1, entidade.X_Q12(s0)
        srai a1, a1, 12         # corrige para inteiro
        lw a2, entidade.Y_Q12(s0)
        srai a2, a2, 12         # corrige para inteiro
        addi a1, a1, entidade.LARGURA
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

P_PE1_V:

        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        lh t1, JOGADOR.COOLDOWN_USO_VASSOURA(t0)

        bnez t1, P_PE1_RET # se o cooldown nao estiver zerado, nao deixa ativar o modo vassoura

        lb t1, JOGADOR.FLAG_VASSOURA(t0)
        sub t1, zero, t1 # caso contrario, inverte a flag da vassoura
        sb t1, JOGADOR.FLAG_VASSOURA(t0)

        li t1, 1000
        sh t1, JOGADOR.COOLDOWN_USO_VASSOURA(t0)

        li t1, 100
        sh t1, JOGADOR.TEMPO_USO_VASSOURA(t0)

        sb zero, entidade.NO_CHAO(a0)

        sw zero, entidade.VELOCIDADE_Y_Q12(a0)

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
