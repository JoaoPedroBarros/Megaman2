#################################################################
# PROC_IMPRIMIR_STRING				       	     	#
# Imprime uma string no FRAME BUFFER.				#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : endereco da string					#
#	A1 : X							#
#	A2 : Y							#
#	A3 : cores (0x0000bbff)					#
# RETORNOS:                                                  	#
#       (nenhum)						#
#################################################################

# Prefixo interno: P_IS1_

# CODIGO ADAPTADO DE SYSTEMv24.s
	
.text
	

PROC_IMPRIMIR_STRING:

			addi	sp, sp, -12			# aloca espaco
	    		sw	ra, 0(sp)			# salva ra
	    		sw	s0, 4(sp)			# salva s0
	    		sw 	s1, 8(sp)			# pos x (para podermos indentar o texto corretamente)
			mv 	s1, a1				# salva a pos x

			mv s0, a0				# coloca o endereco da string em s0

P_IS1_LOOP:		lb	a0, 0(s0)                 	# le em a0 o caracter a ser impresso
	
	    		beq     a0, zero, P_IS1_LOOP_FIM	# string ASCIIZ termina com NULL
	    		
	    		li 	t0, '\n'
	    		beq	a0, t0, P_IS1_PulaLinha		# se o caractere for enter, pula linha

			bltz a2, P_IS1_PulaCaractere		# pula se y < 0 

	    		jal     SUBPROC_IMPRIMIR_CARACTERE 	# imprime char

P_IS1_PulaCaractere:
	    		
			addi    a1, a1, 8                 	# incrementa a coluna
			li 	t6, LARGURA_VGA
			addi 	t6, t6, -7		
			bge	a1, t6, P_IS1_PulaLinha		# se nao tiver lugar na linha
			
			j 	P_IS1_NaoPulaLinha		# por padrao, nao pula linha
			
P_IS1_PulaLinha:	    	addi    a2, a2, 10                 	# incrementa a linha (+2 de spacing)
	    		mv    	a1, s1				# volta a coluna zero

P_IS1_NaoPulaLinha:	addi    s0, s0, 1			# proximo caractere
    			j       P_IS1_LOOP       		# volta ao loop

P_IS1_LOOP_FIM:		lw      ra, 0(sp)    			# recupera ra
			lw 	s0, 4(sp)			# recupera s0 original
			lw	s1, 8(sp)
    			addi    sp, sp, 12			# libera espaco
			ret      	    			# retorna


#########################################################
#  SUBPROC_IMPRIMIR_CARACTERE                            #
#  a0 = char(ASCII)                                     #
#  a1 = x                                               #
#  a2 = y                                               #
#  a3 = cores (0x0000bbff) 	b = fundo, f = frente	#
#########################################################
#   t0 = i                                              #
#   t1 = j                                              #
#   t2 = endereco do char na memoria                    #
#   t3 = metade do char (2a e depois 1a)                #
#   t4 = endereco para impressao                        #
#   t5 = background color                               # 
#   t6 = foreground color                               #
#########################################################

# Prefixo interno: SP_IC1_

#	t9 foi convertido para s9 pois nao ha registradores temporarios sobrando dentro deste procedimento

SUBPROC_IMPRIMIR_CARACTERE:
		addi sp, sp, -4
		sw s9, (sp)
		li 	t4, 0xFF	# t4 temporario
		slli 	t4, t4, 8	# t4 = 0x0000FF00 (no RARS, nao podemos fazer diretamente "andi rd, rs1, 0xFF00")
		and    	t5, a3, t4   	# t5 obtem cor de fundo
    		srli	t5, t5, 8	# numero da cor de fundo
		andi   	t6, a3, 0xFF    # t6 obtem cor de frente

		li 	tp, ' '
		blt 	a0, tp, SP_IC1_.NAOIMPRIMIVEL	# ascii menor que 32 nao eh imprimivel
		li 	tp, '~'
		bgt	a0, tp, SP_IC1_.NAOIMPRIMIVEL	# ascii Maior que 126  nao eh imprimivel
    		j       SP_IC1_.IMPRIMIVEL
    
SP_IC1_.NAOIMPRIMIVEL: li      a0, 32		# Imprime espaco

