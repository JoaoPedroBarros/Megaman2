# PROC_APLICAR_FRICCAO
# Aplica friccao na entidade, desacelerando-a dependendo do
# ambiente onde ela estah
#
# Argumentos:
# a0 - Endereco da struct basica da entidade

PROC_APLICAR_FRICCAO:
        lw t0, entidade.NO_CHAO(a0)
        lw t1, entidade.VELOCIDADE_X_Q12(a0)
        bnez t0, P_AF1_CHAO
P_AF1_AR:
        ret
        # vx -= vx >> fator_friccao_ar
        srai t2, t1, FATOR_FRICCAO_AR
        sub t1, t1, t2
        sw t1, entidade.VELOCIDADE_X_Q12(a0)

        # vy -= vy >> fator_friccao_ar
        lw t1, entidade.VELOCIDADE_Y_Q12(a0)
        srai t2, t1, FATOR_FRICCAO_AR
        sub t1, t1, t2
        sw t1, entidade.VELOCIDADE_Y_Q12(a0)

        ret
P_AF1_CHAO:
        # vx -= vx >> fator_friccao_chao
        srai t2, t1, FATOR_FRICCAO_CHAO
        sub t1, t1, t2
        sw t1, entidade.VELOCIDADE_X_Q12(a0)

        ret