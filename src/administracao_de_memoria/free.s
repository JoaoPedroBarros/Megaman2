# PROC_FREE
# Libera um endereco de memoria alocada da heap
#
# ARGUMENTOS:
# a0 - endereco de memoria alocado
#
# (sem retorno)

PROC_FREE:
        la t0, memoria_heap

        # retorna se o endereco nao pertencer ah heap
        bltu a0, t0, PROC_RET   
        li t1, HEAP_TAMANHO
        add t1, t1, t0
        bgeu a0, t1, PROC_RET

        # pega o index correspondente no registro
        sub t0, a0, t0
        srli t0, t0, REGISTRO_RAZAO_POTENCIA_2
        la t1, memoria_heap_registro_alocacao
        add t1, t1, t0

        lb t2, (t1)     # pega a qtd de bytes alocados no segmento
        beqz t2, PROC_RET # retorna se a qtd for 0 (o endereco jah estah livre!)

        # escreve 0 em cada casa do registro que estava ocupada pela alocacao
P_F2_LIBERAR_LOOP:
        sb zero, (t1)
        addi t2, t2, -1
        addi t1, t1, 1
        bgtz t2, P_F2_LIBERAR_LOOP

PROC_RET:
        ret