# Entidade que modela o jogador, seguindo o padrao de exemplo.s

.data

# Struct especifica do jogador (perguntar depois a relacao com a struct basica)

JOGADOR.struct:
    .eqv JOGADOR.VIDA 0
    .eqv JOGADOR.MUNICAO 1 
    .eqv JOGADOR.MARCADOR_ANIMACAO 2
    .eqv JOGADOR.DIRECAO 3

JOGADOR.TAMANHO_STRUCT: .word 4

# limitar vida e municao em 10. Portanto, um byte deve ser suficiente

# o marcador_animacao referencia o inicio do sprite atual. No caso do jogador, eh interessante
# associa-lo ao pool do teclado, entao, apos uma entrada no teclado, incrementa-se em 1.

# a direcao serve para mudar o sprite a depender para onde o jogador esta olhando. Se for 0, aponta para os sprites
# da direita. Caso contrario, para os da esquerda

.text

# Argumentos:
# a0 - struct basica
# a1 - X
# a2 - Y

JOGADOR.NOVO:

    sw a1, entidade.X(a0)
    sw a2, entidade.Y(a0)

    li t0, 32
    sw t0, entidade.ALTURA(a0)
    sw t0, entidade.LARGURA(a0)
    sw zero, entidade.COLIDIVEL(a0)
    sw zero, entidade.HOSTIL(a0)

    lw t0, entidade.STRUCT_ESPECIFICA(a0)

<<<<<<< HEAD
    li t1, 10
    sb t1, JOGADOR.VIDA(t0)
    sb t1, JOGADOR.MUNICAO(t0)
=======
    li t1, 100
    sw t1, JOGADOR.VIDA(t0)
    sw t1, JOGADOR.MUNICAO(t0)

    li t1, 0
    sw t1, JOGADOR.MARCADOR_ANIMACAO(t0)
>>>>>>> c3b8ccb14f509d7457b47185eb223a12dcbd629d

    sb zero, JOGADOR.MARCADOR_ANIMACAO(t0)
    sb zero, JOGADOR.DIRECAO(t0)

    ret

# Argumentos:

# a0 - struct basica

# Retorno:

# a0 - jogador estah vivo (ou nao)

JOGADOR.PROC:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0 # aqui, deve-se manter referencia ah struct basica

    lw t0, entidade.STRUCT_ESPECIFICA(s0)
    lw t1, JOGADOR.VIDA(t0)

    li a0, 1
    bgt t1, zero, JOGADOR_VIVE
    li a0, 0

JOGADOR_VIVE:

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

JOGADOR.DRAW:

    addi sp, sp, -4
    sw ra, 0(sp)

# por enquanto, como so temos um sprite, nao vou adicionar a direcao e a animacao. No entanto, eh apenas uma
# aritmetica de ponteiros

    mv t0, a0
    la a0, sprite_bruxa
    lw a1, entidade.X(t0)
    lw a2, entidade.Y(t0)

    la t3, camera
    lw t1, camera_x(t3)
    lw t2, camera_y(t3)
    sub a1, a1, t1
    sub a2, a2, t2

    li a3, 32
    li a4, 32

<<<<<<< HEAD
    addi a0, a0, 8
=======
    addi a0, a0, 8       # pula words de dimensao
>>>>>>> c3b8ccb14f509d7457b47185eb223a12dcbd629d

    jal PROC_IMPRIMIR_TEXTURA

    li a0, 10
    li a7, 1
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

    

















         
