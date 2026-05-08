.eqv N 32

.data
Vetor:  .word 9,2,5,1,8,2,4,3,6,7,10,2,32,54,2,12,6,3,1,78,54,23,1,54,2,65,3,6,55,31,4,-4

.text	
MAIN:	la a0,Vetor
	li a1,N
	jal SHOW

	la a0,Vetor
	li a1,N
	jal SORT2

	la a0,Vetor
	li a1,N
	jal SHOW

	li a7,10
	ecall

SORT2:
	li t0,1
	
While:  slli t1,t0,2
	add t1,t1,a0
	lw t2,0(t1)
	lw t3,-4(t1)

  	bge t0,a1,Fora
	beq t0,zero,Incrementa
	bge t2,t3,Incrementa
	sw t3,0(t1)
	sw t2,-4(t1)
	addi t0,t0,-1
	j While	

Incrementa: addi t0,t0,1
	    j While
Fora:	ret

SHOW:	mv t0,a0
	mv t1,a1
	mv t2,zero

loop1: 	beq t2,t1,fim1
	li a7,1
	lw a0,0(t0)
	ecall
	li a7,11
	li a0,9
	ecall
	addi t0,t0,4
	addi t2,t2,1
	j loop1

fim1:	li a7,11
	li a0,10
	ecall
	ret
