.data
	texto: .string "Ola, Mundo"
.text

GAME_LOOP:

	.include "Funcoes/Debug.s"
	
	li a7, 10
	ecall
