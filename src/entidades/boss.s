.data

BOSS.struct:
    .eqv BOSS.VIDA 0
    .eqv BOSS.VIDA_MAXIMA 4
    .eqv BOSS.CONTADOR_MOVESET 8 # a cada certa quantidade de gameloops, o boss escolhera um moveset aleatoriamente entre
    # os presets
    .eqv BOSS.CONTADOR_MOVIMENTACAO 9 # conta a localizacao atual na lemniscata
    .eqv BOSS.TIMER_MOVESET 13 # por simplicidade, todos os moveset terao a mesma duracao
    .eqv BOSS.TIMER_MOVIMENTACAO 15 # o chefe passarah 200 gameloops (mais ou menos 6 segundos) na movimentacao padrao

.eqv BOSS.TAMANHO_STRUCT 17

.text

# ARGUMENTOS

# a0 - tipo da entidade
# a1 - X em Q0
# a2 - Y em Q0

BOSS.NOVO:

    slli a1, a1, 12
    slli a2, a2, 12
    sw a1, entidade.X_Q12(a0)
    sw a2, entidade.Y_Q12(a0)

    li t0, 1
    sw t0, entidade.COLIDIVEL(a0)
    sw t0, entidade.HOSTIL(a0)

    definir_hitbox(a0, 5, 6, 22, 26)    # temporario! vai depender no sprite final

    # nao havera tratamento de gravidade para o chefe, visto que ele voarah

    lw t0, entidade.STRUCT_ESPECIFICA(a0)

    li t1, 1000 # o chefe tera 1000 de vida
    sw t1, BOSS.VIDA(t0)
    sw t1, BOSS.VIDA_MAXIMA(t0)

    sw zero, BOSS.CONTADOR_MOVIMENTACAO(t0)

    li t1, 200
    sh t1, BOSS.TIMER_MOVIMENTACAO(t0)
    sh zero, BOSS.TIMER_MOVESET(t0)

    ret

BOSS.PROC:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0

    jal BOSS.MOVESET_MANAGER

    mv a0, s0
    jal PROC_RENDERIZAR_GUI_BOSS

    li a0, 1

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8

    ret

BOSS.DRAW:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv t0, a0

    la a0, sprite_boss_rascunho
    addi a0, a0, 8

    lw a1, entidade.X_Q12(t0)
    lw a2, entidade.Y_Q12(t0)

    srai a1, a1, 12
    srai a2, a2, 12
               
    # dimensoes da textura
    li a3, 64
    li a4, 64

    jal PROC_IMPRIMIR_TEXTURA

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

## ARGUMENTOS

# a0 - struct basica do boss

## RETORNO

# nenhum

BOSS.MOVESET_MANAGER:

    addi sp, sp, -4
    sw ra, 0(sp)

    lw t1, entidade.STRUCT_ESPECIFICA(a0)
    lh t2, BOSS.TIMER_MOVIMENTACAO(t1)

    bgtz t2, BOSS.MOVIMENTACAO_PADRAO
    j BOSS.MOVESET_3

BOSS.MOVIMENTACAO_PADRAO:

    la t0, LEMNISCATA
    addi t2, t2, -1
    sh t2, BOSS.TIMER_MOVIMENTACAO(t1)

    lw t2, BOSS.CONTADOR_MOVIMENTACAO(t1)

    addi t2, t2, 1
    
    li t3, 159
    ble t2, t3, NAO_REINICIA_LEMNISCATA

    mv t2, zero

NAO_REINICIA_LEMNISCATA:

    sw t2, BOSS.CONTADOR_MOVIMENTACAO(t1)
    slli t2, t2, 2
    add t0, t0, t2

    lh t3, 0(t0)
    lh t4, 2(t0)

    slli t3, t3, 12
    slli t4, t4, 12

    sw t3, entidade.X_Q12(a0)
    sw t4, entidade.Y_Q12(a0)

    j BOSS.FINALIZA_PADRAO

BOSS.MOVESET_1:

    # vai para um lado da tela e cria uma barreira de fogo
    ret

BOSS.MOVESET_2:

    lh t3, BOSS.TIMER_MOVESET(t1) 
    ret

BOSS.MOVESET_3:

    lh t3, BOSS.TIMER_MOVESET(t1)
    bgtz t3, SEM_CORRECAO_TIMER_MOVESET_3

    li t0, 128
    slli t0, t0, 12
    sw t0, entidade.X_Q12(a0)

    li t0, 88
    slli t0, t0, 12
    sw t0, entidade.Y_Q12(a0)

    sw zero, BOSS.CONTADOR_MOVIMENTACAO(t1)

    li t3, 100
    sh t3, BOSS.TIMER_MOVESET(t1)

SEM_CORRECAO_TIMER_MOVESET_3:

    addi t3, t3, -1
    sh t3, BOSS.TIMER_MOVESET(t1)

    li t4, 30
    remu t4, t3, t4
    bnez t4, NAO_GERA_MINION

    li a0, ENTIDADE_SCHNOZ
    li a1, 160
    li a2, 140

    jal PROC_ADICIONAR_ENTIDADE
    
    mv a1, s0
    lw t1, entidade.STRUCT_ESPECIFICA(a1)
    lh t3, BOSS.TIMER_MOVESET(t1)

    li t4, 45
    remu t4, t3, t4
    bnez t4, NAO_GERA_MINION

    lw t2, entidade.STRUCT_ESPECIFICA(a0)
    lb t4, SCHNOZ.DIRECAO(t2)
    sub t4, zero, t4
    sb t4, SCHNOZ.DIRECAO(t2)

NAO_GERA_MINION:
    
    beqz t3, VOLTA_MOVIMENTACAO_PADRAO

    j BOSS.FINALIZA_PADRAO

VOLTA_MOVIMENTACAO_PADRAO:

    li t3, 200
    sh t3, BOSS.TIMER_MOVIMENTACAO(t1)

BOSS.FINALIZA_PADRAO:

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

BOSS.COLISAO:

    addi sp, sp, -4
    sw ra, (sp)

    lw t0, entidade.TIPO(a1)
    li t1, ENTIDADE_PROJETIL_COMUM
    beq t0, t1, BOSS.COLISAO._PROJETIL_COMUM

    j BOSS.COLISAO._VIVO

BOSS.COLISAO._PROJETIL_COMUM:

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lw t1, BOSS.VIDA(t0)
    addi t1, t1, PROJETIL_COMUM.DANO
    sw t1, BOSS.VIDA(t0)
    sgtz a0, t1
    j BOSS.COLISAO._RET

BOSS.COLISAO._VIVO:
    li a0, 1
    
BOSS.COLISAO._RET:
    lw ra, (sp)
    addi sp, sp, 4
    ret



