# Entidade que modela o jogador, seguindo o padrao de exemplo.s

.data

# Struct especifica do jogador

JOGADOR.struct:
    .eqv JOGADOR.VIDA 0
    .eqv JOGADOR.VIDA_MAXIMA 1
    .eqv JOGADOR.MUNICAO 2
    .eqv JOGADOR.MARCADOR_ANIMACAO 3
    .eqv JOGADOR.DIRECAO 4
    .eqv JOGADOR.COOLDOWN_PROJETIL 5
    .eqv JOGADOR.TEMPO_USO_VASSOURA 6
    .eqv JOGADOR.COOLDOWN_USO_VASSOURA 8
    .eqv JOGADOR.FLAG_VASSOURA 10
    .eqv JOGADOR.TEMPORIZADOR_INVENCIBILIDADE 11
    .eqv JOGADOR.TEMPORIZADOR_IGNORAR_PLATAFORMA 12
    

.eqv JOGADOR.TAMANHO_STRUCT 13

.eqv JOGADOR.ACELERACAO_Q12        2048 # 0.5, por frame

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

    definir_hitbox(a0, 5, 6, 22, 26)
    
    sw zero, entidade.HOSTIL(a0)
    sw zero, entidade.FLAGS(a0)

    lw t0, entidade.STRUCT_ESPECIFICA(a0)

    li t1, 10
    sb t1, JOGADOR.VIDA(t0)
    sb t1, JOGADOR.VIDA_MAXIMA(t0)
    sb t1, JOGADOR.COOLDOWN_PROJETIL(t0)

    sb zero, JOGADOR.MARCADOR_ANIMACAO(t0)
    sb zero, JOGADOR.TEMPORIZADOR_IGNORAR_PLATAFORMA(t0)
    sw zero, entidade.NO_CHAO(a0)

    sh zero, JOGADOR.TEMPO_USO_VASSOURA(t0)
    sh zero, JOGADOR.COOLDOWN_USO_VASSOURA(t0)
    sb zero, JOGADOR.TEMPORIZADOR_INVENCIBILIDADE(t0)

    li t1, -1
    sb t1, JOGADOR.FLAG_VASSOURA(t0)

    li t1, 1
    sb t1, JOGADOR.DIRECAO(t0)
    sw t1, entidade.COLIDIVEL(a0)

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

    lw t0, entidade.STRUCT_ESPECIFICA(s0)
    lbu t1, JOGADOR.TEMPORIZADOR_INVENCIBILIDADE(t0)
    blez t1, JOGADOR.PROC._CONT0

    # se o jogador ainda estah invencivel, decrementa o tempo restante ateh ele nao estar
    addi t1, t1, -1
    sb t1, JOGADOR.TEMPORIZADOR_INVENCIBILIDADE(t0) 


JOGADOR.PROC._CONT0:
    lb t1, JOGADOR.FLAG_VASSOURA(t0)

    bgtz t1, SEM_GRAVIDADE

    # aplica gravidade
    lw t0, entidade.VELOCIDADE_Y_Q12(s0)
    li t1, GRAVIDADE_PADRAO
    add t0, t0, t1
    sw t0, entidade.VELOCIDADE_Y_Q12(s0)

SEM_GRAVIDADE:

    mv a0, s0
    jal JOGADOR.MODO_VASSOURA

    mv a0, s0
    jal JOGADOR.MORTE_QUEDA

    mv a0, s0

    lw t2, entidade.STRUCT_ESPECIFICA(s0)
    # Verificar se precisamos decrementar o temporazidor
    lb t0, JOGADOR.TEMPORIZADOR_IGNORAR_PLATAFORMA(t2)
    blez t0, JOGADOR.PROC.DESATIVAR_FLAG_IGNORAR_PLATAFORMAS

    addi t0, t0, -1 # temporizador--
    sb t0, JOGADOR.TEMPORIZADOR_IGNORAR_PLATAFORMA(t2)

