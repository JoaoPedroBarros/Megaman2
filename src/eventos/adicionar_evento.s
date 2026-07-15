# PROC_ADICIONAR_EVENTO
#
# Agenda um evento para acontecer em um frame especifico.
#
# Argumentos:
# a0 - procedimento do evento (endereco da proc para ser chamada)
# a1 - dados do evento (ponteiro contendo o argumento para ser passado ah proc)
# a2 - numero do frame para executar o evento
#
# Retornos:
# a0 - endereco do evento adicionado

PROC_ADICIONAR_EVENTO:
        addi sp, sp, -16
        sw ra, (sp)
        # salva os argumentos
        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a2, 12(sp)

        lw t0, qtd_de_eventos   # pega a quantidade de eventos
        li t1, ESPACO_ARRAY_EVENTOS
        srai t1, t1, 2          # pega o maximo de eventos possiveis (espaco_eventos/sizeof(Evento*))
        beq t1, t0, P_AE2_FALHA # retorna se o maximo de eventos ja foi atingido!

        li a0, struct_evento.TAMANHO_STRUCT     # aloca um evento
        jal PROC_MALLOC
        beqz a0, P_AE2_FALHA    # retorna nulo se o malloc falhar

        

        # recupera os argumentos
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw t2, 12(sp)

        sw t0, struct_evento.PROC(a0)
        sw t1, struct_evento.DADOS(a0)
        sw t2, struct_evento.FRAME_EXEC(a0)
        li t0, 1
        sw t0, struct_evento.ATIVO(a0)

        la t0, qtd_de_eventos
        lw t1, (t0)
        slli t2, t1, 4
        la t3, array_eventos
        add t3, t2, t3
        sw a0, (t3)     # salva o evento

        addi t1, t1, 1
        sw t1, (t0)     # incrementa a quantidade de eventos
        
P_AE2_RET:
        lw ra, (sp)
        addi sp, sp, 16
        ret

P_AE2_FALHA:
        li a0, 0        # retorna nulo
        j P_AE2_RET