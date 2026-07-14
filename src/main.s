# Megaman2

.include "MACROSv24.s"
.include "macros.s"

.text
        j main          # Importante manter para garantir que a main vai rodar...

.data
.include "memoria.s"
        # definicoes e memoria adicional
        .include "fase_e_mapa/definicoes_mapas.s"
        .include "administracao_de_memoria/heap.s"
        .include "entidades/definicoes_entidades.s"
        .include "dialogo/definicoes_dialogo.s"
        .include "eventos/definicao_eventos.s"
        .include "animacao/definicoes_animacoes.s"

        .eqv GRAVIDADE_PADRAO 2048 # (0.5 pixeis / frame)

        # ASSETS UTILIZADOS
        .include "../assets/sprites/data/bruxa/sprite_bruxa_idle.data"
        .include "../assets/sprites/data/bruxa/sprite_bruxa_andando.data"
        .include "../assets/sprites/data/bruxa/sprite_bruxa_feitico.data"
        .include "../assets/sprites/data/bruxa/sprite_bruxa_pulo.data"
        .include "../assets/sprites/data/bruxa/sprite_bruxa_queda.data"
        .include "../assets/sprites/data/bruxa/sprite_bruxa_vassoura.data"
        .include "../assets/tilemaps/final_tilemap_1.s"
        .include "../assets/tilemaps/final_tilemap_1_colisao.s"
        .include "../assets/tilemaps/boss-fight-tilemap.data"
        .include "../assets/tilemaps/boss-fight-tilemap-colisao.data"
        .include "../assets/tiles_mapa/tileset.s"
        .include "../assets/sprites/data/bruxa/sprite_feitico5.data"
        .include "../assets/sprites/data/bruxa/sprite_feitico6.data"
        .include "../assets/sprites/data/bruxa/sprite_feitico_vento.data"
        .include "../assets/sprites/data/boss/sprite_boss.data"
        .include "../assets/sprites/data/schnoz/sprite_schnoz.data"
        .include "../assets/sprites/data/spawn/sprite_spawn.data"
        .include "../assets/dialogos/narrador.s"
        .include "../assets/sprites/data/dragao/sprite_dragao.data"
        .include "../assets/sprites/data/dragao/sprite_projetil_dragao.data"
        .include "../assets/sprites/data/boss/sprite_feitico_boss.data"

        # ENTIDADES NO JOGO
        .include "entidades/exemplo.s"
        .include "entidades/jogador.s"
        .include "entidades/projetil_comum.s"
        .include "entidades/schnoz.s"
        .include "entidades/jumper.s"
        .include "entidades/projetil_inimigo.s"
        .include "entidades/projetil_vento.s"
        .include "entidades/boss.s"
        .include "entidades/powerup.s"
        .include "entidades/fogo.s"

        # OUTROS
        .include "entidades/lista_entidades.s"
        .include "aritmetica/lemniscata_bernoulli.data"
        .include "animacao/animacoes.s"

.text
main:

        # deixa a heap disponivel para uso
        jal PROC_INICIALIZAR_HEAP

        # carrega o mapa
        la a0, final_tilemap_1
        la a1, final_tilemap_1_colisao
        jal PROC_CARREGAR_MAPA
       
        # carrega a textura
        la t0, tileset
        sw t0, textura_mapa, t1

        jal PROC_MENU
        
        # finaliza
        li a7, 10
        ecall

.include "administracao_de_memoria/free.s"
.include "administracao_de_memoria/inicializar_heap.s"
.include "administracao_de_memoria/malloc.s"
.include "impressao_e_tela/desenhar.s"
.include "impressao_e_tela/imprimir_fase.s"
.include "impressao_e_tela/imprimir_textura.s"
.include "impressao_e_tela/imprimir_textura_invertida.s"
.include "impressao_e_tela/imprimir_tile.s"
.include "impressao_e_tela/imprimir_entidades.s"
.include "impressao_e_tela/imprimir_dialogo.s"
.include "impressao_e_tela/imprimir_retangulo.s"
.include "impressao_e_tela/imprimir_outline.s"
.include "impressao_e_tela/imprimir_string.s"
.include "impressao_e_tela/renderizar_gui.s"
.include "impressao_e_tela/renderizar_gui_boss.s"
.include "entidades/adicionar_entidade.s"
.include "entidades/entidades_manager.s"
.include "entidades/remover_entidade.s"
.include "entidades/deletar_entidades_pendentes.s"
.include "entidades/monster_controller.s"
.include "entidades/recicla_entidade.s"
.include "fase_e_mapa/carregar_mapa.s"
.include "fase_e_mapa/fase.s"
.include "entradas/processar_entradas.s"
.include "camera/posicionar_camera.s"
.include "aritmetica/max.s"
.include "aritmetica/min.s"
.include "dialogo/adicionar_dialogo.s"
.include "dialogo/dialogos_manager.s"
.include "dialogo/limpar_dialogo.s"
.include "strings/copiar_string.s"
.include "strings/copiar_string_limite.s"
.include "strings/copiar_string_limite_seguro.s"
.include "strings/tamanho_string.s"
.include "colisao_e_movimento/colisao_schnoz.s"
.include "colisao_e_movimento/calcular_tile_colisao.s"
.include "colisao_e_movimento/calcular_tile_colisao_linha_coluna.s"
.include "colisao_e_movimento/mover_entidade.s"
.include "colisao_e_movimento/aplicar_friccao.s"
.include "colisao_e_movimento/colisoes_manager.s"
.include "colisao_e_movimento/detectar_colisao.s"
.include "eventos/adicionar_evento.s"
.include "eventos/eventos_manager.s"
.include "eventos/limpar_eventos.s"
.include "powerups/powerup_drop_tables.s"
.include "powerups/rolar_powerup.s"
.include "animacao/reiniciar_animacao.s"
.include "animacao/atualizar_animacao_jogador.s"
.include "animacao/atualizar_animacao_schnoz.s"
.include "animacao/atualizar_animacao_jumper.s"
.include "animacao/criar_animacao_controller.s"
.include "animacao/definir_animacao.s"
.include "animacao/executar_animacao.s"
.include "animacao/obter_textura_animacao.s"
.include "null_proc.s"
.include "SYSTEMv24.s"
.include "sleep.s"
.include "custscenes/inicio_jogo.s"


