# PROC_APLICAR_MOVIMENTACAO
# Atualiza a posicao das entidades com base na velocidade delas
#
# Argumento: a0 - entidade
# 
# (sem retornos)

PROC_APLICAR_MOVIMENTACAO:
        lw t1, entidade.VELOCIDADE_X_Q12(a0)
        lw t2, entidade.X_Q12(a0)
        add t2, t2, t1
        sw t2, entidade.X_Q12(a0)

        lw t1, entidade.VELOCIDADE_Y_Q12(a0)
        lw t2, entidade.Y_Q12(a0)
        add t2, t2, t1
        sw t2, entidade.Y_Q12(a0)
        ret
