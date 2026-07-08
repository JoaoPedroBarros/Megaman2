# classe que modela o jumper, inimigo que pula e atira

.data

# struct especifica do jumper

JUMPER.struct:
    .eqv JUMPER.VIDA 0 # a vida serah um numero Q12, por isso eh uma word
    .eqv JUMPER.COOLDOWN_MOVIMENTO 4 # contador para pegar o tempo do pulo
    .eqv JUMPER.DIRECAO 5 # fala para onde o brabo estah olhando
    
.eqv JUMPER.TAMANHO_STRUCT 6

.text

# ARGUMENTOS

# a0 - tipo da entidade
# a1 - X em Q0
# a2 - Y em Q0

JUMPER.NOVO:

    slli a1, a1, 12 # transforma ambas as coordenadas em Q12
    slli a2, a2, 12
    sw a1, entidade.X_Q12(a0) # armazena os valores na struct basica
    sw a2, entidade.Y_Q12(a0)

    definir_hitbox(a0, 8, 6, 17, 26)    # temporario! deve mudar de acordo com o novo sprite

    li t0, 1
    sw t0, entidade.COLIDIVEL(a0) # o inimigo serah colidivel
    sw t0, entidade.HOSTIL(a0) # o inimigo serah hostil
    sw t0, entidade.NO_CHAO(a0) # o inimigo comecarah no chao

    lw t0, entidade.STRUCT_ESPECIFICA(a0) # carrega a struct especifica

    li t1, 40 # o jumper terah um pouco menos de vida, visto que tem movimentacao mais complexa
    slli t1, t1, 12
    sw t1, JUMPER.VIDA(t0)
    sb zero, JUMPER.COOLDOWN_MOVIMENTO(t0)

    li t1, 1
    sb t1, JUMPER.DIRECAO(t0) # comeca olhando para a direita

    # o contador comeca em 0. Ao chegar em 10 e em 20, atira um projetil. No 21, faz um pulo e reinicia o counter
    # para zero quando identificar colisao com o chao.

    ret

JUMPER.PROC:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0
    
    lw t0, entidade.STRUCT_ESPECIFICA(s0)
    lb t1, JUMPER.COOLDOWN_MOVIMENTO(t0) # analisa se o jumper deve atualizar as velocidades ou nao

    li t2, 20
    bne t1, t2, JUMPER_PULA # se nao for igual a 20, nao realiza a atualizacao de movimento

    mv a0, s0
    jal JUMPER.PULA # metodo que atualiza as velocidades pro salto

    lw t0, entidade.STRUCT_ESPECIFICA(s0) # 
    li t1, 0
    sb t1, JUMPER.COOLDOWN_MOVIMENTO(t0)

    lw a1, entidade.X_Q12(s0)
    srai a1, a1, 12         # corrige para inteiro
    lw a2, entidade.Y_Q12(s0)
    srai a2, a2, 12         # corrige para inteiro
    addi a1, a1, entidade.HITBOX_LARGURA #??????
    li a0, ENTIDADE_PROJETIL_INIMIGO
    jal PROC_ADICIONAR_ENTIDADE

    lw t0, entidade.STRUCT_ESPECIFICA(s0)
    lb t1, JUMPER.DIRECAO(t0)

    lw t2, entidade.VELOCIDADE_X_Q12(a0)
    mul t2, t1, t2
    sw t2, entidade.VELOCIDADE_X_Q12(a0)

JUMPER_PULA:

    lw t0, entidade.STRUCT_ESPECIFICA(s0)
    lb t1, JUMPER.COOLDOWN_MOVIMENTO(t0)
    addi t1, t1, 1
    sb t1, JUMPER.COOLDOWN_MOVIMENTO(t0)

    lw t1, entidade.NO_CHAO(s0)
    bnez t1, SEM_ATUALIZACAO_VELOCIDADE

    lw t1, entidade.VELOCIDADE_X_Q12(s0)
    li t2, 500
    lb t3, JUMPER.DIRECAO(t0)
    mul t2, t2, t3
    add t1, t1, t2
    sw t1, entidade.VELOCIDADE_X_Q12(s0)

    lw t1, entidade.VELOCIDADE_Y_Q12(s0)
    li t2, 5000
    add t1, t1, t2
    sw t1, entidade.VELOCIDADE_Y_Q12(s0)

SEM_ATUALIZACAO_VELOCIDADE:

    mv a0, s0
    jal PROC_MOVER_ENTIDADE

    
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    li a0, 1
    ret

JUMPER.DRAW:

    addi sp, sp, -4
    sw ra, 0(sp)

    mv t0, a0

    la a0, sprite_bruxa_feitico1 # urgente: trocar os sprites
    addi a0, a0, 8

    lw a1, entidade.X_Q12(t0)
    lw a2, entidade.Y_Q12(t0)

    srai a1, a1, 12
    srai a2, a2, 12

    # corrige posicao x e y para ser impresso relativo ah camera
    la t3, camera
    lw t1, camera_x(t3)
    lw t2, camera_y(t3)
    sub a1, a1, t1          
    sub a2, a2, t2        
        
    # dimensoes da textura
    li a3, 32 
    li a4, 32

    lw t1, entidade.STRUCT_ESPECIFICA(t0)
    lb t2, JUMPER.DIRECAO(t1)
    bltz t2, JUMPER.DRAW._INVERTIDO    # imprime para o outro lado se direcao = -1

    jal PROC_IMPRIMIR_TEXTURA
    j JUMPER.DRAW._RET

JUMPER.DRAW._INVERTIDO:
    jal PROC_IMPRIMIR_TEXTURA_INVERTIDA

JUMPER.DRAW._RET:

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

JUMPER.PULA:

    lw t0, entidade.NO_CHAO(a0)
    beqz t0, JUMPER_PULA_RETORNO      # nao deixa pular se estiver no ar

    lw t1, entidade.VELOCIDADE_Y_Q12(a0)
    li t0, -10
    slli t0, t0, 12
    add t1, t0, t1
    sw t1, entidade.VELOCIDADE_Y_Q12(a0)

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lb t2, JUMPER.DIRECAO(t0)

    lw t1, entidade.VELOCIDADE_X_Q12(a0)
    li t0, 2
    slli t0, t0, 12
    mul t0, t0, t2
    add t1, t0, t1
    sw t1, entidade.VELOCIDADE_X_Q12(a0)

    sub t2, zero, t2
    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    sb t2, JUMPER.DIRECAO(t0)

    sw zero, entidade.NO_CHAO(a0)

JUMPER_PULA_RETORNO:

    ret

JUMPER.COLISAO:
    
    addi sp, sp, -4
    sw ra, 0(sp)

    lw t0, entidade.TIPO(a1)
    li t1, ENTIDADE_PROJETIL_COMUM
    bne t0, t1, JUMPER.COLISAO._VIVO

JUMPER.COLISAO._MORTO:

    mv a0, zero
    j JUMPER.COLISAO._RET

JUMPER.COLISAO._VIVO:

    li a0, 1

JUMPER.COLISAO._RET:

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

