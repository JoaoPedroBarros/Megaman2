# PROC_IMPRIMIR_TILE
# imprime um tile na tela

# Argumentos
#       a0 - tipo do tile
#       a1 - X
#       a2 - Y
#       a3 - textura

PROC_IMPRIMIR_TILE:
        addi sp, sp, -4
        sw ra, (sp)

        li t0, TILE_VOID
        beq a0, t0, P_IT2_RET   # nao imprime se o tile for void (nada)

        li t1, AREA_TILE
        MULTIPLY(a0, a0, t1)
        add a0, a3, a0          # avanca AREA_TILE * TIPO_TILE casas, para o endereco do tile certo
        addi a0, a0, 8          # pula as 2 words de dimensao

        # a0 posicionado (textura)
        # a1 posicionado (x)
        # a2 posicionado (y)
        li a3, TAMANHO_TILE     # altura do tile 
        li a4, TAMANHO_TILE     # largura do tile
        jal PROC_IMPRIMIR_TEXTURA
P_IT2_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret


