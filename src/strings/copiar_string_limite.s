#################################################################
# PROC_COPIAR_STRING_LIMITE				       	#
# Copia o conteudo de uma string a outra ateh ou encontrar um   #
# caractere \0 ou copiar a2 caracteres.                         #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Endereco da string origem                          #
#       A1 : Endereco da string destino                         #
#       A2 : Quantidade max de bytes                            #
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

PROC_COPIAR_STRING_LIMITE:
        beqz a2, P_CS2_RET # faz nada se qtd = 0
        add a2, a0, a2 # endereco limite de copia
P_CS2_LOOP:
        lb t0, (a0)
        sb t0, (a1)
        beqz t0, P_CS2_RET
        addi a0, a0, 1
        addi a1, a1, 1
        bltu a0, a2, P_CS2_LOOP
P_CS2_RET:
        ret