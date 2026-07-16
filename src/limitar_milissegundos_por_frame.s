# PROC_LIMITAR_MILISSEGUNDOS_POR_FRAME
#
# Limita a quantidade de frames por segundo para um minimo de a0 ms entre frames.
#
# Argumento:
# a0 - mínimo de mspf

.data
        LM1_ULTIMA_CHAMADA_TIMESTAMP: .word 0
.text
PROC_LIMITAR_MILISSEGUNDOS_POR_FRAME:
        csrr t0, time
        la t2, LM1_ULTIMA_CHAMADA_TIMESTAMP
        lw t1, (t2)
        sub t1, t0, t1          # tempo entre agora e o ultimo frame
        bgt t1, a0, P_LM1_RET   # se passou mais tempo que o minimo, nao faz nada

        # dorme pelo que falta para completar o delay
        sub a0, a0, t1          
	li a7, 32
        ecall

P_LM1_RET:
        csrr t0, time
        sw t0, (t2)
        ret
