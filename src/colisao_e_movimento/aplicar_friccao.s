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

        # vx -= sinal(vx) * fator_constante_friccao_chao

        beqz t1, P_AF1_CHAO_ZERAR_VELOCIDADE_X # se t1 = 0, deixa como 0

        li t0, FRICCAO_CONSTANTE_CHAO_Q12
        bltz t1, P_AF1_CHAO_VELOCIDADE_NEGATIVA

P_AF1_CHAO_VELOCIDADE_POSITIVA:
        ble t1, t0, P_AF1_CHAO_ZERAR_VELOCIDADE_X # se vx < fator, zera vx
        sub t1, t1, t0
        sw t1, entidade.VELOCIDADE_X_Q12(a0)    # senao, vx -= fator
        ret

P_AF1_CHAO_VELOCIDADE_NEGATIVA:
        neg t0, t0
        bge t1, t0, P_AF1_CHAO_ZERAR_VELOCIDADE_X # se |vx| < fator, zera vx
        sub t1, t1, t0
        sw t1, entidade.VELOCIDADE_X_Q12(a0)    # senao, vx -= -fator (vx += fator)
        ret

P_AF1_CHAO_ZERAR_VELOCIDADE_X:
        sw zero, entidade.VELOCIDADE_X_Q12(a0)
        ret