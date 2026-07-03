# PROC_FASE: roda o jogo
# (sem argumentos e retorno)

.data 
        dialogo1nome: .asciz "Narrador"
        dialogo1teste: .asciz "Lorem ipsum dolor sit amet."

        dialogo2nome: .asciz "Vento"
        dialogo2teste: .asciz "Consectetur, adipliscing; elit...\n(whoooosh...)"

.text

PROC_FASE:
        addi sp, sp, -4
        sw ra, (sp)

        # exemplo de criaçao de jogador em uma posicao
        li a0, ENTIDADE_JOGADOR
        li a1, 200
        li a2, 320
        jal PROC_ADICIONAR_ENTIDADE

        li a0, ENTIDADE_SCHNOZ
        li a1, 250
        li a2, 320
        jal PROC_ADICIONAR_ENTIDADE

        li a0, ENTIDADE_JUMPER
        li a1, 220
        li a2, 320
        jal PROC_ADICIONAR_ENTIDADE

        la a0, dialogo1teste
        la a1, dialogo1nome
        li a2, 2
        jal PROC_ADICIONAR_DIALOGO

        la a0, dialogo2teste
        la a1, dialogo2nome
        li a2, 2
        jal PROC_ADICIONAR_DIALOGO

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

        jal PROC_DELETAR_ENTIDADES_PENDENTES 	# deleta entidades mortas

        jal PROC_IMPRIMIR_FASE                  # imprime a fase 
        jal PROC_IMPRIMIR_ENTIDADES             # imprime as entidades

        jal PROC_DIALOGOS_MANAGER               # administra dialogos

        jal PROC_DESENHAR                       # muda o frame, mostrando tudo impresso ateh agora na tela

        jal PROC_SLEEP

        j P_F1_LOOP

        lw ra, (sp)
        addi sp, sp, 4
        ret
