# PROC_IMPRIMIR_TEXTURA_CI4
#
# Imprime uma textura comprimida com index de 4 bits
# dado uma paleta. 
#
# Argumentos:
#       a0 - endereco da textura
#       a1 - pos x
#       a2 - pos y
#       a3 - numero de linhas da textura
#       a4 - numero de colunas da textura
#       a5 = endereco do arquivo de paleta

PROC_IMPRIMIR_TEXTURA_CI4: 	
                        addi sp, sp, -4
                        sw s0, (sp)

			# primeiro checamos se a textura nao estah completamente invisivel
			li t0, LARGURA_VGA
			li t1, ALTURA_VGA
			bge a1, t0, P_IT4_FIM
			bge a2, t1, P_IT4_FIM
                        add t2, a1, a4
                        bltz t2, P_IT4_FIM
                        add t2, a2, a3
                        bltz t2, P_IT4_FIM

                        # checagem para ver se a textura vai estar completamente visivel
                        slt t2, a1, zero        # t2 = X < 0
                        slt t3, a2, zero        # t3 = Y < 0

                        add t4, a1, a4
                        slt t4, t4, t0          # t4 = X + C < LARGURA

                        add t5, a2, a3
                        slt t5, t5, t1          # t5 = Y + L < ALTURA

                        or t2, t2, t3
                        not t2, t2
                        and t4, t4, t5
                        and t2, t2, t4          # (X >= 0 && Y >= 0 && X < LARGURA && Y < ALTURA)
                        
			la t3, FRAME_BUFFER_PTR
			lw t3, (t3)	

			li t0, LARGURA_VGA		# t0 = LVGA (largura VGA) // largura do buffer
			MULTIPLY(t0, a2, t0)		# t0 = pL = Y * LVGA
			add t0, t0, a1			# t0 = pL + X
			add t3, t3, t0			# BUFFER += pL + X, indo pra posicao em que queremos imprimir

                        addi s0, a5, 8                  # pega o endereco da paleta, sem as words de dimensao
			
# t3 = P  = endereco do pixel vga atual
# a0 = E  = endereco do pixel textura atual
# t0 = I  = informacao do pixel de textura atual
# a1 = X
# a2 = Y
# t4 = X_limite
# t5 = Y_limite

# t6 = cor transparente

# a5 = Comeco da tela (endereco minimo para impressao)
# a6 = Fim da tela    (endereco maximo para impressao)
# a7 = X_limite_tela  (X minimo para estar fora da tela)

# s0 = endereco de paleta
			
			add t4, a1, a4
                        add t5, a2, a3
			li t6, COR_TRANSPARENTE		# t6 = COR_TRANSPARENTE

                        lw a5, FRAME_BUFFER_PTR
                        lw a6, FRAME_BUFFER_FIM_PTR

			li a7, LARGURA_VGA
			
                        bnez t2, P_IT4_LOOP_RAPIDO      # se a textura estah COMPLETAMENTE VISIVEL, vamos pro loop rapido
			j P_IT4_LOOP			# senao, vai pro loop normal
			
P_IT4_PROXIMA_LINHA:    
			sub t1, a4, a7 			# t1 = -320+C -- lembre-se que a tela eh 240 por 320!
			neg t1, t1			# t1 = 320-C

			add t3, t3, t1			# E += 320-C (t6)

			addi a2, a2, 1 			# Y++
			sub a1, a1, a4			# volta X
				
			# SE Y == Y_MAX: SAI DO LOOP
			beq a2, t5, P_IT4_FIM
			
P_IT4_LOOP:		lbu t0, (a0)			# coloca a informacao do pixel em I (I = informacao em P)