JOGADOR.PROC.ATIVAR_FLAG_IGNORAR_PLATAFORMAS:   # ativa a flag se temporizador > 0
    lw t0, entidade.FLAGS(a0)
    ori t0, t0, FLAG_ENTIDADE_IGNORAR_PLATAFORMAS
    sw t0, entidade.FLAGS(a0)
    j JOGADOR.PROC.CONT

JOGADOR.PROC.DESATIVAR_FLAG_IGNORAR_PLATAFORMAS: # desativa caso contrario
    lw t0, entidade.FLAGS(a0)
    li t1, FLAG_ENTIDADE_IGNORAR_PLATAFORMAS
    not t1, t1
    and t0, t0, t1
    sw t0, entidade.FLAGS(a0)

JOGADOR.PROC.CONT:
    mv a0, s0
    lw t2, entidade.STRUCT_ESPECIFICA(s0)
    lbu t0, JOGADOR.COOLDOWN_PROJETIL(t2)
    addi t0, t0, 1
    li t1, 10
    bgt t0, t1, NO_UPDATE_COOLDOWN
    sb t0, JOGADOR.COOLDOWN_PROJETIL(t2)

NO_UPDATE_COOLDOWN:
    mv a0, s0
    jal PROC_MOVER_ENTIDADE   # move com base na velocidade

    mv a0, s0
    jal PROC_APLICAR_FRICCAO  # aplica friccao normal


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

    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a0
    lw t6, entidade.STRUCT_ESPECIFICA(s0)
    lbu t2, JOGADOR.TEMPORIZADOR_INVENCIBILIDADE(t6)
    andi t2, t2, 0x2
    seqz t2, t2
    beqz t2, JOGADOR.DRAW._RENDERIZAR_GUI   # se o jogador estah invencivel, faz ele piscar:
#                                             apenas imprime ele quando o n mod 4 == 2 | 3.

# por enquanto, como so temos um sprite, nao vou adicionar a direcao e a animacao. No entanto, eh apenas uma
# aritmetica de ponteiros

    lb t1, JOGADOR.COOLDOWN_PROJETIL(t6)
    addi t1, t1, -1
    li t2, 1024
    mul t1, t1, t2

    la a0, sprite_bruxa_feitico1
    add a0, a0, t1

    lw a1, entidade.X_Q12(s0)
    lw a2, entidade.Y_Q12(s0)

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

    lb t0, JOGADOR.DIRECAO(t6)
    bltz t0, JOGADOR.DRAW._INVERTIDO    # imprime para o outro lado se direcao = -1

    jal PROC_IMPRIMIR_TEXTURA
    j JOGADOR.DRAW._RENDERIZAR_GUI

JOGADOR.DRAW._INVERTIDO:
    jal PROC_IMPRIMIR_TEXTURA_INVERTIDA

JOGADOR.DRAW._RENDERIZAR_GUI:

    mv a0, s0
    jal PROC_RENDERIZAR_GUI

JOGADOR.DRAW._RET:

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# argumentos: a0 - entidade desse tipo envolvida na colisao
#             a1 - a outra entidade envolvida na colisao
#
# retorno: a0 - se a entidade desse tipo estah viva ou nao
JOGADOR.COLISAO:
    lw t0, entidade.HOSTIL(a1)
    beqz t0, JOGADOR.COLISAO._VIVO   # nao faz nada se a outra entidade nao for hostil

    lw t0, entidade.STRUCT_ESPECIFICA(a0)

    lw t2, entidade.X_Q12(a1)
    lw t3, entidade.X_Q12(a0)

    li t1, 1024
    lw t4, entidade.VELOCIDADE_X_Q12(a0)
    bgt t2, t3, JOGADOR.COLISAO._KNOCKBACK_ESQUERDA 
