# PLAYGROUND - MAPA MAIOR QUE A TELA
# TENTATIVA DE CONSTRUIR RENDERIZACAO QUE SAIA DA TELA

.include "MACROSv24.s"
.include "macros.s"

.data
.include "memoria.s"
.include "../assets/mapa1.data"
.include "../assets/textura_teste.data"

.text
main:
        # carrega o mapa
        la a0, mapa1
        jal PROC_CARREGAR_MAPA
       
        # carrega a textura
        la t0, textura_teste
        sw t0, textura_mapa, t1

        # chama o procedimento de fase
        jal PROC_FASE

.include "impressao_e_tela/desenhar.s"
.include "impressao_e_tela/imprimir_fase.s"
.include "impressao_e_tela/imprimir_textura.s"
.include "impressao_e_tela/imprimir_tile.s"
.include "fase_e_mapa/carregar_mapa.s"
.include "fase_e_mapa/fase.s"
.include "entradas/processar_entradas.s"
.include "camera/posicionar_camera.s"
.include "SYSTEMv24.s"
