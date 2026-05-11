# PROC_FASE: roda o jogo
# (sem argumentos e retorno)

PROC_FASE:
        addi sp, sp, -4
        sw ra, (sp)

        # gameloop
P_F1_LOOP:
        # limpa a tela, preenchendo de preto
        li a0, 0x00
        lw a1, FRAME_ATUAL
        seqz a1, a1     # pega o frame NAO atual (seqz 1 = 0, seqz 0 = 1)
        li a7, 148
        ecall

        jal PROC_PROCESSAR_ENTRADAS          # processa entradas no teclado

        la t0, jogador
        lw a0, jogador_x(t0)
        lw a1, jogador_y(t0)
        jal PROC_POSICIONAR_CAMERA                # coloca a camera na posicao do jogador

        jal PROC_IMPRIMIR_FASE               # imprime a fase 

        jal PROC_DESENHAR

        j P_F1_LOOP

        addi sp, sp, 4
        ret
