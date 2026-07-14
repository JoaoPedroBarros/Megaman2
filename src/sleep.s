# Cr�ditos a Thiago Tom�s de Paula. Algoritmo retirado do Livr�o de OAC
# Descri��o: sleep(int time) : Realiza um sleep blocking de time ms
# "Congela o programa por time ms"
PROC_SLEEP:
	li a0, 1
	li a7, 32
	ecall
	ret
#P_S1_LOOP:
	#csrr t0, time
	#sltu t2, t0, t1
	#bne t2, zero, SleepLoop
	#ret