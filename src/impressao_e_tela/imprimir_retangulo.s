#################################################################
# PROC_IMPRIMIR_RETANGULO				       	#
# Muda cada pixel do frame fornecido para ter a cor fornecida 	#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : COR DE PREENCHIMENTO                            	#
#       A1 : X1                                                 #
#       A2 : Y1                                                 #
#       A3 : X2                                                 #
#       A4 : Y2                                                 #
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################



PROC_IMPRIMIR_RETANGULO: 	
	la t3, FRAME_BUFFER_PTR
	lw t3, (t3)
	
	# (x1, y1) DEVE SER MENOR QUE (x2, y2)
	ble a1, a3, P_IR1_N_TROCAR_X1_X2
	mv t0, a1
	mv a1, a3
	mv a3, t0
P_IR1_N_TROCAR_X1_X2:
	ble a2, a4, P_IR1_N_TROCAR_Y1_Y2
	mv t0, a2
	mv a2, a4
	mv a4, t0
P_IR1_N_TROCAR_Y1_Y2:

P_IR1_X_MIN:
	srai t0, a1, 31			# 0x0000 se a1 >= 0, 0xFFFF se a1 < 0
	not t0, t0			# 0xFFFF se a1 >= 0, 0x0000 se a1 < 0
	and a1, a1, t0			# a1 se a1 >= 0, 0 se a1 < 0
P_IR1_Y_MIN:
	srai t0, a2, 31			# 0x0000 se a2 >= 0, 0xFFFF se a2 < 0
	not t0, t0			# 0xFFFF se a2 >= 0, 0x0000 se a2 < 0
	and a2, a2, t0			# a2 se a2 >= 0, 0 se a2 < 0

	li t4, LARGURA_VGA		# t0 = LVGA (largura VGA) // largura do buffer
	blt a3, t4, P_IR1_X_AJUSTADO	# X nao pode passar do maximo (LVGA-1)
	addi a3, t4, -1			# Coloca como max
P_IR1_X_AJUSTADO:
	li t0, ALTURA_VGA
	blt a4, t0, P_IR1_Y_AJUSTADO	# Y tbm nao pode passar do maximo (HVGA-1)
	addi a4, t0, -1			# Coloca como max

P_IR1_Y_AJUSTADO:

P_IR1_MAIN:
	MULTIPLY(t0, a2, t4)		# t0 = pL = Y1 * LVGA
	add t0, t0, a1			# t0 = pL + X1
	add t3, t3, t0			# BUFFER += pL + X, indo pra posicao em que queremos imprimir
	
# a0 = I  = informacao do pixel de textura atual
# t1 = X  = X atual
# t2 = Y  = Y atual
# t3 = P  = endereco do pixel vga atual
# t4 = Lm = Largura VGA
# t6 = COR_TRANSPARENTE


# t6 = cor transparente
	sub t0, a3, a1
	mv t1, a1
	mv t2, a2
	li t6, COR_TRANSPARENTE		
	j P_IR1_LOOP			# vai pro loop
	
P_IR1_PROXIMA_LINHA:    
	sub t1, t0, t4 			# t1 = C-320 -- lembre-se que a tela eh 240 por 320!
	neg t1, t1			# t1 = 320-C

	add t3, t3, t1			# E += 320-C (t6)

	mv t1, a1                       # X = X1

	addi t2, t2, 1                  # Y++
		
	# SE Y > Y2 sai do loop
	bgt t2, a4, P_IR1_FIM
	
P_IR1_LOOP:		
	beq a0, t6, P_IR1_PULA_PIXEL	# SE ( I == COR_TRANSPARENTE ), ENTAO PULA O PIXEL
	sb a0,	(t3)			# 	imprime o pixel
P_IR1_PULA_PIXEL:	

	# SE X = X2, VAI PARA A PROXIMA LINHA
	beq t1, a3, P_IR1_PROXIMA_LINHA

	addi t1, t1, 1			# CC++ 
	addi t3, t3, 1			# P++ 

	j P_IR1_LOOP			# continua o loop		
									
P_IR1_FIM:					
	ret	
