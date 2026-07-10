#################################################################
# PROC_COPIAR_STRING_LIMITE_SEGURO				#
# Copia o conteudo de uma string a outra ateh ou encontrar um   #
# caractere \0 ou copiar a2-1 caracteres, colocando um \0 no    #
# final.                                                        #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Endereco da string origem                          #
#       A1 : Endereco da string destino                         #
#       A2 : Quantidade max de bytes                            #
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

PROC_COPIAR_STRING_LIMITE_SEGURO:
        beqz a2, P_CS3_RET      # faz nada se qtd = 0
        addi a2, a2, -1 # guarda espaco para o \0 no final
        beqz a2, P_CS3_TERMINAR # se qtd = 1, coloca apenas o \0
        # senao, copia normal
        add a2, a0, a2  # a2 = endereco limite de copia (sem contar com o \0)
P_CS3_LOOP:
        lb t0, (a0)
        sb t0, (a1)
        beqz t0, P_CS3_RET
        addi a0, a0, 1
        addi a1, a1, 1
        bltu a0, a2, P_CS3_LOOP
P_CS3_TERMINAR:
        sb zero, (a1)   # termina com um \0
P_CS3_RET:
        ret