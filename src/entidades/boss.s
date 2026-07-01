.data

BOSS.struct:
    .eqv BOSS.VIDA 0
    .eqv BOSS.CONTADOR_MOVESET 4 # a cada certa quantidade de gameloops, o boss escolhera um moveset aleatoriamente entre
    # os presets

.eqv BOSS.TAMANHO_STRUCT 5

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

    li t0, 64 # o boss deve ser um pouco maior que o personagem
    sw t0, entidade.ALTURA(a0)
    sw t0, entidade.LARGURA(a0)

    li t0, 1
    sw t0, entidade.COLIDIVEL(a0)
    sw t0, entidade.HOSTIL(a0)

    # nao havera tratamento de gravidade para o chefe, visto que ele voara

    li t1, 1000 #
    slli t1, t1, 12
    sw t1, BOSS.VIDA(t0)
    sb zero, BOSS.COOLDOWN_MOVESET(t0)

BOSS.PROC:

    ret

BOSS.DRAW:

    ret

BOSS.MOVESET_1:

    # vai para um lado da tela e cria uma barreira de fogo
    ret

BOSS.MOVESET_2:

    # pega o lugar inicial, faz uma parabola e cria varias colunas de fogo.
    ret

BOSS.MOVESET_3:

    # cria minions mais fracos de fogo
    ret