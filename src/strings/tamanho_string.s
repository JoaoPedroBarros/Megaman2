#################################################################
# PROC_TAMANHO_STRING                                           #
# Retorna o tamanho de uma string                               #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Endereco da string origem                          #
#                                                               #
# RETORNOS:                                                  	#
#       A0 : Quantidade de caracteres                           #
#################################################################

PROC_TAMANHO_STRING:
        mv t1, a0               # t1 = endereco atual
P_TS1_LOOP:
        lb t0, (t1)             # pega o caractere atual
        beqz t0, P_TS1_RET      # se o caractere eh \0, retorna t1
        addi t1, t1, 1          # senao, vai para o prox caractere
        j P_TS1_LOOP
P_TS1_RET:
        sub a0, t1, a0          # retorna a quantidade de caracteres que andamos
        ret