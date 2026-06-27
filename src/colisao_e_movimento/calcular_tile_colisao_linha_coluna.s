# PROC_CALCULAR_TILE_COLISAO_COLUNA_LINHA
#
# Retorna o tile na posicao dada no 
# tilemap de colisao.
#
# Argumentos:
# a0 - coluna
# a1 - linha
# Retorno:
# a0 - tipo do tile (ver definicoes_mapa.s)

PROC_CALCULAR_TILE_COLISAO_COLUNA_LINHA:
        la t0, tilemap_colisao # carrega a referencia do tilemap

        lw t3, 4(t0) # pega a largura do tilemap

        mul t2, a1, t3 # multiplica o n de linhas pelo comprimento para saber quantos tiles ja percorreu verticalmente
        add t1, a0, t2 # adiciona o n de coluna para saber quantos tiles ja percorreu horizontalmente

        addi t0, t0, 8 # pula as dimensoes do mapa
        add t0, t0, t1 # aplica o offset
        lb a0, 0(t0) # carrega o tile
        ret
