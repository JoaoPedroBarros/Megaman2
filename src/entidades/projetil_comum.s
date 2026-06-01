# Entidade que modela o projetil padrao do jogo, solto pelo jogador

.data

PROJETIL_COMUM.struct:
        .eqv VELOCIDADE_X     0
        .eqv VELOCIDADE_Y_Q12 4         # velocidade Y representada com 12 casas decimais
        .eqv POSICAO_SUBY_Q12 8         # posicao decimal na coordenada Y
.eqv PROJETIL_COMUM.TAMANHO_STRUCT 12

# Argumentos (obrigatoriamente):
# a0 - struct basica
# a1 - X
# a2 - Y
# Sem retornos!

.text 

PROJETIL_COMUM.NOVO:
        sw a1, entidade.X(a0)
        sw a2, entidade.Y(a0)
        lw t0, entidade.STRUCT_ESPECIFICA(a0)   # pega a struct com dados especificos a esse tipo de entidade

        sw zero, VELOCIDADE_X(t0)
        sw zero, VELOCIDADE_Y_Q12(t0)

        # nao retorna nada! apenas deixa a entidade com valores iniciados.
        ret     

# Argumento (obrigatoriamente)
# a0 - struct basica
# Retorno (obrigatorialmente)
# a0 - se a entidade ainda existe ou nao
PROJETIL_COMUM.PROC:
        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        lw t1, VELOCIDADE_X(t0)
        lw t2, entidade.X(a0)
        add t2, t2, t1
        sw t2, entidade.X(a0)

        lw t1, VELOCIDADE_Y_Q12(t0)
        addi t1, t1, 1024       # 0.5
        sw t1, VELOCIDADE_Y_Q12(t0)
        srli t1, t1, 12         # pega o valor inteiro
        lw t2, entidade.Y(a0)
        add t2, t2, t1
        sw t2, entidade.Y(a0)

        li a0, 1                        # retorna que ainda existe
        ret

# Argumentos (obrigatoriamente):
# a0 - struct basica
# sem retornos!
PROJETIL_COMUM.DRAW:
        addi sp, sp, -4
        sw ra, (sp)

        mv t0, a0       # (struct)
        la a0, playground_tilemap                   # textura
        lw a1, entidade.X(t0)           # pos x
        lw a2, entidade.Y(t0)           # pos y

        # corrige posicao x e y para ser impresso relativo ah camera
        la t3, camera
        lw t1, camera_x(t3)
        lw t2, camera_y(t3)
        sub a1, a1, t1          
        sub a2, a2, t2        
        
        # dimensoes da textura
        li a3, 20
        li a4, 20

        # poderia ser tbm algo como
        # lw a3, (t0)
        # lw a4, 4(t0)

        jal PROC_IMPRIMIR_TEXTURA

        lw ra, (sp)
        addi sp, sp, 4
        ret

# argumentos
# a0 - struct basica
# a1 - nova velocidade (inteira)
PROJETIL_COMUM.SET_VELOCIDADE_X:
        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        sw a1, VELOCIDADE_X(t0)
        ret

