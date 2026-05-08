.data
	# Mapas
	.include "Sprites/mapas.s" # Por enquanto tem recorteBase(320x240) e paisagemTeste(640x240)
	# Sprites
	# Sons
	texto: .string "Ola, Mundo"
.text
CONFIGURACOES:
	# Configuracoes
	#|-> Define mapa
	
GAME_LOOP:
	# Sleep
	#li a0, 30
	#call Sleep

	# Da renderização
		# Inverte frame a ser renderizado
		#li t0, 0xFF200604
		#lw t1, 0(t0)
		#xori t1, t1, 1
		#slli t1, t1, 20
		#lui t2, 0xFF000
		#xor t1, t1, t2
		#mv s1, t1	#s1 = 0xFFX0 0000 : Endereco inicial do Bitmap a ser renderizado
				# Guardei em s1, pois usaremos esse valor nas 4 funções a seguir
			
		# Renderiza background
			li t3,0x07070707	# cor vermelho|vermelho|vermelhor|vermelho
			li t3,0x07070707	# cor vermelho|vermelho|vermelhor|vermelho
			# "call RenderizaBackground (int enderecoImagem, int posicaoInicial)"
			#|-> Pega endereço de recorte
			#|-> Renderiza recorte em cima do endereço em a0
		
		# Renderiza objetos
			# "call RenderizaObjeto (int enderecoObjeto, int posicaoInicial, int salto)"
			#|-> personagem
			#|-> inimigos
			#|-> eventos (feitiços e afins)
		
		# Atualiza etapa da animação dos objetos
			# personagem
			# inimigos
			# eventos (feitiços e afins)
			
		# Inverte frame de exibição
		#li t0, 0xFF200604
		#lw t1, 0(t0)
		#xori t1, t1, 1
		#sw t1 0(t0)
		
	# Da movimentação
		# Faz o pool do teclado
		
		# Atualiza recorte
		
		# Atualiza posição objetos
			# personagem
			# inimigos
			# eventos (feitiços e afins)
	
	# Toca musica
	
FIM_GAME_LOOP:
	li a7, 10
	ecall

.include "Funcoes/sleep.s"
.include "Funcoes/Debug.s"