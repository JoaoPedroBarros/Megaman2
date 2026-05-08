# Equivalente em C: int passouTempo(Tempo &UltReg, int t)
# Descrição: Retorna 1 se a diferença entre o tempo Atual e UltReg for >= t. Se não retorna 0.
#	     Caso retorne 1, também atualiza UltReg.

# P.S Funciona, mas é gambiarra!

.data
	TEMPO_INICIAL_SCORE_TIMER: .word 0
	PASSOU: .string "Passou 1 segundo\n"
.text
	# Pega tempo atual
	li a7, 30
	ecall

	# Correcao para que todas funcoes rodem pela primeira vez
	li t0, -6000		# O valor aqui precisa ser ajustado para que todas as funcoes funcionem
	add a0, a0, t0		# "Atrasa" TEMPO_ATUAL

	# Inicializa TEMPO_INICIAL_SCORE_TIMER
	la s2, TEMPO_INICIAL_SCORE_TIMER
	sw a0, 0(s2)	# Inicializa: TEMPO_INICIAL_SCORE_TIMER = TEMPO_ATUAL	

LOOP:
	# Pega tempo em TEMPO_INICIAL_SCORE_TIMER
	la s2, TEMPO_INICIAL_SCORE_TIMER	# Pega endereco de TEMPO_INICIAL_SCORE_TIMER
	lw s2, 0(s2)                        # Pega o conteudo de TEMPO_INICIAL_SCORE_TIMER

	# Pega tempo atual
	li a7, 30           # Chama a funcao TIME()
	ecall               # Chama o Sistema operacional

	# Pega o tempo passado desde o tempo inicial
	sub t3, a0, s2			# t3 = TEMPO_ATUAL - TEMPO_INICIAL_TESTE

	li t2, 1000     # Constante de comparacao : 1 segundo
	blt t3, t2, PULA_REDUZ_TIMER # Se passou 1 segundo, reduza SCORE_TIMER	
	
	la a0, PASSOU
	li a7, 4
	ecall
	
	# Atualiza TEMPO_INICIAL_SCORE_TIMER
	li a7, 30   # Chama a funcao TIME()
	ecall       # Chama o Sistema operacional
	
	la s2, TEMPO_INICIAL_SCORE_TIMER    # Pega endereco de TEMPO_INICIAL_SCORE_TIMER
	sw a0, 0(s2)                        # Atualiza o conteudo de TEMPO_INICIAL_SCORE_TIMER


PULA_REDUZ_TIMER:
	j LOOP