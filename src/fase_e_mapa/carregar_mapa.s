# PROC_CARREGAR_MAPA
# Carrega um mapa dado na memoria.

# Argumentos: a0 - endereco do mapa visual.
#             a1 - endereco do mapa de colisao.

PROC_CARREGAR_MAPA:

P_CM1_VISUAL:           # primeiro
        mv t6, zero     # tilemap 0: visual
        la t0, tilemap

P_CM1_COLISAO:
        lw t1, (a0)
        sw t1, (t0)
        lw t2, 4(a0)
        sw t2, 4(t0)

        slli t4, t2, LOG2_TAMANHO_TILE
        slli t3, t1, LOG2_TAMANHO_TILE
        
        mv t1, zero
        mv t2, zero

        # pula os bytes de dimensao
        addi a0, a0, 8  
        addi t0, t0, 8

        # a0 - endereco do mapa original
        # t0 - endereco do tilemap onde vamos carregar
        # t1 - X
        # t2 - Y
        # t3 - X limite
        # t4 - Y limite
        # t5 - tile atual

P_CM1_LOOP:
        lb t5, (a0)
        sb t5, (t0)

P_CM1_LOOP_CONT:
        # proximo byte
        addi t0, t0, 1
        addi a0, a0, 1  
        addi t1, t1, TAMANHO_TILE   # avanca o tile de um X
        blt t1, t3, P_CM1_LOOP  # se nao ultrapassamos o limite do X, continua o loop

P_CM1_LOOP_PROXIMA_LINHA:
        mv t1, zero             # zera o x
        addi t2, t2, TAMANHO_TILE
        blt t2, t4, P_CM1_LOOP  # se nao ultrapassamos o limite do Y, continua o loop

P_CM1_FIM_LOOP:
        bnez t6, P_CM1_RET      # se tivermos acabado de fazer o tilemap 1 (colisao), termina

        addi t6, t6, 1          # senao, comeca ele
        la t0, tilemap_colisao  # pega o tilemap certo
        mv a0, a1               # pega o endereco certo
        j P_CM1_COLISAO         # refaz o procedimento com o tilemap de colisao

P_CM1_RET:
        ret                     # retorna, terminado o carregamento