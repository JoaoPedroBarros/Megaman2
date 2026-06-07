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

        #la t0, tilemap # carrega a referencia do tilemap

        #lw t1, entidade.X_Q12(a0) # carrega o X
        #lw t2, entidade.Y_Q12(a0) # carrega o Y
        #lw t3, entidade.VELOCIDADE_Y_Q12(a0)

        #srli t1, t1, 12 # volta as coordenadas para Q0
        #srli t2, t2, 12
        #srli t3, t3, 12

        #addi t2, t2, 32 # pega o tile abaixo para ver se o personagem cai
        #add t2, t2, t3

        #li t3, TAMANHO_TILE # carrega o tamanho do tile

        #div t1, t1, t3 # divide as coordenadas para obter a localizacao no tilemap
        #div t2, t2, t3

        #lw t3, 4(t0) # calcula o comprimento do tilemap

        #mul t2, t2, t3 # multiplica o Y pelo comprimento para saber quantos tiles ja percorreu verticalmente
        #add t1, t1, t2 # adiciona o X para saber quantos tiles ja percorreu horizontalmente

        #addi t0, t0, 8 # pula as dimensoes do mapa
        #add t0, t0, t1 # adiciona a localizacao do personagem ao primeiro tile

        #lb t0, 0(t0)
        #beq t0, zero, P_AG1_PARAR
        #li t1, 2
        #beq t0, t1, P_AG1_PARAR

        #lw t1, entidade.VELOCIDADE_Y_Q12(a0)
        #add t1, t1, a1
        #sw t1, entidade.VELOCIDADE_Y_Q12(a0)
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
        #sw zero, entidade.VELOCIDADE_Y_Q12(a0)
        #li t0, 1
        #sw t0, entidade.NO_CHAO(a0)

        sw zero, entidade.VELOCIDADE_Y_Q12(a0)
        sub t2, t2, t3
        slli t2, t2, 12
        sw t2, entidade.Y_Q12(a0)
        li t0, 1
        sw t0, entidade.NO_CHAO(a0)

P_AG1_RET:
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
