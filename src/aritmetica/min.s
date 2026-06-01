# PROC_MIN
# Retorna o minimo entre dois numeros.
#
# Argumentos:
# a0 - valor 1
# a1 - valor 2
#
# Retornos:
# a0 - minimo

PROC_MIN:
        blt a0, a1, PM1_RET     # retorna o proprio a0 se a0 < a1
        mv a0, a1               # retorna a1 se a1 <= a0
PM1_RET:
ret