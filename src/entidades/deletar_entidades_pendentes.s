# PROC_DELETAR_ENTIDADES_PENDENTES
#
# Deleta todas as entidades marcadas para serem
# removidas

PROC_DELETAR_ENTIDADES_PENDENTES:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)

        lw s0, tamanho_array_entidades
        li t0, array_entidades.BYTES_POR_ENTRADA
        sub s0, s0, t0         # comeca em array_entidades[array_entidades.size()-1]

        # for (int i = n - 1; i >= 0; --i) {
        #       if (!entity[i].pending_delete) continue;
        #
        #       free(entity[i]);
        #       entity[i] = entity[n - 1];
        #       --n;
        # }
P_DE1_DELETAR_LOOP:
        bltz s0, P_DE1_RET                      # termina se i < 0

        la t0, array_entidades
        add a0, t0, s0
        lw t0, (a0)                             # pega a proxima entidade no array

        lw t1, entidade.FLAGS(t0)
        
        andi t1, t1, FLAG_ENTIDADE_DELECAO_PENDENTE
        beqz t1, P_DE1_CONTINUE                 # se a entidade nao estah marcada para delecao, continua

        jal PROC_REMOVER_ENTIDADE               # remove a entidade

P_DE1_CONTINUE:
	li t0, array_entidades.BYTES_POR_ENTRADA
        sub s0, s0, t0                          # vai pra proxima entidade
        j P_DE1_DELETAR_LOOP

P_DE1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret
