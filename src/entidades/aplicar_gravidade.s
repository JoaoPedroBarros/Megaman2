# PROC_APLICAR_GRAVIDADE
# faz com que uma entidade acelere para baixo se ela nao estiver tocando no chao
#
# Argumentos: a0 - entidade
#             a1 - forca da gravidade
#
# Retorno: nenhum

PROC_APLICAR_GRAVIDADE:
        addi sp, sp, -4
        sw ra, 0(sp)

P_AG1_DETECTAR_COLISOES:
        # aqui ficaria o calculo para ver se o movimento 
        # da entidade, em qualquer ponto do movimento, vai
        # a colocar dentro do chao. por enquanto, vamos
        # assumir que y=352 eh o chao.

        #mv s0, a0

        #lw a0, entidade.X_Q12(s0)
        #lw a1, entidade.Y_Q12(s0)

        #srli a0, a0, 12
        #srli a1, a1, 12

        #lw t0, entidade.ALTURA(s0)
        #add a1, a1, t0
        #lw t0, entidade.VELOCIDADE_Y_Q12(s0)
        #add a1, a1, t0

        #jal CALCULA_TILE

        #beq a0, zero, P_AG1_PARAR
        #li t1, 2
        #beq a0, t1, P_AG1_PARAR

        #lw t1, entidade.VELOCIDADE_Y_Q12(s0)
        #add t1, t1, a1
        #sw t1, entidade.VELOCIDADE_Y_Q12(s0)
        #j P_AG1_RET

        lw t0, entidade.Y_Q12(a0)
        lw t1, entidade.VELOCIDADE_Y_Q12(a0)
        add t0, t1, t0
        srai t0, t0, 12         # pega parte inteira do Y
        lw t3, entidade.ALTURA(a0)
        add t0, t0, t3          # pega parte mais embaixo do Y na entidade
        li t2, 352
        bge t0, t2, P_AG1_PARAR # se o novo movimento vai colocar o Y mais baixo para ficar
                                # maior que 320, entao passamos do chao!

        add t1, t1, a1                          # acelera pela gravidade na direcao positiva (para baixo!)
        sw t1, entidade.VELOCIDADE_Y_Q12(a0)    # salva nova velocidade
        j P_AG1_RET

P_AG1_PARAR:
        sw zero, entidade.VELOCIDADE_Y_Q12(s0)
        li t0, 1
        sw t0, entidade.NO_CHAO(s0)

        #sw zero, entidade.VELOCIDADE_Y_Q12(a0)
        #sub t2, t2, t3
        #slli t2, t2, 12
        #sw t2, entidade.Y_Q12(a0)
        #li t0, 1
        #sw t0, entidade.NO_CHAO(a0)

P_AG1_RET:
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
