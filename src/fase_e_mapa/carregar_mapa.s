# PROC_CARREGAR_MAPA
# Carrega um mapa dado na memoria.

# Argumentos: a0 - endereco do mapa.

PROC_CARREGAR_MAPA:
        la t0, tilemap

        lw t1, (a0)
        sw t1, (t0)
        lw t2, 4(a0)
        sw t2, 4(t0)

        li t3, TAMANHO_TILE
        MULTIPLY(t4,t2,t3)
        MULTIPLY(t3,t1,t3)
        
        mv t1, zero
        mv t2, zero

        # a0 - endereco do mapa original
        # t0 - endereco do tilemap onde vamos carregar
        # t1 - X
        # t2 - Y
        # t3 - X limite
        # t4 - Y limite
        # t5 - tile atual

        li a1, TILE_INICIO_FASE
        # a1 - tile de inicio de fase

P_CM1_LOOP:
        lb t5, (a0)
        sb t5, (t0)
        beq a1, t5, P_CM1_REGISTRAR_JOGADOR
        j P_CM1_LOOP_CONT

P_CM1_REGISTRAR_JOGADOR:
        # guarda as posicoes do jogador
        la t6, jogador
        sw t1, jogador_x(t6)
        sw t2, jogador_y(t6)

P_CM1_LOOP_CONT:
        # proximo byte
        addi t0, t0, 1
        addi a0, a0, 1  
        addi t1, t1, TAMANHO_TILE   # avanca o tile de um X
        ble t1, t3, P_CM1_LOOP  # se nao ultrapassamos o limite do X, continua o loop

P_CM1_LOOP_PROXIMA_LINHA:
        mv t1, zero             # zera o x
        addi t2, t2, TAMANHO_TILE
        ble t2, t4, P_CM1_LOOP  # se nao ultrapassamos o limite do Y, continua o loop

P_CM1_RET:
        ret                     # retorna, terminado o carregamento