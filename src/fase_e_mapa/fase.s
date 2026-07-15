# PROC_FASE: roda o jogo
# (sem argumentos e retorno)

.data 
        dialogo1nome: .asciz "FLORA:\n"
        dialogo1teste: .asciz "Lorem ipsum dolor sit amet."

        dialogo2nome: .asciz "Vento"
        dialogo2teste: .asciz "Consectetur, adipliscing; elit...\n(whoooosh...)"
.text

PROC_FASE:
        addi sp, sp, -4
        sw ra, (sp)
        
        sw zero, frame_counter, t0      # reseta o frame_counter
        sb zero, flagretornofase, t0    # reseta a flag de retorno

        jal PROC_LIMPAR_ENTIDADES       # comeca do absoluto 0

        # exemplo de criaçao de jogador em uma posicao
        li a0, ENTIDADE_JOGADOR
        li a1, 30
        li a2, 144
        jal PROC_ADICIONAR_ENTIDADE ##

        la t0, jogador # armazena a refererencia pra struct o jogador num endereco global
        sw a0, 0(t0)

        la a0, berserk___forces
        li a1, 1        # canal de musica: 1
        li a2, 1        # sobrescrever a musica anterior
        li a3, 1        # loopa a musica
        li a4, 80       # volume
        jal PROC_TOCAR_AUDIO

        jal PROC_LIMPAR_DIALOGO

        # gameloop
P_F1_LOOP:
        # limpa a tela, preenchendo de preto
        li a0, 0x00
        lw a1, FRAME_ATUAL
        seqz a1, a1     # pega o frame NAO atual (seqz 1 = 0, seqz 0 = 1)
        li a7, 148
        ecall

        jal PROC_ENTIDADES_MANAGER              # administra entidades
        jal PROC_COLISOES_MANAGER               # lida com colisoes
        jal PROC_EVENTOS_MANAGER                # administra eventos

        jal PROC_MONSTER_CONTROLLER
        jal PROC_DELETAR_ENTIDADES_PENDENTES 	# deleta entidades mortas

        jal PROC_IMPRIMIR_FASE                  # imprime a fase 
        jal PROC_IMPRIMIR_ENTIDADES             # imprime as entidades

        jal PROC_DIALOGOS_MANAGER               # administra dialogos

        jal PROC_AUDIOS_MANAGER                 # toca audios

        jal PROC_DESENHAR                       # muda o frame, mostrando tudo impresso ateh agora na tela

        la t0, frame_counter
        lw t1, (t0)
        addi t1, t1, 1
        sw t1, (t0)                             # adiciona um frame no contador

        jal PROC_SLEEP

        # retorna apenas de a flag estiver ligada, e retorna a propria flag.
        lb a0, flagretornofase
        beqz a0, P_F1_LOOP

        lw ra, (sp)
        addi sp, sp, 4
        ret

