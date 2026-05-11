# PROC_POSICIONAR_CAMERA
# centraliza a camera na posicao desejada

# Argumentos:
# a0 - X absoluto 
# a1 - Y absoluto
# (tomando-se o canto superior esquerdo do mapa (nao da tela) como origem)

PROC_POSICIONAR_CAMERA:
        # primeiro calcula a posicao do canto superior esquerdo
        li t0, LARGURA_VGA
        srai t0, t0, 1  
        sub a0, a0, t0  # X_canto_superior_esquerdo = X - LARGURA_VGA/2

        li t0, ALTURA_VGA
        srai t0, t0, 1  
        sub a1, a1, t0  # Y_canto_superior_esquerdo = Y - LARGURA_VGA/2

        bgez a0, P_PC1_CONT1
        #mv a0, zero     # se X_canto_superior_esquerdo < 0, coloca o X como 0

P_PC1_CONT1:
        bgez a1, P_PC1_CONT2
        #mv a1, zero     # se Y_canto_superior_esquerdo < 0, coloca o Y como 0

P_PC1_CONT2:
        # salva a nova posicao da camera
        la t0, camera
        sw a0, camera_x(t0)
        sw a1, camera_y(t0)
        ret