SP_IC1_.IMPRIMIVEL:	li	tp, LARGURA_VGA			# Num colunas 320
SP_IC1_.mul1:		mul     t4, tp, a2			# multiplica a2x320  t4 = coordenada y
SP_IC1_.mul1d:	add     t4, t4, a1               		# t4 = 320*y + x
			addi    t4, t4, 7                 	# t4 = 320*y + (x+7)
			lw      tp, FRAME_BUFFER_PTR          	# pointer de frame
			add     t4, t4, tp               	# t4 = endereco de impressao do ultimo pixel da primeira linha do char
			addi    t2, a0, -32               	# indice do char na memoria
			slli    t2, t2, 3                 	# offset em bytes em relacao ao endereco inicial
			la      t3, LabelTabChar		# endereco dos caracteres na memoria
			add     t2, t2, t3               	# endereco do caractere na memoria
			lw      t3, 0(t2)                 	# carrega a primeira word do char
			li 	t0, 4				# i=4

SP_IC1_.forChar1I:	beq     t0, zero, SP_IC1_.endForChar1I # if(i == 0) end for i
    			addi    t1, zero, 8               	# j = 8

SP_IC1_.forChar1J:	beq     t1, zero, SP_IC1_.endForChar1J # if(j == 0) end for j
        		andi    s9, t3, 0x001			# primeiro bit do caracter
        		srli    t3, t3, 1             		# retira o primeiro bit
        		beq     s9, zero, SP_IC1_.SP_IC1_Pixelbg1	# pixel eh fundo?
        		sb      t6, 0(t4)             		# imprime pixel com cor de frente
        		j       SP_IC1_.endCharPixel1
SP_IC1_.SP_IC1_Pixelbg1:	
			li	s9, COR_TRANSPARENTE
			beq	t5, s9, SP_IC1_.endCharPixel1	# se cor eh transparente, nao imprime aqui
			sb      t5, 0(t4)                # imprime pixel com cor de fundo
SP_IC1_.endCharPixel1: addi    t1, t1, -1                	# j--
    			addi    t4, t4, -1                	# t4 aponta um pixel para a esquerda
    			j       SP_IC1_.forChar1J		# vollta novo pixel

SP_IC1_.endForChar1J: addi    t0, t0, -1 		# i--
    			addi    t4, t4, LARGURA_VGA
			addi    t4, t4, 8
    			j       SP_IC1_.forChar1I	# volta ao loop

SP_IC1_.endForChar1I:	lw      t3, 4(t2)           	# carrega a segunda word do char
			li 	t0, 4			# i = 4
SP_IC1_.forChar2I:    beq     t0, zero, SP_IC1_.endForChar2I  # if(i == 0) end for i
    			addi    t1, zero, 8             # j = 8

SP_IC1_.forChar2J:	beq	t1, zero, SP_IC1_.endForChar2J # if(j == 0) end for j
        		andi    s9, t3, 0x001	    		# pixel a ser impresso
        		srli    t3, t3, 1                 	# desloca para o proximo
        		beq     s9, zero, SP_IC1_.SP_IC1_Pixelbg2 # pixel eh fundo?
        		sb      t6, 0(t4)			# imprime cor frente
        		j       SP_IC1_.endCharPixel2		# volta ao loop

SP_IC1_.SP_IC1_Pixelbg2:	
			li	s9, COR_TRANSPARENTE
			beq	t5, s9, SP_IC1_.endCharPixel2	# se cor eh transparente, nao imprime aqui
			sb      t5, 0(t4)		# imprime cor de fundo

SP_IC1_.endCharPixel2:	addi    t1, t1, -1		# j--
    				addi    t4, t4, -1              # t4 aponta um pixel para a esquerda
    				j       SP_IC1_.forChar2J

SP_IC1_.endForChar2J:	addi	t0, t0, -1 		# i--
    			addi    t4, t4, LARGURA_VGA
			addi    t4, t4, 8
    			j       SP_IC1_.forChar2I	# volta ao loop

SP_IC1_.endForChar2I:	
			lw s9, (sp)
			addi sp, sp, 4
			ret				# retorna