#   se a entidade estah a direita do jogador, joga ele para a esquerda
#   senao, joga para a direita
JOGADOR.COLISAO._KNOCKBACK_DIREITA:
    add t4, t4, t1
    j JOGADOR.COLISAO._CONT

JOGADOR.COLISAO._KNOCKBACK_ESQUERDA:
    sub t4, t4, t1

JOGADOR.COLISAO._CONT:
    sw t4, entidade.VELOCIDADE_X_Q12(a0)

    lb t1, JOGADOR.TEMPORIZADOR_INVENCIBILIDADE(t0)
    bgtz t1, JOGADOR.COLISAO._VIVO  # ignora colisao se o jogador estah invencivel

    lw t1, JOGADOR.VIDA(t0)         # senao, decrementa vida
    addi t1, t1, -1
    sw t1, JOGADOR.VIDA(t0)
    blez t1, JOGADOR.COLISAO._MORTO     # morre se vida >=0

    li t1, 10
    sb t1, JOGADOR.TEMPORIZADOR_INVENCIBILIDADE(t0)

JOGADOR.COLISAO._VIVO:
    li a0, 1
    ret

JOGADOR.COLISAO._MORTO:
    li a0, 0
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

JOGADOR.MODO_VASSOURA:

    lw t0, entidade.STRUCT_ESPECIFICA(a0)
    lh t1, JOGADOR.TEMPO_USO_VASSOURA(t0) # carrega o tempo que o jogador pode usar a vassoura
    beqz t1, SEM_ATUALIZACAO_TEMPO_VASSOURA # se for 0, quer dizer que nao esta usando: nao atualiza
    addi t1, t1, -1 # caso contrario, decrementa
    sh t1, JOGADOR.TEMPO_USO_VASSOURA(t0) # armazena no atributo do jogador

    bnez t1, SEM_ATUALIZACAO_TEMPO_VASSOURA # se chegar a 0 depois de decrementar, quer dizer que acabou o tempo
    li t1, -1
    sb t1, JOGADOR.FLAG_VASSOURA(t0) # desativa a vassoura

SEM_ATUALIZACAO_TEMPO_VASSOURA:

    lh t1, JOGADOR.COOLDOWN_USO_VASSOURA(t0) # carrega o cooldown da vassoura
    beqz t1, SEM_ATUALIZACAO_COOLDOWN_VASSOURA # se for igual a 0, nao tem pq decrementar: a vassoura estah pronta para usar
    addi t1, t1, -1 # caso contrario, decrementa
    sh t1, JOGADOR.COOLDOWN_USO_VASSOURA(t0) # quando chega a 0, deixa o jogador usar a vassoura novamente

SEM_ATUALIZACAO_COOLDOWN_VASSOURA:

    ret

## procedimento para avaliar se o jogador morre de queda

## ARGUMENTOS:

# a0 - struct basica do jogador

## RETORNO:

# a0 - se o jogador vive (1) ou morre (0)

JOGADOR.MORTE_QUEDA:

    addi sp, sp, -4
    sw ra, 0(sp)

    lb t0, entidade.NO_CHAO(a0) # so analisa se o jogador estiver caindo, economiza algumas instrucoes
    bnez t0, JOGADOR.MORTE_QUEDA_RET # se nao, pula pro retorno e mantem a unidade viva

    lw a1, entidade.Y_Q12(a0) # carrega Y
    lw a0, entidade.X_Q12(a0) # carrega X

    srai a1, a1, 12 # transforma ambos em Q0
    srai a0, a0, 12

    jal PROC_CALCULAR_TILE_COLISAO # procedimento para calcular o tile atual no mapa de colisao

    li t0, 4 # 4 eh o tile de morte. Se der positivo, por enquanto fecha o programa. Depois, fazer tela de game over
    bne a0, t0, JOGADOR.MORTE_QUEDA_RET

    li a7, 10 # ecall que fecha o programa
    ecall

JOGADOR.MORTE_QUEDA_RET:

    li a0, 1
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

