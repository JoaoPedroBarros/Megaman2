# PROC_REMOVER_ENTIDADE
# Remove uma entidade da memoria.
#
# Argumentos:
# a0 - endereco da entrada da entidade no array de entidades
#
# (sem retornos)

PROC_REMOVER_ENTIDADE:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)

        la t0, array_entidades
        blt a0, t0, P_RE1_RET      # retorna se &entidade < &array_entidades

        lw t1, tamanho_array_entidades
        add t0, t0, t1
        bgt a0, t0, P_RE1_RET      # retorna se &entidade > &array_entidades[n-1]

        mv s0, a0               # guarda a entidade em um registrador seguro

P_RE1_FREE:
        lw a0, array_entidades.STRUCT_BASICA(s0)
        jal PROC_FREE           # libera o espaco de uma entidade

P_RE1_SWAP:
        la t0, array_entidades
        lw t1, tamanho_array_entidades

        add t0, t0, t1
        li t2, array_entidades.BYTES_POR_ENTRADA
        sub t0, t0, t2          # pega a ultima entidade (E[n-1])

# vamos colocar a ultima entidade no lugar da atual que nao existe mais
P_RE1_SWAP_LOOP:
        lw t1, (t0)
        sw t1, (s0)
        addi t2, t2, -4
        addi t0, t0, 4
        addi s0, s0, 4
        bgtz t2, P_RE1_SWAP_LOOP    # continua se ainda faltam bytes para serem swappados
        
        # decrementa o tamanho do array de entidades em 1 entidade.
        la t0, tamanho_array_entidades
        li t1, array_entidades.BYTES_POR_ENTRADA
        lw t2, (t0)
        sub t2, t2, t1
        sw t2, (t0)

P_RE1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret