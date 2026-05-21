# PROC_FASE: roda o jogo
# (sem argumentos e retorno)

PROC_FASE:
        addi sp, sp, -4
        sw ra, (sp)

        # exemplo de criaçao de jogador em uma posicao
        li a0, ENTIDADE_JOGADOR
        li a1, 100
        li a2, 100
        jal PROC_ADICIONAR_ENTIDADE

        # gameloop
P_F1_LOOP:
        # limpa a tela, preenchendo de preto
        li a0, 0x00
        lw a1, FRAME_ATUAL
        seqz a1, a1     # pega o frame NAO atual (seqz 1 = 0, seqz 0 = 1)
        li a7, 148
        ecall

        jal PROC_PROCESSAR_ENTRADAS             # processa entradas no teclado

        jal PROC_ENTIDADES_MANAGER              # administra entidades

        la t0, jogador
        lw a0, jogador_x(t0)
        lw a1, jogador_y(t0)
        jal PROC_POSICIONAR_CAMERA              # coloca a camera na posicao do jogador

        jal PROC_IMPRIMIR_FASE                  # imprime a fase 
        jal PROC_IMPRIMIR_ENTIDADES             # imprime as entidades
        jal PROC_DESENHAR                       # muda o frame, mostrando tudo impresso ateh agora na tela

        j P_F1_LOOP

        lw ra, (sp)
        addi sp, sp, 4
        ret
