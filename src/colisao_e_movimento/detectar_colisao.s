# PROC_DETECTAR_COLISAO
#
# Detecta colisao entre duas entidades.
# IMPORTANTE: NAO UTILIZAR FORA DE
# COLISOES_MANAGER. PARA IMPLEMENTAR
# COLISOES NA SUA ENTIDADE, USE A PROC
# PROPRIA E GUARDE ELA NA LISTA DE 
# ENTIDADES!!!
#
# Argumentos:
# a0 - struct entidade 1
# a1 - struct entidade 2
#
# Retornos:
# a0 - se houve colisao (0 = nao, 1 = sim)


# algoritmo AABB:
#. x1 = a.x + a.offx
#. x2 = b.x + b.offx
#.
#. if (x1 > x2 + b.width) return 0;
#. if (x2 > x1 + a.width) return 0;
#.
#. y1 = a.y + a.offy
#. y2 = b.y + b.offy
#.
#. if (y1 > y2 + b.height) return 0;
#. if (y2 > y1 + a.height) return 0;
#.
#. return 1;

PROC_DETECTAR_COLISAO:
        lw t0, entidade.X_Q12(a0)
        srai t0, t0, 12 
        lw t1, entidade.HITBOX_DESLOCAMENTO_X(a0)
        add t0, t0, t1 # entidade1.x

        lw t1, entidade.X_Q12(a1)
        srai t1, t1, 12 
        lw t2, entidade.HITBOX_DESLOCAMENTO_X(a1)
        add t1, t1, t2 # entidade2.x

        lw t2, entidade.HITBOX_LARGURA(a0)
        lw t3, entidade.HITBOX_LARGURA(a1)

        add t4, t1, t3
        bgt t0, t4, P_DC1_SEM_COLISAO
        add t4, t0, t2
        bgt t1, t4, P_DC1_SEM_COLISAO

        lw t0, entidade.Y_Q12(a0)
        srai t0, t0, 12 
        lw t1, entidade.HITBOX_DESLOCAMENTO_Y(a0)
        add t0, t0, t1 # entidade1.y

        lw t1, entidade.Y_Q12(a1)
        srai t1, t1, 12
        lw t2, entidade.HITBOX_DESLOCAMENTO_Y(a1)
        add t1, t1, t2 # entidade2.Y

        lw t2, entidade.HITBOX_ALTURA(a0)
        lw t3, entidade.HITBOX_ALTURA(a1)

        add t4, t1, t3
        bgt t0, t4, P_DC1_SEM_COLISAO
        add t4, t0, t2
        bgt t1, t4, P_DC1_SEM_COLISAO

P_DC1_COLISAO:
        li a0, 1
        ret

P_DC1_SEM_COLISAO:
        mv a0, zero
        ret