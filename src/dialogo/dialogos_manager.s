# PROC_DIALOGOS_MANAGER
# Mostra o dialogo atual e passa pro proximo
# com input do jogador
#
# (sem argumentos e retornos)

PROC_DIALOGOS_MANAGER:
        addi sp, sp, -4
        sw ra, (sp)

        la t0, struct_dialogo_estatica
        lw t1, struct_dialogo_estatica.EM_PROGRESSO(t0)
        beqz t1, P_DM1_RET

P_DM1_MOSTRAR_ATUAL:
        lw t1, struct_dialogo_estatica.DIALOGO_ATUAL(t0)
        lw t2, dialogo.CONTADOR_FRAMES(t1)
        addi t2, t2, 1
        sw t2, dialogo.CONTADOR_FRAMES(t1)

        lw t3, dialogo.FRAME_PROXIMO_CARACTERE(t1)
        blt t2, t3, P_DM1_VERIFICAR_TECLA      # se FRAME_ATUAL < FRAME_LIMITE, nao pula caractere

P_DM1_PROXIMO_CARACTERE:
        lw t4, dialogo.CONTADOR_CARACTERES(t1)
        lw t5, dialogo.TAMANHO(t1)
        beq t4, t5, P_DM1_VERIFICAR_TECLA   # nao faz nada se jah chegamos no final!

        # agora vamos ver o caractere atual para ver quanto delay devemos aplicar para o proximo caractere

        # pega o contador-ehsimo caractere      
        lw t3, dialogo.STRING(t1)
        add t3, t3, t4
        lb t5, (t3)

        lw t0, dialogo.DELAY_ENTRE_CARACTERES(t1)
        beqz t0, P_DM1_IR_AO_FINAL      # se delay = 0, revela tudo de uma vez

        # aplica delay conforme o tipo de caractere

        li t6, ','
        beq t6, t5, P_DM1_DELAY_1_E_MEIO
        li t6, ':'
        beq t6, t5, P_DM1_DELAY_1_E_MEIO
        li t6, ';'
        beq t6, t5, P_DM1_DELAY_1_E_MEIO

        li t6, '\n'
        beq t6, t5, P_DM1_DELAY_2
        li t6, '!'
        beq t6, t5, P_DM1_DELAY_2
        li t6, '?'
        beq t6, t5, P_DM1_DELAY_2
        li t6, '.'
        beq t6, t5, P_DM1_DELAY_2

P_DM1_DELAY_PADRAO:
        add t2, t2, t0
        sw t2, dialogo.FRAME_PROXIMO_CARACTERE(t1)
        j P_DM1_INC_CONTADOR_CARACTERES

P_DM1_DELAY_1_E_MEIO:

        # frame_proximo_caractere = delay + (delay>>1) = delay + delay/2 = (int) delay*1.5
        add t2, t2, t0
        srai t0, t0, 1
        add t2, t2, t0
        sw t2, dialogo.FRAME_PROXIMO_CARACTERE(t1)
        j P_DM1_INC_CONTADOR_CARACTERES

P_DM1_DELAY_2:

        # frame_proximo_caractere = delay << 1 = delay*2
        slli t0, t0, 1
        add t2, t2, t0
        sw t2, dialogo.FRAME_PROXIMO_CARACTERE(t1)

P_DM1_INC_CONTADOR_CARACTERES:
        # contador_caracteres++
        addi t4, t4, 1
        sw t4, dialogo.CONTADOR_CARACTERES(t1)

P_DM1_VERIFICAR_TECLA:
        lw t4, TECLA_PRESSIONADA

        li t3, ' '
        bne t4, t3, P_DM1_CONT                  
        # se ESPACO pressionado:
        #       se nao terminamos de mostrar o dialogo, TERMINA
        #       se terminamos, PULA

        lw t4, dialogo.CONTADOR_CARACTERES(t1)
        lw t5, dialogo.TAMANHO(t1)
        beq t4, t5, P_DM1_PULAR

P_DM1_IR_AO_FINAL:
        # pula pro final da string
        lw t2, dialogo.TAMANHO(t1)
        sw t2, dialogo.CONTADOR_CARACTERES(t1)
        j P_DM1_CONT

P_DM1_PULAR:
        lw t0, dialogo.PROXIMO_DIALOGO(t1)
        la t2, struct_dialogo_estatica
        sw t0, struct_dialogo_estatica.DIALOGO_ATUAL(t2)

        # libera o dialogo (eliminando-o)
        mv a0, t1
        jal PROC_FREE

        la t0, struct_dialogo_estatica
        lw t1, struct_dialogo_estatica.DIALOGO_ATUAL(t0)
        bnez t1, P_DM1_CONT     # se existe um dialogo proximo, continua

        # senao, termina a execucao de dialogo
        sw zero, struct_dialogo_estatica.EM_PROGRESSO(t0)
        j P_DM1_RET

P_DM1_CONT:
        # renderizar dialogo! passa o dialogo como argumento
        mv a0, t1
        jal PROC_IMPRIMIR_DIALOGO

P_DM1_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret
