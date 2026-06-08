### PROCEDIMENTOS PARA ANALISAR COLISAO COM O MAPA ###

### ARGUMENTOS ###

# a0 - struct basica do jogador

### RETORNO ###

# a0 - 0 se o jogador nao pode se movimentar. 1 caso contrario.


PROC_COLISAO_MAPA_DIREITA:

        la t0, tilemap # carrega a referencia do tilemap

        lw t1, entidade.X_Q12(a0) # carrega o X
        lw t2, entidade.Y_Q12(a0) # carrega o Y

        srli t1, t1, 12 # volta as coordenadas para Q0
        srli t2, t2, 12

        addi t1, t1, entidade.LARGURA  # soma 24 para o fim do sprite: fica melhor visualmente

        li t3, TAMANHO_TILE # carrega o tamanho do tile

        div t1, t1, t3 # divide as coordenadas para obter a localizacao no tilemap
        div t2, t2, t3

        lw t3, 4(t0) # calcula o comprimento do tilemap

        mul t2, t2, t3 # multiplica o Y pelo comprimento para saber quantos tiles ja percorreu verticalmente
        add t1, t1, t2 # adiciona o X para saber quantos tiles ja percorreu horizontalmente

        addi t0, t0, 8 # pula as dimensoes do mapa
        add t0, t0, t1 # adiciona a localizacao do personagem ao primeiro tile

        lb t0, 0(t0) # carrega o tile
        beq t0, zero, MOVIMENTACAO_INVALIDA # 0 eh o tile preto: nao move
        li t1, 2
        beq t0, t1, MOVIMENTACAO_INVALIDA # 2 eh um tile de chao: nao move
        li t1, 3
        beq t0, t1, MOVIMENTACAO_INVALIDA # 3 eh um tile de chao: nao move
        j MOVIMENTACAO_VALIDA


PROC_COLISAO_MAPA_ESQUERDA:

        la t0, tilemap # carrega a referencia do tilemap

        lw t1, entidade.X_Q12(a0) # carrega o X
        lw t2, entidade.Y_Q12(a0) # carrega o Y

        srli t1, t1, 12 # volta as coordenadas para Q0
        srli t2, t2, 12

        ## como a esquerda ja pega o inicio do sprite, nao precisa de aritmetica pra deixar melhor visualmente

        li t3, TAMANHO_TILE # carrega o tamanho do tile

        div t1, t1, t3 # divide as coordenadas para obter a localizacao no tilemap
        div t2, t2, t3

        lw t3, 4(t0) # calcula o comprimento do tilemap

        mul t2, t2, t3 # multiplica o Y pelo comprimento para saber quantos tiles ja percorreu verticalmente
        add t1, t1, t2 # adiciona o X para saber quantos tiles ja percorreu horizontalmente

        addi t0, t0, 8 # pula as dimensoes do mapa
        add t0, t0, t1 # adiciona a localizacao do personagem ao primeiro tile

        lb t0, 0(t0) # carrega o tile
        beq t0, zero, MOVIMENTACAO_INVALIDA # 0 eh o tile preto: nao move
        li t1, 2
        beq t0, t1, MOVIMENTACAO_INVALIDA # 2 eh um tile de chao: nao move
        li t1, 3
        beq t0, t1, MOVIMENTACAO_INVALIDA # 3 eh um tile de chao: nao move
        li t1, 9
        beq t0, t1, MOVIMENTACAO_INVALIDA
        j MOVIMENTACAO_VALIDA

PROC_COLISAO_MAPA_CHAO:

        

PROC_COLISAO_MAPA_CIMA:

MOVIMENTACAO_INVALIDA:

        li a0, 0 # 0 nao deixa o personagem completar o movimento
        ret

MOVIMENTACAO_VALIDA:

        li a0, 1 # 1 deixa o personagem completar o movimento
        ret

