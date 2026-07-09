.data

BOSS.struct:
    .eqv BOSS.VIDA 0
    .eqv BOSS.VIDA_MAXIMA 4
    .eqv BOSS.CONTADOR_MOVESET 8 # a cada certa quantidade de gameloops, o boss escolhera um moveset aleatoriamente entre
    # os presets
    .eqv BOSS.CONTADOR_MOVIMENTACAO 9 # conta a localizacao atual na lemniscata

.eqv BOSS.TAMANHO_STRUCT 13

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

    # nao havera tratamento de gravidade para o chefe, visto que ele voarah

    lw t0, entidade.STRUCT_ESPECIFICA(a0)

    li t1, 1000 # o chefe tera 1000 de vida
    sw t1, BOSS.VIDA(t0)
    sw t1, BOSS.VIDA_MAXIMA(t0)

    sb zero, BOSS.CONTADOR_MOVIMENTACAO(t0)

    li t1, 2
    sb t1, BOSS.CONTADOR_MOVESET(t0)

    ret

BOSS.PROC:

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0


    jal BOSS.MOVIMENTACAO_PADRAO

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

    la a0, sprite_bruxa_feitico1 # urgente: trocar os sprites
    addi a0, a0, 8

    lw a1, entidade.X_Q12(t0)
    lw a2, entidade.Y_Q12(t0)

    srai a1, a1, 12
    srai a2, a2, 12
               
    # dimensoes da textura
    li a3, 32
    li a4, 32

    jal PROC_IMPRIMIR_TEXTURA

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

## ARGUMENTOS

# a0 - struct basica do boss

## RETORNO

# nenhum

BOSS.MOVIMENTACAO_PADRAO:

    
    la t0, LEMNISCATA
    lw t1, entidade.STRUCT_ESPECIFICA(a0)
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

    # pega o lugar inicial, faz uma parabola e cria varias colunas de fogo.
    ret

BOSS.MOVESET_3:

    # cria minions mais fracos de fogo
    ret

BOSS.FINALIZA_PADRAO:

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



