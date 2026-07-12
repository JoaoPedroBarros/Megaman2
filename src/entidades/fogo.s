# entidade que modela um tile de explosao do boss. Acho melhor que modificar o tilemap, visto que teriamos que mudar
# tanto o visual quanto o de colisao, tendo muitos acessos ah memoria

.data

FOGO.struct:

    .eqv TIMER 0

.eqv FOGO.TAMANHO_STRUCT 1

# ARGUMENTOS

# a0 - tipo da entidade
# a1 - X em Q0
# a2 - Y em Q0

.text

FOGO.NOVO:

    slli a1, a1, 12
    slli a2, a2, 12

    sw a1, entidade.X_Q12(a0)
    sw a2, entidade.Y_Q12(a0)

    li t0, 1
    sw t0, entidade.COLIDIVEL(a0)
    sw t0, entidade.HOSTIL(a0)

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    li t1, 20
    sb t0, FOGO.TIMER(t0)

    ret

FOGO.PROC:

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lb t1, FOGO.TIMER(t0)
    sltz a0, t1
    ret

FOGO.DRAW:
    
    ret

FOGO.COLISAO:

    ret






