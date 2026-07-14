# Entidade que modela o inimigo basico, que simplesmente anda horizontalmente em uma direcao ate 
# colidir

.data

SCHNOZ.struct:

    .eqv SCHNOZ.ANIMACAO_CONTROLLER 0
    .eqv SCHNOZ.VIDA 4
    .eqv SCHNOZ.CONTADOR_KNOCKBACK 8
    .eqv SCHNOZ.DIRECAO 9
    .eqv SCHNOZ.SPAWN 10

.eqv SCHNOZ.TAMANHO_STRUCT 11

.eqv SCHNOZ.VELOCIDADE 4096 # 1 

.text

# Argumentos:
# a0 - struct basica;
# a1 - X
# a2 - Y

# Retorno:
# nenhum, apenas inicializa a struct com os valores iniciais

SCHNOZ.NOVO:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    slli a1, a1, 12 # passa para Q12
    slli a2, a2, 12
    sw a1, entidade.X_Q12(a0) # armazena na struct generica
    sw a2, entidade.Y_Q12(a0)

    definir_hitbox(a0, 8, 6, 17, 26)    # temporario! deve mudar de acordo com o novo sprite

    li t0, SCHNOZ.VELOCIDADE
    sw t0, entidade.VELOCIDADE_Y_Q12(a0)
    neg t0, t0
    sw t0, entidade.VELOCIDADE_X_Q12(a0)

    sw zero, entidade.FLAGS(a0) # nenhum comportamento especial de colisao!

    li t0, 1 # o inimigo serah colidivel e hostil
    sw t0, entidade.COLIDIVEL(a0)
    sw t0, entidade.HOSTIL(a0)

    lw t0, entidade.STRUCT_ESPECIFICA(a0)

    li t1, 50
    sw t1, SCHNOZ.VIDA(t0)

    li t1, 20
    sb t1, SCHNOZ.SPAWN(t0)

    la t1, jogador
    lw t1, 0(t1)
    lw t2, entidade.X_Q12(t1)
    lw t3, entidade.X_Q12(a0)

    ble t2, t3, SCHNOZ_SPAWNA_ESQUERDA
    li t1, 1
    j SCHNOZ_SPAWNA_DIREITA

SCHNOZ_SPAWNA_ESQUERDA:

    li t1, -1

SCHNOZ_SPAWNA_DIREITA:

    sb t1, SCHNOZ.DIRECAO(t0)
    sb zero, SCHNOZ.CONTADOR_KNOCKBACK(t0)

    mv s0, t0
    jal PROC_CRIAR_ANIMACAO_CONTROLLER
    sw a0, SCHNOZ.ANIMACAO_CONTROLLER(s0)

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

SCHNOZ.PROC:

# aqui, aplicaremos os procedimentos de movimentacao, gravidade e colisao para o inimigo
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0

    li t0, SCHNOZ.VELOCIDADE
    slli t0, t0, 2
    sw t0, entidade.VELOCIDADE_Y_Q12(a0)
    
    lw t1, entidade.STRUCT_ESPECIFICA(s0)
    lb t2, SCHNOZ.SPAWN(t1)

    blez t2, CONTINUAR_SCHNOZ_0
    addi t2, t2, -1
    sb t2, SCHNOZ.SPAWN(t1)
    j SCHNOZ_SPAWNANDO

CONTINUAR_SCHNOZ_0:

    lb t2, SCHNOZ.CONTADOR_KNOCKBACK(t1)
    bnez t2, SEM_CORRECAO_VELOCIDADE_SCHNOZ

    li t0, SCHNOZ.VELOCIDADE
    lb t2, SCHNOZ.DIRECAO(t1)
    mul t0, t0, t2
    sw t0, entidade.VELOCIDADE_X_Q12(s0)
    mv a0, s0
    jal PROC_COLISAO_SCHNOZ
    j CONTINUAR_SCHNOZ_1

SEM_CORRECAO_VELOCIDADE_SCHNOZ:

    addi t2, t2, -1
    sb t2, SCHNOZ.CONTADOR_KNOCKBACK(t1)

