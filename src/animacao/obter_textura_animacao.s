# PROC_OBTER_TEXTURA_ANIMACAO
#
# Dado um animation controller, retorna
# o index de impressao da sprite a ser
# renderizada.
#
# Argumento: a0 - animacao controller
# Retornos: 
#       a0 - endereco do primeiro byte a ser impresso
#       a1 - endereco da paleta atual

PROC_OBTER_TEXTURA_ANIMACAO:
        lw a1, struct_animacao_controller.PALETA(a0)
        lw t0, struct_animacao_controller.SPRITE(a0)
        lw t1, 0(t0)
        lw t2, 4(t0)
        lw t3, struct_animacao_controller.FRAME(a0)
        mul t2, t2, t1
        mul t3, t3, t2
        add a0, t0, t3
        addi a0, a0, 8  # pula dimensoes
        
        ret             

