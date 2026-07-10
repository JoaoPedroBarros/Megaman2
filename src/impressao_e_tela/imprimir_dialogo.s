# PROC_IMPRIMIR_DIALOGO
#
# Renderiza um dialogo na tela. IMPORTANTE: **APENAS** O MANAGER DE DIALOGOS
# DEVE USAR ESSE PROCEDIMENTO. Para adicionar um dialogo na fila, use
# PROC_ADICIONAR_DIALOGO. Para mostra-lo imediatamente, limpe primeiro a fila
# usando PROC_LIMPAR_DIALOGO.
#
# Argumento: a0 - dialogo a ser renderizado
# (sem retornos)

PROC_IMPRIMIR_DIALOGO:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)

        mv s0, a0       # guarda o dialogo

P_ID1_RENDERIZAR_UI:
        imprimir_retangulo(0x00, 5, 5, 315, 75)
        imprimir_outline(0xFF, 10, 10, 310, 70, 2) # outline de 2px de espessura

P_ID1_IMPRIMIR_DIALOGO:
        # copia a string do dialogo para o buffer
        lw a0, dialogo.STRING(s0)
        la a1, dialogo_buffer
        lw a2, dialogo.CONTADOR_CARACTERES(s0)
        addi a2, a2, 1                          # tamanho do buffer = espaco para caracteres + espaco para \0
        jal PROC_COPIAR_STRING_LIMITE_SEGURO # copia com um \0 no final

        # syscall de imprimir string
        la a0, dialogo_buffer
        li a1, 15
        li a2, 30
        li a3, 0xFF
        jal PROC_IMPRIMIR_STRING

        # imprime o nome tbm
        lw a0, dialogo.NOME_FALANTE(s0)
        li a1, 15
        li a2, 15
        li a3, 0xFF
        jal PROC_IMPRIMIR_STRING

P_ID1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret