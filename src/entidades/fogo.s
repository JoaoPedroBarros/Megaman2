# entidade que modela um tile de explosao do boss. Acho melhor que modificar o tilemap, visto que teriamos que mudar
# tanto o visual quanto o de colisao, tendo muitos acessos ah memoria

.data

FOGO.struct:

    .eqv FOGO.TIMER 0

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

    definir_hitbox(a0, 4, 3, 24, 26) 

    li t0, 1
    sw t0, entidade.COLIDIVEL(a0)
    sw t0, entidade.HOSTIL(a0)

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    li t1, 20
    sb t1, FOGO.TIMER(t0)

    ret

FOGO.PROC:

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lb t1, FOGO.TIMER(t0)
    addi t1, t1, -1
    sb t1, FOGO.TIMER(t0)
    sgtz a0, t1

    ret

FOGO.DRAW:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv t0, a0

    la a0, sprite_spawn
    addi a0, a0, 8

    lw a1, entidade.X_Q12(t0)
    lw a2, entidade.Y_Q12(t0)

    srai a1, a1, 12
    srai a2, a2, 12

    la t3, camera
    lw t1, camera_x(t3)
    lw t2, camera_y(t3)
    sub a1, a1, t1          
    sub a2, a2, t2   
               
    # dimensoes da textura
    li a3, 32
    li a4, 32

    la a5, sprite_spawn_paleta

    jal PROC_IMPRIMIR_TEXTURA_CI4

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

FOGO.COLISAO:

    ret






