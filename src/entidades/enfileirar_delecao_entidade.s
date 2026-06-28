# PROC_ENFILEIRAR_DELECAO_ENTIDADE
#
# Coloca entidade na fila para ser deletada ao final do frame
# Importante: Entidades em si nao devem usar esse procedimento,
# ajustando, em vez disso, o valor de retorno das procs
# relevantes.
#
# a0 - endereco da entrada da entidade no array de entidades

PROC_ENFILEIRAR_DELECAO_ENTIDADE:
        la t0, fila_entidades_a_serem_deletadas
        la t1, tamanho_fila_entidades_a_serem_deletadas
        lw t2, (t1)                             # pega n
        add t0, t0, t2                          # pega &fila[n]
        sw a0, (t0)                             # salva em &fila[n]
        addi t2, t2, 4
        sw t2, (t1)                             # n++
        ret