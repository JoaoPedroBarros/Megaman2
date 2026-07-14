# classe que modela o jumper, inimigo que pula e atira

.data

# struct especifica do jumper

JUMPER.struct:

    .eqv JUMPER.VIDA 0
    .eqv JUMPER.ANIMACAO_CONTROLLER 4
    .eqv JUMPER.DIRECAO 8
    .eqv JUMPER.SPAWN 9
    .eqv JUMPER.COOLDOWN_MOVIMENTO 10
    
.eqv JUMPER.TAMANHO_STRUCT 11

.text

# ARGUMENTOS

# a0 - tipo da entidade
# a1 - X em Q0
# a2 - Y em Q0

JUMPER.NOVO:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    slli a1, a1, 12 # transforma ambas as coordenadas em Q12
    slli a2, a2, 12
    sw a1, entidade.X_Q12(a0) # armazena os valores na struct basica
    sw a2, entidade.Y_Q12(a0)

    definir_hitbox(a0, 8, 6, 17, 26)    # temporario! deve mudar de acordo com o novo sprite

    li t0, 1
    sw t0, entidade.COLIDIVEL(a0) # o inimigo serah colidivel
    sw t0, entidade.HOSTIL(a0) # o inimigo serah hostil

    lw t0, entidade.STRUCT_ESPECIFICA(a0) # carrega a struct especifica

    li t1, 25 # o jumper terah um pouco menos de vida, visto que tem movimentacao mais complexa
    sw t1, JUMPER.VIDA(t0)
    sb zero, JUMPER.COOLDOWN_MOVIMENTO(t0)

    li t1, 1
    sb t1, JUMPER.DIRECAO(t0) # comeca olhando para a direita

    mv s0, t0
    jal PROC_CRIAR_ANIMACAO_CONTROLLER
    sw a0, JUMPER.ANIMACAO_CONTROLLER(s0)

    li t1, 20
    sb t1, JUMPER.SPAWN(s0)

    # o contador comeca em 0. Ao chegar em 10 e em 20, atira um projetil. No 21, faz um pulo e reinicia o counter
    # para zero quando identificar colisao com o chao.

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8

    ret

JUMPER.PROC:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0

    lw t0, entidade.STRUCT_ESPECIFICA(s0)
    lb t1, JUMPER.SPAWN(t0)

    blez t1, CONT_JUMPER_0
    addi t1, t1, -1
    sb t1, JUMPER.SPAWN(t0)
    j JUMPER_SPAWNANDO

CONT_JUMPER_0:

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

JUMPER_SPAWNANDO:

    mv a0, s0
    jal PROC_ATUALIZAR_ANIMACAO_JUMPER

    mv a0, s0
    jal PROC_RECICLA_ENTIDADE

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8

    ret

JUMPER.DRAW:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0

    lw t1, entidade.STRUCT_ESPECIFICA(s0)
    lw a0, JUMPER.ANIMACAO_CONTROLLER(t1)
    jal PROC_OBTER_TEXTURA_ANIMACAO
    mv a5, a1   # guarda a paleta

    lw a1, entidade.X_Q12(s0)
    lw a2, entidade.Y_Q12(s0)

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

    lw t1, entidade.STRUCT_ESPECIFICA(s0)
    lb t2, JUMPER.DIRECAO(t1)
    bgtz t2, JUMPER.DRAW._INVERTIDO    # imprime para o outro lado se direcao = -1

    jal PROC_IMPRIMIR_TEXTURA_CI4
    j JUMPER.DRAW._RET

JUMPER.DRAW._INVERTIDO:
    jal PROC_IMPRIMIR_TEXTURA_INVERTIDA_CI4

JUMPER.DRAW._RET:

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
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
    addi sp, sp, -8
    sw ra, (sp)
    sw s0, 4(sp)

    lw t0, entidade.TIPO(a1)
    li t1, ENTIDADE_PROJETIL_COMUM
    beq t0, t1, JUMPER.COLISAO._PROJETIL_COMUM

    li t1, ENTIDADE_PROJETIL_VENTO
    beq t0, t1, JUMPER.COLISAO._PROJETIL_VENTO

    j JUMPER.COLISAO._VIVO
    # se o tipo de entidade eh um projetil comum, morre
JUMPER.COLISAO._PROJETIL_COMUM:

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lw t1, JUMPER.VIDA(t0)
    addi t1, t1, PROJETIL_COMUM.DANO
    sw t1, JUMPER.VIDA(t0)

    # vive se vida > 0, morre caso contrario
    bgtz t1, JUMPER.COLISAO._VIVO
    j JUMPER.COLISAO._MORTO

JUMPER.COLISAO._PROJETIL_VENTO:
    lw t0, entidade.STRUCT_ESPECIFICA(a0)

    li t1, 16384
    lw t3, entidade.VELOCIDADE_X_Q12(a1)

    bgtz t3, SEM_CORRECAO_KNOCKBACK_VENTO_JUMPER
    sub t1, zero, t1

SEM_CORRECAO_KNOCKBACK_VENTO_JUMPER:

    lw t2, entidade.VELOCIDADE_X_Q12(a0)
    add t2, t2, t1
    sw t1, entidade.VELOCIDADE_X_Q12(a0)

    lw t1, JUMPER.VIDA(t0)
    addi t1, t1, -10
    sw t1, JUMPER.VIDA(t0)
    bgtz t1, JUMPER.COLISAO._VIVO
    # morre se vida < 0

JUMPER.COLISAO._MORTO:
    # rola para ver se vai spawnar um powerup
    # a0 (entidade) carregado
    mv s0, a0

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lw a0, JUMPER.ANIMACAO_CONTROLLER(t0)
    jal PROC_FREE

    mv a0, s0
    la a1, DROP_TABLE_JUMPER
    jal PROC_ROLAR_POWERUP

    la t0, MONSTER_CONTROLLER
    lb t1, (t0)
    addi t1, t1, -1
    sb t1, (t0)

    li a0, 0
    j JUMPER.COLISAO._RET

JUMPER.COLISAO._VIVO:

    li a0, 1
    
JUMPER.COLISAO._RET:
    lw ra, (sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

