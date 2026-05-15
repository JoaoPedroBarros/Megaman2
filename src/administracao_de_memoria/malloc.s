# PROC_MALLOC
# Aloca uma quantidade de bytes na memoria.
#
# ARGUMENTOS:
# a0 - tamanho em bytes
# 
# RETORNOS:
# a0 - ponteiro ah posicao (0, se nao hah memoria disponivel!)

PROC_MALLOC:
        beqz a0, P_M1_NAO_ENCONTRADO    # primeiramente, falha se o tamanho for 0

        la t1, memoria_heap_registro_alocacao

        # divide por REGISTRO_RAZAO, rounding up, para saber quantos enderecos alocar
        addi a0, a0, REGISTRO_RAZAO
        addi a0, a0, -1
        srli a0, a0, REGISTRO_RAZAO_POTENCIA_2 

        # precisamos pegar um bloco de tamanho a0
        # entao precisamos parar assim que atingirmos o primeiro endereco que nao tem esse tamanho de bloco
        # (no caso: registro+TAMANHO-a0+1)
        li t0, HEAP_REGISTRO_TAMANHO
        add t2, t1, t0
        sub t2, t2, a0
        addi t2, t2, 1

P_M1_CHECK_REGISTRO_LOOP:
        mv t3, a0       # quantidade de enderecos que precisamos checar
        mv t4, t1       # a partir da onde vamos checar
        P_M1_CHECK_ATUAL_LOOP:
                lb t0, (t4)
                bnez t0, P_M1_PULAR_ENDERECOS_OCUPADOS
                addi t3, t3, -1
                addi t4, t4, 1  # avanca para a proxima casa
                bgtz t3, P_M1_CHECK_ATUAL_LOOP # (checa a0 posicoes)
        j P_M1_ENCONTRADO       # se nenhum endereco nao_vazio foi encontrado na checagem... achamos um espaco vazio grande o suficiente!

P_M1_PULAR_ENDERECOS_OCUPADOS:
        # pula a quantidade de enderecos ocupados no segmento atual
        add t1, t4, t0  # (a partir de onde encontramos o byte ocupado!)
        bltu t1, t2, P_M1_CHECK_REGISTRO_LOOP       # continua a checagem se ainda existirem enderecos disponiveis para checar
        j P_M1_NAO_ENCONTRADO   # se passamos por todos os enderecos do registro sem encontrar nada, entao nao tem nenhum espaco livre!

P_M1_NAO_ENCONTRADO:
        # nao encontramos: retorna endereco nulo
        mv a0, zero
        ret

P_M1_ENCONTRADO:
        # encontramos um endereco! 
        la t0, memoria_heap_registro_alocacao
        sub t0, t1, t0          # pega o quanto andamos no registro ateh encontrarmos o espaco livre
        slli t0, t0, REGISTRO_RAZAO_POTENCIA_2 # (em bytes)

        la t4, memoria_heap     
        add t4, t4, t0          # avanca ateh o bloco encontrado

P_M1_RESERVA_ESPACO_LOOP:
        # reserva a0 bytes, escrevendo a quantidade de bytes ateh o final desse segmento de memoria alocado
        # [a0, a0-1, ..., 2, 1]
        sb a0, (t1)
        addi t1, t1, 1
        addi a0, a0, -1
        bgtz a0, P_M1_RESERVA_ESPACO_LOOP

P_M1_RETORNAR_ENDERECO:
        mv a0, t4
        ret            # retorna o endereco na heap