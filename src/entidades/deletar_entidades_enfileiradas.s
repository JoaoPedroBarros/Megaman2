# PROC_DELETAR_ENTIDADES_ENFILEIRADAS
#
# Consome a fila de entidades a serem deletadas, apagando
# cada uma das entidades na fila

PROC_DELETAR_ENTIDADES_ENFILEIRADAS:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)

        lw s0, tamanho_fila_entidades_a_serem_deletadas
        addi s0, s0, -4         # comeca em queue[queue.size()-1]

        # for (int i = queue.size(), i >= 0, i--)
        #               remove_entity(queue[i]);
        #       
P_DE1_DELETAR_LOOP:
        bltz s0, P_DE1_DELETAR_FIM               # termina se i < 0

        la t0, fila_entidades_a_serem_deletadas
        add t0, t0, s0
        lw a0, (t0)                             # pega a proxima entidade na fila
        jal PROC_REMOVER_ENTIDADE               # remove a entidade

        addi s0, s0, -4                          # vai pra proxima entidade
        j P_DE1_DELETAR_LOOP

P_DE1_DELETAR_FIM:
        sw zero, tamanho_fila_entidades_a_serem_deletadas, t0

P_DE1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret