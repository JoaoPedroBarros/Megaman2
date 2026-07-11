# metodos de animacao de jogador

# PARAMETROS

# a0 - struct do jogador

# RETORNO

# a0 - referencia pro sprite escolhido

# os procedimentos a seguir modificam, a depender da passagem do gameloop, para qual sprite esta apontando.

PROC_ANIMACAO_JOGADOR:

    lw t0, entidade.STRUCT_ESPECIFICA(a0) # carrega a struct especifica do jogador

# aqui, temos uma hierarqua de sprites. Montei para que nao houvesse problemas visuais, como o jogador
# ao atirar, ficar idle em pleno voo. 

    lb t1, JOGADOR.FLAG_VASSOURA(t0)
    bgtz t1, RETORNA_SPRITE_VASSOURA_JOGADOR # ve se o jogador estah usando a vassoura

    lw t1, entidade.VELOCIDADE_Y_Q12(a0)
    bltz t1, RETORNA_SPRITE_PULO # ve se o jogador estah pulando
    bgtz t1, RETORNA_SPRITE_QUEDA # ve se o jogador estah em queda

CORRECAO_ERRO_VELOCIDADE_Y:

    lb t1, JOGADOR.COOLDOWN_PROJETIL(t0) 
    li t2, 10
    bne t1, t2, RETORNA_SPRITE_ATIRANDO_JOGADOR # ve se o jogador estah atirando. Permanece durante os 10 loops de cooldown do projetil

    lw t1, entidade.VELOCIDADE_X_Q12(a0)
    bnez t1, RETORNA_SPRITE_MOVIMENTACAO_JOGADOR # ve se o personagem estah andando

    j RETORNA_SPRITE_IDLE_JOGADOR # se nao for nenhum dos acimas, estah parado. Logo, retorna o idle

RETORNA_SPRITE_VASSOURA_JOGADOR:

    la a0, sprite_bruxa_voando # endereco do sprite da vassoura
    j PROC_ANIMACAO_JOGADOR_RET

RETORNA_SPRITE_ATIRANDO_JOGADOR:

    la a0, sprite_bruxa_feitico5 # endereco do sprite do tiro
    j PROC_ANIMACAO_JOGADOR_RET

RETORNA_SPRITE_PULO:

    la a0, sprite_bruxa_pulo5 # endereco do sprite de pulo
    j PROC_ANIMACAO_JOGADOR_RET

RETORNA_SPRITE_QUEDA:

    li t2, 2048 # tive que fazer uma gambiarra aqui pq, quando no chao, a velocidade alterna entre 0 e 2048. Assim, o personagem ficava
    # alternando o sprite de queda e o de movimentacao
    beq t1, t2, CORRECAO_ERRO_VELOCIDADE_Y # volta para as comparacaos
    la a0, sprite_queda # caso contrario, referencia o endereco de sprite de queda
    j PROC_ANIMACAO_JOGADOR_RET

RETORNA_SPRITE_MOVIMENTACAO_JOGADOR:

    lb t1, JOGADOR.MARCADOR_ANIMACAO(t0) # marcador para saber qual sprite de movimentacao apontar
    # vai de 0 a 3, pois sao 4 sprites

    lb t2, JOGADOR.COOLDOWN_MOVIMENTACAO(t0) # cooldown para trocar os sprites. Sem isso, avanca rapido demais
    bnez t2, SEM_CORRECAO_MARCADOR_ANIMACAO # nao atualiza o sprite se o cooldown nao tiver acabado

    # se o cooldown tiver acabado, reinicia o timer

    li t2, 7
    sb t2, JOGADOR.COOLDOWN_MOVIMENTACAO(t0)

    addi t1, t1, 1 # e atualizao sprite

    li t3, 3
    ble t1, t3, SEM_CORRECAO_MARCADOR_ANIMACAO # mantem o marcador na range 0-3
    mv t1, zero

SEM_CORRECAO_MARCADOR_ANIMACAO:

    sb t1, JOGADOR.MARCADOR_ANIMACAO(t0) # atualiza o marcador

    addi t2, t2, -1
    sb t2, JOGADOR.COOLDOWN_MOVIMENTACAO(t0) # decrementa o cooldown

    la a0, sprite_bruxa_andando1 # referencia o endereco e incrementa para chegar ao sprite desejado
    li t2, 1024
    mul t2, t1, t2
    add a0, a0, t2

    j PROC_ANIMACAO_JOGADOR_RET

RETORNA_SPRITE_IDLE_JOGADOR:

    la a0, sprite_bruxa_feitico1 # referencia ao endereco idle

PROC_ANIMACAO_JOGADOR_RET:

    ret

