# Entidade que modela o jogador, seguindo o padrao de exemplo.s

.data

# Struct especifica do jogador (perguntar depois a relacao com a struct basica)

JOGADOR.struct:
    .eqv JOGADOR.VIDA 0
    .eqv JOGADOR.MUNICAO 1 
    .eqv JOGADOR.MARCADOR_ANIMACAO 2
    .eqv JOGADOR.DIRECAO 3
    .eqv JOGADOR.COOLDOWN_PROJETIL 4

.eqv JOGADOR.TAMANHO_STRUCT 5

# limitar vida e municao em 10. Portanto, um byte deve ser suficiente

# o marcador_animacao referencia o inicio do sprite atual. No caso do jogador, eh interessante
# associa-lo ao pool do teclado, entao, apos uma entrada no teclado, incrementa-se em 1.

# a direcao serve para mudar o sprite a depender para onde o jogador esta olhando. Se for 0, aponta para os sprites
# da direita. Caso contrario, para os da esquerda

# informacao do maximo que a camera pode ir sem sair do mapa
X_maximo_camera_mapa: .word 0
Y_maximo_camera_mapa: .word 0

.text

# Argumentos:
# a0 - struct basica
# a1 - X
# a2 - Y

JOGADOR.NOVO:
    slli a1, a1, 12     # coloca em q12
    slli a2, a2, 12     # coloca em q12
    sw a1, entidade.X_Q12(a0)
    sw a2, entidade.Y_Q12(a0)

    li t0, 32
    sw t0, entidade.ALTURA(a0)
    sw t0, entidade.LARGURA(a0)
    sw zero, entidade.COLIDIVEL(a0)
    sw zero, entidade.HOSTIL(a0)

    lw t0, entidade.STRUCT_ESPECIFICA(a0)

    li t1, 10
    sb t1, JOGADOR.VIDA(t0)

    sb zero, JOGADOR.MARCADOR_ANIMACAO(t0)
    sb zero, JOGADOR.DIRECAO(t0)
    sb zero, JOGADOR.COOLDOWN_PROJETIL(t0)
    
    sw zero, entidade.NO_CHAO(a0)

    # guarda os limites do mapa
    la t0, tilemap
    lw t1, (t0)
    lw t0, 4(t0)
    li t2, TAMANHO_TILE
    MULTIPLY(t0, t0, t2)
    MULTIPLY(t1, t1, t2)
    li t2, CENTRO_VGA_X
    sub t0, t0, t2
    li t2, CENTRO_VGA_Y
    sub t1, t1, t2

    sw t0, X_maximo_camera_mapa, t2
    sw t1, Y_maximo_camera_mapa, t2

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

    jal PROC_PROCESSAR_ENTRADAS # chama procedimento para processar as entradas e aplicar no objeto do jogador

    mv a0, s0
    li a1, GRAVIDADE_PADRAO
    jal PROC_APLICAR_GRAVIDADE

    mv a0, s0
    lb t0, JOGADOR.COOLDOWN_PROJETIL(a0)
    addi t0, t0, 1
    li t1, 10
    bgt t0, t1, NO_UPDATE_COOLDOWN
    sb t0, JOGADOR.COOLDOWN_PROJETIL(a0)
    safe_print_int_ln(t0)

NO_UPDATE_COOLDOWN: 

    mv a0, s0
    jal PROC_APLICAR_MOVIMENTACAO   # move com base na velocidade

    lw a0, entidade.X_Q12(s0)
    lw a1, entidade.Y_Q12(s0)
    srai a0, a0, 12
    srai a1, a1, 12
    jal JOGADOR._CORRIGIR_CAMERA
    jal PROC_POSICIONAR_CAMERA # posiciona a camera no jogador

    lw t0, entidade.STRUCT_ESPECIFICA(s0)
    lb t1, JOGADOR.VIDA(t0) # carrega a vida

    li a0, 1
    bgt t1, zero, JOGADOR_VIVE # se a vida for menor que 0, o jogador estah morto e retorna a0. Pode-se fazer diretamente com uma ecall
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
    lw a1, entidade.X_Q12(t0)
    lw a2, entidade.Y_Q12(t0)

    # pega o valor inteiro
    srai a1, a1, 12
    srai a2, a2, 12

    la t3, camera
    lw t1, camera_x(t3)
    lw t2, camera_y(t3)
    sub a1, a1, t1
    sub a2, a2, t2

    li a3, 32
    li a4, 32

    addi a0, a0, 8 

    jal PROC_IMPRIMIR_TEXTURA

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# Argumentos:
# a0 - X (inteiro)
# a1 - Y (inteiro)
#
# Retornos : 
# a0 - X inteiro mais proximo sem que a camera nao saia do mapa
# a1 - Y inteiro mais proximo sem que a camera nao saia do mapa

JOGADOR._CORRIGIR_CAMERA:
    addi sp, sp, -12
    sw ra, (sp)
    sw a1, 4(sp)

    # nao deixa a camera sair pela direita ou esquerda

    # a0 - X carregado
    lw a1, X_maximo_camera_mapa
    jal PROC_MIN

    # a0 - X parcialmente corrigido
    li a1, CENTRO_VGA_X
    jal PROC_MAX

    sw a0, 8(sp)    # salva o novo X

    # nao deixa a camera sair por baixo ou por cima

    lw a0, 4(sp)    # Y argumento
    lw a1, Y_maximo_camera_mapa
    jal PROC_MIN

    # a0 - Y parcialmente corrigido
    li a1, CENTRO_VGA_Y
    jal PROC_MAX
    mv a1, a0       # guarda o novo Y para retorno

    lw ra, (sp)
    lw a0, 8(sp)    # recupera novo X para retorno
    addi sp, sp, 12
    ret