P_IT4_NIBBLE1:
                        srli t1, t0, 4                  # pega parte 1
			
                        blt t3, a5, P_IT4_NIBBLE2 	# SE (P < MINIMO), PULA O PIXEL
                        bge t3, a6, P_IT4_NIBBLE2       # SENAO SE (P >= MAXIMO), TERMINA IMPRESSAO
			bltz a1,    P_IT4_NIBBLE2	# SENAO SE (X < 0), PULA O PIXEL
                        bge a1, a7, P_IT4_NIBBLE2       # SENAO SE (X >= X_LIMITE), PULA O PIXEL
                        add t1, s0, t1
                        lbu t1,  (t1)                    # carrega o idx da paleta
			beq t1, t6, P_IT4_NIBBLE2	# SENAO SE ( I == COR_TRANSPARENTE ), PULA O PIXEL
                                                        # SENAO:
			sb t1,	(t3)			# 	imprime o pixel

P_IT4_NIBBLE2:
                        addi t3, t3, 1			# P++ 
			addi a1, a1, 1			# X++ 
                        andi t1, t0, 0x0F               # pega parte 2
                        blt t3, a5, P_IT4_PULA 	        # SE (P < MINIMO), PULA O PIXEL
                        bge t3, a6, P_IT4_PULA          # SENAO SE (P >= MAXIMO), TERMINA IMPRESSAO
			bltz a1,    P_IT4_PULA	        # SENAO SE (X < 0), PULA O PIXEL
                        bge a1, a7, P_IT4_PULA         # SENAO SE (X >= X_LIMITE), PULA O PIXEL
                        add t1, s0, t1
                        lbu t1,  (t1)                    # carrega o idx da paleta
			beq t1, t6, P_IT4_PULA	        # SENAO SE ( I == COR_TRANSPARENTE ), PULA O PIXEL
                                                        # SENAO:
                        sb t1, (t3)

P_IT4_PULA:	        addi a0, a0, 1			# E++
			addi t3, t3, 1			# P++ 
			addi a1, a1, 1			# X++ 
			
			# SE X == X_limite, VAI PARA A PROXIMA LINHA
			bne a1, t4, P_IT4_LOOP
			j P_IT4_PROXIMA_LINHA



P_IT4_PROXIMA_LINHA_RAPIDO:    
			add t3, t3, a7                  # avanca LARGURA_VGA (1 linha inteira) 
                        sub t3, t3, a4                  # recua a qtd de colunas da textura
                                                        # avancamos 320-C, pulando pra posicao inicial de impressao, mas na 
                                                        # linha de baixo.

			addi a2, a2, 1 			# Y++
			sub a1, a1, a4			# volta X
				
			# SE Y == Y_MAX: SAI DO LOOP
			beq a2, t5, P_IT4_FIM
			
P_IT4_LOOP_RAPIDO:	lbu t0, (a0)			# coloca a informacao do pixel em I (I = informacao em P)
			
P_IT4_NIBBLE1_R:        srli t1, t0, 4
                        
                        add t1, s0, t1
                        lbu t1, (t1)
                        
			beq t1, t6, P_IT4_NIBBLE2_R# SE ( I == COR_TRANSPARENTE ), PULA O PIXEL
                                                        # SENAO:
			sb t1,	(t3)			# 	imprime o pixel
P_IT4_NIBBLE2_R:
                        addi t3, t3, 1			# P++ 
			addi a1, a1, 1			# X++ 
                        andi t1, t0, 0x0F
                        add t1, s0, t1
                        lbu t1, (t1)
                        beq t1, t6, P_IT4_PULA_PIXEL_RAPIDO
                        sb t1, (t3)

P_IT4_PULA_PIXEL_RAPIDO:addi a0, a0, 1			# E++
			addi t3, t3, 1			# P++ 
			addi a1, a1, 1			# X++ 
			
			bne a1, t4, P_IT4_LOOP_RAPIDO
			# SE X == X_limite, VAI PARA A PROXIMA LINHA
			j P_IT4_PROXIMA_LINHA_RAPIDO		
        
											
P_IT4_FIM:		
                        lw s0, (sp)
                        addi sp, sp, 4
			ret