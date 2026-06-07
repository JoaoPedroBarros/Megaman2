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
        mv t1, zero             # t1 = tamanho
P_TS1_LOOP:
        lb t0, (a0)             # pega o caractere atual
        beqz t0, P_TS1_RET      # se o caractere eh \0, retorna t1
        addi t1, t1, 1          # senao, aumenta o tamanho da string
        addi a0, a0, 1          # vai pro proximo caractere
        j P_TS1_LOOP
P_TS1_RET:
        mv a0, t1               # retorna a qtd de caracteres
        ret