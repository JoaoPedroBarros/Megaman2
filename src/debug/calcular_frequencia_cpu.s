#################################################################
# PROC_CALCULAR_FREQUENCIA_CPU        		                #
# Gasta uma quandidade de milissegundos medindo a frequencia    #
# media da CPU.                                                 #
# 							     	#
# ARGUMENTOS:						     	#
#	a0 - ms para serem gastos (aprox) -- favor inserir      #
#       um divisor de 1000                                      #
# RETORNOS:                                                  	#
#       a0 - frequencia medida                                  #
#################################################################

# Prefixo interno: P_CF1_

.eqv CF1_ITERACOES_DO_LOOP_POR_CHECAGEM 10000

PROC_CALCULAR_FREQUENCIA_CPU:
        csrr t1, time                   # tempo no comeco da checagem
        mv t2, zero                     # zera a quantidade de instrucoes por enquanto
P_CF1_CHECAR:
        li t0, CF1_ITERACOES_DO_LOOP_POR_CHECAGEM
P_CF1_LOOP:
        addi t0, t0, -1                 # (qtd de iteracoes faltando)--
        bgt t0, zero, P_CF1_LOOP        # repete se 0 < qtd de iteracoes faltando
P_CF1_LOOP_FIM:
        li t0, CF1_ITERACOES_DO_LOOP_POR_CHECAGEM
        slli t3, t0, 1                  # pega 2*(iteracoes do loop)
                                        # (isto eh, a qtd de instrucoes rodadas no loop)
        add t2, t2, t3                  # adiciona a qtd no contador

        csrr t3, time                   # pega o tempo atual
        sub t3, t3, t1                  # pega a diferenca entre o tempo atual e o tempo no comeco
        blt t3, a0, P_CF1_LOOP          # se ainda nao atingimos a qtd de ms exigida, continua checando

        # se jah atingimos,
        div t2, t2, t3                  # divide a qtd de instrucoes pela qtd de tempo gasto aproximado (em ms)
        li t0, 1000
        mul a0, t2, t0                  # calcula qtd de instrucoes por segundo e coloca no registrador de retorno
P_CF1_RET:
        ret