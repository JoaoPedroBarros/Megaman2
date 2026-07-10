# procedimento para imprimir a GUI do boss, com seu nome e sua vida atual

# Argumentos
#       a0 - struct do boss

PROC_RENDERIZAR_GUI_BOSS:
    addi sp, sp, -12
    sw ra, (sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    mv s0, a0       # salva a struct do boss e sua struct especifica
    lw s1, entidade.STRUCT_ESPECIFICA(s0)

P_RG1_IMPRIMIR_BARRA_DE_VIDA_BOSS:

    lw t0, BOSS.VIDA_MAXIMA(s1)
    lw t1, BOSS.VIDA(s1)

    li t2, 100
    mul t1, t1, t2
    div t1, t1, t0  # pega a porcentagem de vida do jogador

    li a0, 0x0F           # barra vermelha
    li a1, 296          # x1 = 16
    li a3, 300           # x2 = 20
    li a4, 190            # y2 = 200
    sub a2, a4, t1        # y1 = 200 - % 
    jal PROC_IMPRIMIR_RETANGULO

    li a0, 0xFF
    li a1, 296
    li a2, 90
    li a3, 300
    li a4, 190
    li a5, 1        # grossura 1
    jal PROC_IMPRIMIR_OUTLINE       # imprime um outline ao redor

P_RG1_BOSS_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret

