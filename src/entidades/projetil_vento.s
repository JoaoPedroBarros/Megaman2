# entidade que modela um projetil de vento, que aplica um knockback no 
# inimigo quando identifica a colisao, alem de um dano reduzido

.data

PROJETIL_VENTO.struct:
        
.eqv PROJETIL_VENTO.TAMANHO_STRUCT 0
.eqv PROJETIL_VENTO.DANO -10
.eqv PROJETIL_VENTO.KNOCKBACK_INIMIGO 16384 # valor em Q12 para a velocidade

# Argumentos (obrigatoriamente):
# a0 - struct basica
# a1 - X
# a2 - Y
# Sem retornos!

.text 

PROJETIL_VENTO.NOVO:
        slli a1, a1, 12
        slli a2, a2, 12    
        sw a1, entidade.X_Q12(a0)
        sw a2, entidade.Y_Q12(a0)

        sw zero, entidade.VELOCIDADE_X_Q12(a0)
        sw zero, entidade.VELOCIDADE_Y_Q12(a0)
        li t0, 1
        sw t0, entidade.COLIDIVEL(a0)
        sw zero, entidade.HOSTIL(a0)
        li t0, FLAG_ENTIDADE_IGNORAR_PLATAFORMAS
        sw t0, entidade.FLAGS(a0)

        definir_hitbox(a0, 2, 3, 12, 10)

        ret     


PROJETIL_VENTO.PROC:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)
        
        mv s0, a0

        jal PROC_MOVER_ENTIDADE

        lw t0, entidade.VELOCIDADE_X_Q12(s0)       
        snez a0, t0

        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret

PROJETIL_VENTO.DRAW:
        addi sp, sp, -4
        sw ra, (sp)

        mv t0, a0       # (struct)
        la a0, sprite_feitico_vento             # textura
        addi a0, a0, 8
        lw a1, entidade.X_Q12(t0)           # pos x
        lw a2, entidade.Y_Q12(t0)           # pos y

        srai a1, a1, 12
        srai a2, a2, 12

        la t3, camera
        lw t1, camera_x(t3)
        lw t2, camera_y(t3)
        sub a1, a1, t1          
        sub a2, a2, t2        
        
        li a3, 16
        li a4, 16

        lw t1, entidade.VELOCIDADE_X_Q12(t0)
        bltz t1, PROJETIL_VENTO.DRAW._IMPRIMIR_INVERTIDO

        jal PROC_IMPRIMIR_TEXTURA
        j PROJETIL_VENTO.DRAW._RET

PROJETIL_VENTO.DRAW._IMPRIMIR_INVERTIDO:
        jal PROC_IMPRIMIR_TEXTURA_INVERTIDA

PROJETIL_VENTO.DRAW._RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret

PROJETIL_VENTO.SET_VELOCIDADE_X:
        sw a1, entidade.VELOCIDADE_X_Q12(a0)
        ret

PROJETIL_VENTO.COLISAO:

        lw t0, entidade.HOSTIL(a1)
        seqz a0, t0

        lw t0, entidade.TIPO(a1)
        li t1, ENTIDADE_PROJETIL_INIMIGO
        sub t0, t0, t1
        
        seqz t0, t0

        or a0, a0, t0

        ret





