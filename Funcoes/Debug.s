.data

.text
	# Inverte frame a ser renderizado
LOOP:	
	li t0, 0xFF200604
	lw t1, 0(t0)
	xori t1, t1, 1
	slli t1, t1, 20
	
	lui t2, 0xFF000
	xor t1, t1, t2
	mv s1, t1	#S1 = 0xFFX0 0000 : Endereco inicial do Bitmap a ser renderizado
		
	li t0, 0xFF200604
	lw t1, 0(t0)
	xori t1, t1, 1
	sw t1 0(t0)
	
	j LOOP
	li a7,10
	ecall
