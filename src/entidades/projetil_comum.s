# Entidade que modela o projetil padrao do jogo, solto pelo jogador

.data

PROJETIL_COMUM.struct:
        
.eqv PROJETIL_COMUM.TAMANHO_STRUCT 0

# Argumentos (obrigatoriamente):
# a0 - struct basica
# a1 - X
# a2 - Y
# Sem retornos!

.text 

PROJETIL_COMUM.NOVO:
        slli a1, a1, 12     # coloca em q12
        slli a2, a2, 12     # coloca em q12
        sw a1, entidade.X_Q12(a0)
        sw a2, entidade.Y_Q12(a0)

        sw zero, entidade.VELOCIDADE_X_Q12(a0)
        sw zero, entidade.VELOCIDADE_Y_Q12(a0)
        li t0, 1
        sw t0, entidade.COLIDIVEL(a0)
        sw zero, entidade.HOSTIL(a0)
        li t0, FLAG_ENTIDADE_IGNORAR_PLATAFORMAS
        sw t0, entidade.FLAGS(a0)

        li t0, 16
        sw t0, entidade.ALTURA(a0)
        sw t0, entidade.LARGURA(a0)

        # nao retorna nada! apenas deixa a entidade com valores iniciados.
        ret     

# Argumento (obrigatoriamente)
# a0 - struct basica
# Retorno (obrigatorialmente)
# a0 - se a entidade ainda existe ou nao
PROJETIL_COMUM.PROC:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)
        
        mv s0, a0

        jal PROC_MOVER_ENTIDADE   # move com base na velocidade

        lw t0, entidade.VELOCIDADE_X_Q12(s0)
        snez a0, t0     # retorna (velocidade_x != 0)

        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret

# Argumentos (obrigatoriamente):
# a0 - struct basica
# sem retornos!
PROJETIL_COMUM.DRAW:
        addi sp, sp, -4
        sw ra, (sp)

        mv t0, a0       # (struct)
        la a0, sprite_feitico5              # textura
        addi a0, a0, 8
        lw a1, entidade.X_Q12(t0)           # pos x
        lw a2, entidade.Y_Q12(t0)           # pos y

        # pega valor inteiro
        srai a1, a1, 12
        srai a2, a2, 12

        # corrige posicao x e y para ser impresso relativo ah camera
        la t3, camera
        lw t1, camera_x(t3)
        lw t2, camera_y(t3)
        sub a1, a1, t1          
        sub a2, a2, t2        
        
        # dimensoes da textura
        li a3, 16
        li a4, 16

        jal PROC_IMPRIMIR_TEXTURA

        lw ra, (sp)
        addi sp, sp, 4
        ret

# argumentos
# a0 - struct basica
# a1 - nova velocidade (Q12)
PROJETIL_COMUM.SET_VELOCIDADE_X:
        sw a1, entidade.VELOCIDADE_X_Q12(a0)
        ret

