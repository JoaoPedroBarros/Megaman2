.eqv N 32

.data
Vetor: .word 9,2,5,1,8,2,4,3,6,7,10,2,32,54,2,12,6,3,1,78,54,23,1,54,2,65,3,6,55,31,4,-4
#Vetor:	.word -4,1,1,1,2,2,2,2,2,3,3,3,4,4,5,6,6,6,7,8,9,10,12,23,31,32,54,54,54,55,65,78
#Vetor: .word 78,65,55,54,54,54,32,31,23,12,10,9,8,7,6,6,6,5,4,4,3,3,3,2,2,2,2,2,1,1,1,-4
 
.text
MAIN:	la a0,Vetor
	li a1,N
	jal SHOW

	la a0,Vetor
	li a1,N
#	jal SORT1   #Bubble sort
	jal SORT2   #Gnome sort

	la a0,Vetor
	li a1,N
	jal SHOW

	li a7,10
	ecall

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


SORT1:	li t0,0  # Bubble sort
for1:	bge t0,a1,exit1
	addi t1,t0,-1
for2:	blt t1,zero,exit2
	slli t2,t1,2
	add t2,a0,t2
	lw t3,0(t2)
	lw t4,4(t2)
	bge t4,t3,exit2
	sw t4,0(t2)
	sw t3,4(t2)
	addi t1,t1,-1
	j for2
exit2:	addi t0,t0,1
	j for1
exit1: 	ret


SORT2:  li t0,1	#gnome sort
While:  bge t0,a1,Fora
	slli t1,t0,2
	add t1,t1,a0
	lw t2,0(t1)
	lw t3,-4(t1)
	beq t0,zero,Incrementa
	bge t2,t3,Incrementa
	sw t3,0(t1)
	sw t2,-4(t1)
	addi t0,t0,-1
	j While	
Incrementa: addi t0,t0,1
	    j While
Fora:	ret
