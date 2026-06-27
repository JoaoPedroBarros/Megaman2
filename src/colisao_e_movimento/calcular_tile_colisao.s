# PROC_CALCULAR_TILE_COLISAO
#
# Retorna o tile nas coordenadas dadas no 
# tilemap de colisao.
#
# Argumentos:
# a0 - X (Q0)
# a1 - Y (Q0)
# Retorno:
# a0 - tipo do tile (ver definicoes_mapa.s)

PROC_CALCULAR_TILE_COLISAO:
        la t0, tilemap_colisao # carrega a referencia do tilemap

        # divide as coordenadas para obter a localizacao no tilemap
        srai t1, a0, LOG2_TAMANHO_TILE 
        srai t2, a1, LOG2_TAMANHO_TILE

        lw t3, 4(t0) # calcula o comprimento do tilemap

        mul t2, t2, t3 # multiplica o Y pelo comprimento para saber quantos tiles ja percorreu verticalmente
        add t1, t1, t2 # adiciona o X para saber quantos tiles ja percorreu horizontalmente

        addi t0, t0, 8 # pula as dimensoes do mapa
        add t0, t0, t1 # aplica o offset
        lb a0, 0(t0) # carrega o tile

        ret
