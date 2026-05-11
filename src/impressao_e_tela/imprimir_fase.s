# PROC_IMPRIMIR_FASE
# imprime a fase carregada na memoria com a textura na memoria.

# for (i : linhas)
        # for (j : colunas)
                # print(tile[i][j], relative_pos(camera, i, j))

PROC_IMPRIMIR_FASE:
        addi sp, sp, -28
        sw s0, (sp)
        sw s1, 4(sp)
        sw s2, 8(sp)
        sw s3, 12(sp)
        sw s4, 16(sp)
        sw s5, 20(sp)
        sw ra, 24(sp)

        la s0, tilemap  # endereco do tilemap
        mv s5, s0       # tile atual
        addi s5, s5, 8  # pula 2 words de dimensao

        mv s1, zero     # i
        lw s2, (s0)     # linhas
        lw s4, 4(s0)    # colunas
P_IF1_LOOP_LINHAS:
        # se i >= linhas, sai
        bge s1, s2, P_IF1_CONT

        mv s3, zero     # j

P_IF1_LOOP_COLUNAS:

        # se j >= colunas, sai
        bge s3, s4, P_IF1_LOOP_LINHAS_CONT

        li t0, TAMANHO_TILE
        MULTIPLY(a1, t0, s1)    # Y absoluto
        MULTIPLY(a0, t0, s3)    # X absoluto

        # pega a posicao da camera
        la t0, camera
        lw t1, camera_x(t0)
        lw t2, camera_y(t0)

        sub a2, a1, t2          # Y relativo ah camera
        sub a1, a0, t1          # X relativo ah camera
        lb a0, (s5)             # tipo do tile
        lw a3, textura_mapa     # textura do mapa
        jal PROC_IMPRIMIR_TILE  # imprime o tile

        addi s5, s5, 1          # avanca pro proximo tile

        addi s3, s3, 1
        j P_IF1_LOOP_COLUNAS

P_IF1_LOOP_LINHAS_CONT:
        addi s1, s1, 1
        j P_IF1_LOOP_LINHAS

P_IF1_CONT:

P_IF1_RET:
        lw s0, (sp)
        lw s1, 4(sp)
        lw s2, 8(sp)
        lw s3, 12(sp)
        lw s4, 16(sp)
        lw s5, 20(sp)
        lw ra, 24(sp)
        addi sp, sp, 28
        ret