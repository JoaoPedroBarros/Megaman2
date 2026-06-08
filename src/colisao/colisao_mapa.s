### PROCEDIMENTOS PARA ANALISAR COLISAO COM O MAPA ###

### ARGUMENTOS ###

# a0 - struct basica do jogador

### RETORNO ###

# a0 - 0 se o jogador nao pode se movimentar. 1 caso contrario.


PROC_COLISAO_MAPA_DIREITA:

        addi sp, sp, -4
        sw ra, 0(sp)

        mv s0, a0

        lw a0, entidade.X_Q12(s0) # carrega o X
        lw a1, entidade.Y_Q12(s0) # carrega o Y

        srli a0, a0, 12 # volta as coordenadas para Q0
        srli a1, a1, 12

        lw t3, entidade.LARGURA(s0)
        add a0, a0, t3   # soma a largura para ficar melhor visualmente

        jal CALCULA_TILE

        beq a0, zero, MOVIMENTACAO_INVALIDA # 0 eh o tile preto: nao move
        li t1, 2
        beq a0, t1, MOVIMENTACAO_INVALIDA # 2 eh um tile de chao: nao move
        li t1, 3
        beq a0, t1, MOVIMENTACAO_INVALIDA # 3 eh um tile de chao: nao move
        j MOVIMENTACAO_VALIDA


PROC_COLISAO_MAPA_ESQUERDA:

        addi sp, sp, -4
        sw ra, 0(sp)

        mv s0, a0

        lw a0, entidade.X_Q12(s0) # carrega o X
        lw a1, entidade.Y_Q12(s0) # carrega o Y

        srli a0, a0, 12 # volta as coordenadas para Q0
        srli a1, a1, 12

        jal CALCULA_TILE

        beq a0, zero, MOVIMENTACAO_INVALIDA # 0 eh o tile preto: nao move
        li t1, 2
        beq a0, t1, MOVIMENTACAO_INVALIDA # 2 eh um tile de chao: nao move
        li t1, 3
        beq a0, t1, MOVIMENTACAO_INVALIDA # 3 eh um tile de chao: nao move
        li t1, 9
        beq a0, t1, MOVIMENTACAO_INVALIDA
        j MOVIMENTACAO_VALIDA

PROC_COLISAO_MAPA_CHAO:

PROC_COLISAO_MAPA_CIMA:

MOVIMENTACAO_INVALIDA:

        li a0, 0 # 0 nao deixa o personagem completar o movimento
        lw ra, 0(sp)
        addi sp, sp, 4
        ret

MOVIMENTACAO_VALIDA:

        li a0, 1 # 1 deixa o personagem completar o movimento
        lw ra, 0(sp)
        addi sp, sp, 4
        ret

# procedimento para calcular o tile correspondente baseado em coordenadas brutas

# ARGUMENTOS

# a0 - X
# a1 - Y (ambos em Q0).

# Em casos em que queremos avaliar uma posicao futura, como em colisao, deve-se modificar o valor antes de chamar
# o procedimento.

# RETORNO

# a0 - tipo do tile

CALCULA_TILE:

        la t0, tilemap # carrega a referencia do tilemap
        mv t1, a0
        mv t2, a1
        li t3, TAMANHO_TILE

        div t1, t1, t3 # divide as coordenadas para obter a localizacao no tilemap
        div t2, t2, t3

        lw t3, 4(t0) # calcula o comprimento do tilemap

        mul t2, t2, t3 # multiplica o Y pelo comprimento para saber quantos tiles ja percorreu verticalmente
        add t1, t1, t2 # adiciona o X para saber quantos tiles ja percorreu horizontalmente

        addi t0, t0, 8 # pula as dimensoes do mapa
        add t0, t0, t1 # adiciona a localizacao do personagem ao primeiro tile
        lb a0, 0(t0) # carrega o tile

        ret



        





