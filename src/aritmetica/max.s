# PROC_MAX
# Retorna o maximo entre dois numeros.
#
# Argumentos:
# a0 - valor 1
# a1 - valor 2
#
# Retornos:
# a0 - maximo

PROC_MAX:
        bge a0, a1, PM2_RET     # retorna o proprio a0 se a0 <= a1
        mv a0, a1               # retorna a1 se a1 > a0
PM2_RET:
ret