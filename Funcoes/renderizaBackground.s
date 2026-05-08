################################################
############# RENDERIZA BACKGROUND #############
################################################

# P.S renderiza a tela inteira, mas não está adaptada para receber imagem

# Parametros #
# a0 = Frame (0 ou 1)
# a1 = Endereco Imagem
# a2 = 

.data
	#.include "frogger.data"

.text
	#li a0, 0
	#la a1, frogger
	#call RenderizaBackground
	
	#li a7, 10
	#ecall
	
RenderizaBackground:
# Preenche a tela de vermelho
	li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	# endereco final 
	li t3,0x07070707	# cor vermelho|vermelho|vermelhor|vermelho
LOOP: 	beq t1,t2,FORA		# Se for o último endereço então sai do loop
	sw t3,0(t1)		# escreve a word na memória VGA
	addi t1,t1,4		# soma 4 ao endereço
	j LOOP			# volta a verificar

FORA: 	ret