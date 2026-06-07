#################################################################
# PROC_IMPRIMIR_OUTLINE 				       	#
# Imprime um retangulo ao redor de coordenadas                  #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : COR DE PREENCHIMENTO                            	#
#       A1 : X1                                                 #
#       A2 : Y1                                                 #
#       A3 : X2                                                 #
#       A4 : Y2                                                 #
#       A5 : grossura do outline                                #
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

PROC_IMPRIMIR_OUTLINE: 	
			la t0, FRAME_BUFFER_PTR
			lw t0, (t0)
		
                        li t4, LARGURA_VGA              # t4 = Xm = MAXIMO X PERMITIDO
                        li t5, ALTURA_VGA               # t5 = Ym = MAXIMO Y PERMITIDO

                        addi a1, a1, -1                 # X1-=1
                        addi a2, a2, -1                 # Y1-=1

                        addi a3, a3, 1                  # X2+=1
                        addi a4, a4, 1                  # Y2+=1
                        
			mul t1, a2, t4			# t1 = pL = Y1 * LVGA
			add t1, t1, a1			# t1 = pL + X1
			add t0, t0, t1			# BUFFER += pL + X1, indo pra posicao em que queremos imprimir

                        mv t2, a1                       # t2 = X ATUAL
                        mv t3, a2                       # t3 = Y ATUAL

                        j P_IO1_LOOP

P_IO1_PROXIMA_LINHA:
                        sub t1, a3, a1                  # t1 = X2-X1

                        # correcao necessaria
                        # nao sei o motivo, so sei que cheguei nesses valores experimentalmente
                        addi t1, t1, 1
                        addi t0, t0, 1

                        sub t1, t4, t1                  # t1 = LARGURA_VGA-(X2-X1)
			add t0, t0, t1			# E += LARGURA_VGA-(X2-X1)
                        mv t2, a1                       # X = X1
			addi t3, t3, 1                  # Y++
                        
				
			# SE Y > Y2 sai do loop
			bgt t3, a4, P_IRO_FIM

P_IO1_LOOP:

                        # se estamos no lado superior, inferior, ou esquerda, continue.
                        beq t3, a2, P_IO1_LOOP_CONT
                        beq t2, a1, P_IO1_LOOP_CONT
                        beq t3, a4, P_IO1_LOOP_CONT

                        # senao, acabamos de entrar no interior do outline e devemos sair!
                        # vamos pro lado direito.
                        mv t2, a3                       # X ATUAL = X2

                        # avanca x2-x1-2 posicoes pra frente, colocando-nos no lado direito
                        add t0, t0, a3
                        sub t0, t0, a1
                        addi t0, t0, -1
P_IO1_LOOP_CONT:

                        # se X < 0 ou Y < 0 ou X => Xm ou Y => Ym, nao imprime.
                        bltz t2, P_IO1_PULA_PIXEL        
                        bltz t3, P_IO1_PULA_PIXEL
                        bgt t2, t4, P_IO1_PULA_PIXEL
                        bgt t3, t5, P_IO1_PULA_PIXEL

                        sb a0,	(t0)			# imprime o pixel.
P_IO1_PULA_PIXEL:       

                        # SE X > X2, VAI PARA A PROXIMA LINHA
			beq t2, a3, P_IO1_PROXIMA_LINHA

                        # avanca pra proxima casa                    
                        addi t2, t2, 1
                        addi t0, t0, 1     

			j P_IO1_LOOP			# continua o loop	

P_IRO_FIM:
                        # se a grossura era so um mesmo, devemos retornar.
                        # senao, devemos refazer o que fizemos, so que com a grossura menor em 1 pixel, visto que ja fizemos 1 pixel de grossura.
                        # recursivamente, conseguimos fazer uma outline de grossura arbitraria.
                        addi a5, a5, -1
                        bgtz a5, PROC_IMPRIMIR_OUTLINE  # se grossura-1 > 1, refaz. senao, termina.
                        ret


