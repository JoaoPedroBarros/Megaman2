# Créditos a Thiago Tomás de Paula. Algoritmo retirado do Livrão de OAC
# Descrição: sleep(int time) : Realiza um sleep blocking de time ms
# "Congela o programa por time ms"
Sleep:
	csrr t0, time
	add t1, t0, a0
SleepLoop:
	csrr t0, time
	sltu t2, t0, t1
	bne t2, zero, SleepLoop
	ret