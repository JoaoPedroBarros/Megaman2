# entidade que modela o projetil inimigo. Fiz em classes separadas
# para ser mais facil tratar troca de sprites e colisao com o jogador

.data

PROJETIL_INIMIGO.struct:

.eqv PROJETIL_INIMIGO.TAMANHO_STRUCT 0

# Argumentos:

# a0 - struct basica
# a1 - X (em Q0)
# a2 - Y (em Q0)

.text

PROJETIL_INIMIGO.NOVO:

    slli a1, a1, 12
    slli a2, a2, 12
    sw a1, entidade.X_Q12(a0)
    sw a2, entidade.Y_Q12(a0)

    li t0, 5
    slli t0, t0, 12
    sw t0, entidade.VELOCIDADE_X_Q12(a0)
    sw zero, entidade.VELOCIDADE_Y_Q12(a0)

    li t0, 1
    sw zero, entidade.COLIDIVEL(a0)
    sw t0, entidade.HOSTIL(a0)

    li t0, FLAG_ENTIDADE_IGNORAR_PLATAFORMAS
    sw t0, entidade.FLAGS(a0)

    li t0, 16
    sw t0, entidade.ALTURA(a0)
    sw t0, entidade.LARGURA(a0)

    ret

PROJETIL_INIMIGO.PROC:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0

    jal PROC_MOVER_ENTIDADE

    lw t0, entidade.VELOCIDADE_X_Q12(s0)
    snez a0, t0

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

PROJETIL_INIMIGO.DRAW:

    addi sp, sp, -4
    sw ra, 0(sp)

    mv t0, a0
    la a0, sprite_feitico6
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

    li a3, 16
    li a4, 16

    jal PROC_IMPRIMIR_TEXTURA

    lw ra, (sp)
    addi sp, sp, 4
    ret

PROJETIL_INIMIGO.COLISAO:

    addi sp, sp, -4
    sw ra, 0(sp)

    lw t0, entidade.TIPO(a1)
    li t1, ENTIDADE_JOGADOR
    bne t0, t1, PROJETIL_INIMIGO.COLISAO._VIVO

PROJETIL_INIMIGO.COLISAO._MORTO:

    mv a0, zero
    j PROJETIL_INIMIGO.COLISAO._RET

PROJETIL_INIMIGO.COLISAO._VIVO:

    li a0, 1

PROJETIL_INIMIGO.COLISAO._RET:

    lw ra, 0(sp)
    addi sp, sp, 4
    ret