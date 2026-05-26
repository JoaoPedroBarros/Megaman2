# Megaman2

.include "MACROSv24.s"
.include "macros.s"

.text
        j main          # Importante manter para garantir que a main vai rodar...

.data
.include "memoria.s"

.text
main:

        # deixa a heap disponivel para uso
        jal PROC_INICIALIZAR_HEAP

        # carrega o mapa
        la a0, playground_tilemap
        jal PROC_CARREGAR_MAPA
       
        # carrega a textura
        la t0, textura_teste
        sw t0, textura_mapa, t1

        # chama o procedimento de fase
        jal PROC_FASE

        # finaliza
        li a7, 10
        ecall

.include "administracao_de_memoria/free.s"
.include "administracao_de_memoria/inicializar_heap.s"
.include "administracao_de_memoria/malloc.s"
.include "impressao_e_tela/desenhar.s"
.include "impressao_e_tela/imprimir_fase.s"
.include "impressao_e_tela/imprimir_textura.s"
.include "impressao_e_tela/imprimir_tile.s"
.include "impressao_e_tela/imprimir_entidades.s"
.include "entidades/adicionar_entidade.s"
.include "entidades/entidades_manager.s"
.include "entidades/remover_entidade.s"
.include "fase_e_mapa/carregar_mapa.s"
.include "fase_e_mapa/fase.s"
.include "entradas/processar_entradas.s"
.include "camera/posicionar_camera.s"
.include "SYSTEMv24.s"
.include "sleep.s"
.include "entidades/jogador.s"
