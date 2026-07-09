# PROC_RENDERIZAR_GUI
# Imprime a GUI padrao do jogador na tela

# Argumentos
#       a0 - struct do jogador

PROC_RENDERIZAR_GUI:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        mv s0, a0       # salva a struct do jogador
        lw s1, entidade.STRUCT_ESPECIFICA(s0)   # e a sua struct especifica

P_RG1_IMPRIMIR_BARRA_DE_VIDA:
        lb t0, JOGADOR.VIDA_MAXIMA(s1)
        lb t1, JOGADOR.VIDA(s1)

        li t2, 100
        mul t1, t1, t2
        div t1, t1, t0  # pega a porcentagem de vida do jogador

        li a0, 0x2D             # barra amarela
        li a1, 16               # x1 = 16
        li a3, 20               # x2 = 20
        li a4, 200              # y2 = 200
        sub a2, a4, t1          # y1 = 200 - % 
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0x00
        li a1, 16
        li a2, 100
        li a3, 20
        li a4, 200
        li a5, 1        # grossura 1
        jal PROC_IMPRIMIR_OUTLINE       # imprime um outline ao redor

P_RG1_IMPRIMIR_BARRA_DE_MUNICAO:
        lb t0, JOGADOR.MUNICAO_MAXIMA(s1)
        lb t1, JOGADOR.MUNICAO_PROJETIL_VENTO(s1)

        li t2, 100
        mul t1, t1, t2
        div t1, t1, t0  # pega a porcentagem da municao do jogador

        li a0, 0xF0             # barra azul
        li a1, 32               # x1 = 32
        li a3, 36               # x2 = 36
        li a4, 200              # y2 = 200
        sub a2, a4, t1          # y1 = 200 - % 
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0x00
        li a1, 32
        li a2, 100
        li a3, 36
        li a4, 200
        li a5, 1        # grossura 1
        jal PROC_IMPRIMIR_OUTLINE       # imprime um outline ao redor

P_RG1_IMPRIMIR_ICONE_VASSOURA:
        lh t0, JOGADOR.COOLDOWN_USO_VASSOURA(s1)
        lh t1, JOGADOR.TEMPO_USO_VASSOURA(s1)
        
        # se (tempo_uso_vassoura != 0) [vassoura em uso] || (cooldown_uso_vassoura != 0) [vassora nao disponivel]
        # nao imprime o icone de vassoura disponivel
        or t0, t0, t1 
        bnez t0, P_RG1_RET               

        la a0, sprite_bruxa
        addi a0, a0, 8
        li a1, 50
        li a2, 200
        li a3, 32
        li a4, 32
        jal PROC_IMPRIMIR_TEXTURA

P_RG1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret