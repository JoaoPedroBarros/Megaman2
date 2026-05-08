################################################
############# RENDERIZA BACKGROUND #############
################################################

# P.S renderiza a tela inteira, mas não está adaptada para receber imagem

# Parametros #
# a0 = Frame (0 ou 1)
# a1 = Endereco Imagem
# a2 = 

.data
	.include "../Sprites/mapas.s" # Por enquanto tem recorteBase(320x240) e paisagemTeste(640x240)

.text
	la a0, recorteBase
	li a1, 0xFF000000
	call RenderizaBackground
	
	li a7, 10
	ecall
	
RenderizaBackground:
# Preenche a tela de vermelho
	mv t1, a1	# t1 = endereco inicial da imagem
	mv t3, a0	# t0 = &imagem
	addi t3, t3, 8	# pula as words de definicao (nLinhas e nColunas)
	
	li t2, 0x12C00
	add t2, a1, t2	# t2 = endereco final do bitmap
	
	#li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	#li t2,0xFF012C00	# endereco final 
	#li t3,0x07070707	# cor vermelho|vermelho|vermelhor|vermelho
LOOP: 	beq t1,t2,FORA		# Se for o último endereço então sai do loop
	lw t4,0(t3)
	sw t4,0(t1)		# escreve a word na memória VGA
	addi t1,t1,4		# soma 4 ao endereço
	addi t3,t3,4
	j LOOP			# volta a verificar

FORA: 	ret