CONTINUAR_SCHNOZ_1:

    mv a0, s0
    jal PROC_MOVER_ENTIDADE

SCHNOZ_SPAWNANDO:

    mv a0, s0   
    jal PROC_ATUALIZAR_ANIMACAO_SCHNOZ

    mv a0, s0
    jal PROC_RECICLA_ENTIDADE

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

SCHNOZ.DRAW:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0

    lw t1, entidade.STRUCT_ESPECIFICA(s0)
    lw a0, SCHNOZ.ANIMACAO_CONTROLLER(t1)
    jal PROC_OBTER_TEXTURA_ANIMACAO

    beqz a0, SCHNOZ.DRAW._RET

    mv a5, a1   # paleta

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
    lb t2, SCHNOZ.DIRECAO(t1)
    bgtz t2, SCHNOZ.DRAW._INVERTIDO    # imprime para o outro lado se direcao = -1

    jal PROC_IMPRIMIR_TEXTURA_CI4
    j SCHNOZ.DRAW._RET

SCHNOZ.DRAW._INVERTIDO:
    jal PROC_IMPRIMIR_TEXTURA_INVERTIDA_CI4

SCHNOZ.DRAW._RET:

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret


# Argumentos (obrigatoriamente)
# a0 - struct basica de si mesmo
# a1 - struct basica daquele com quem colidiu
#
# Retorno (obrigatoriamente) 
# a0: se estah vivo (1) ou nao (0)
SCHNOZ.COLISAO:
    addi sp, sp, -8
    sw ra, (sp)
    sw s0, 4(sp)

    mv s0, a0

    lw t0, entidade.TIPO(a1)
    li t1, ENTIDADE_PROJETIL_COMUM
    beq t0, t1, SCHNOZ.COLISAO._PROJETIL_COMUM

    li t1, ENTIDADE_PROJETIL_VENTO
    beq t0, t1, SCHNOZ.COLISAO._PROJETIL_VENTO

    j SCHNOZ.COLISAO._VIVO

SCHNOZ.COLISAO._PROJETIL_COMUM:

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lw t1, SCHNOZ.VIDA(t0)
    addi t1, t1, PROJETIL_COMUM.DANO
    sw t1, SCHNOZ.VIDA(t0)

    # vive se vida > 0, morre caso contrario
    bgtz t1, SCHNOZ.COLISAO._VIVO
    j SCHNOZ.COLISAO._MORTO

SCHNOZ.COLISAO._PROJETIL_VENTO:
    lw t0, entidade.STRUCT_ESPECIFICA(a0)

    li t1, 16384
    lw t3, entidade.VELOCIDADE_X_Q12(a1)

    bgtz t3, SEM_CORRECAO_KNOCKBACK_VENTO_SCHNOZ
    sub t1, zero, t1

SEM_CORRECAO_KNOCKBACK_VENTO_SCHNOZ:

    sw t1, entidade.VELOCIDADE_X_Q12(a0)
    li t1, 10
    sb t1, SCHNOZ.CONTADOR_KNOCKBACK(t0)

    lw t1, SCHNOZ.VIDA(t0)
    addi t1, t1, -10
    sw t1, SCHNOZ.VIDA(t0)

    bgtz t1, SCHNOZ.COLISAO._VIVO # se vida > 0, vive
    # senao...

SCHNOZ.COLISAO._MORTO:

    # a0 (entidade) carregado
    la a1, DROP_TABLE_SCHNOZ # carrega a tabela do schnoz
    jal PROC_ROLAR_POWERUP

    lw t0, entidade.STRUCT_ESPECIFICA(s0)
    lw a0, SCHNOZ.ANIMACAO_CONTROLLER(t0)
    jal PROC_FREE

    la t0, MONSTER_CONTROLLER
    lb t1, (t0)
    addi t1, t1, -1
    sb t1, (t0)
    
    li a0, 0
    j SCHNOZ.COLISAO._RET

SCHNOZ.COLISAO._VIVO:
    li a0, 1
    
SCHNOZ.COLISAO._RET:
    lw ra, (sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret



    






