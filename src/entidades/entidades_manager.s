# PROC_ENTIDADES_MANAGER
#
# Administra todas as entidades

.data

        fila_entidades_a_serem_deletadas: .byte 0:ESPACO_ARRAY_ENTIDADES
        tamanho_fila_entidades_a_serem_deletadas: .word 0

.text

PROC_ENTIDADES_MANAGER:
        addi sp, sp, -16
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)

        mv s0, zero                             # i = 0
        lw s1, tamanho_array_entidades          # i < bytes_utilizados
P_EM1_LOOP:
        bge s0, s1, P_EM1_DELETAR_ENTIDADES_NA_FILA # se !(i < qtd_entidades), break

        la s2, array_entidades
        add s2, s2, s0                         # pega &array_entidades[i]

        lw a0, array_entidades.STRUCT_BASICA(s2)
        lw t0, array_entidades.PROC_POR_FRAME(s2)
        jalr ra, t0, 0                          # realiza o procedimento por frame, passando a struct como argumento

        addi s0, s0, array_entidades.BYTES_POR_ENTRADA # vai pra proxima entidade

        bnez a0, P_EM1_LOOP                     # continua o loop se a entidade ainda existe

        # adiciona o endereco da entidade na fila
        la t0, fila_entidades_a_serem_deletadas
        la t1, tamanho_fila_entidades_a_serem_deletadas
        lw t2, (t1)
        add t0, t0, t2                          # pega &fila[n]
        sw s2, (t0)                             # salva em &fila[n]
        addi t2, t2, 4
        sw t2, (t1)                             # n++

        j P_EM1_LOOP                            # continua o loop

P_EM1_DELETAR_ENTIDADES_NA_FILA:
        lw s0, tamanho_fila_entidades_a_serem_deletadas
        addi s0, s0, -4         # comeca em queue[queue.size()-1]

# for (int i = queue.size(), i >= 0, i--){
#               remove_entity(queue[i])
#       }
P_EM1_DELETAR_LOOP:
        bltz s0, P_EM1_DELETAR_FIM               # termina se i < 0

        la t0, fila_entidades_a_serem_deletadas
        add t0, t0, s0
        lw a0, (t0)                             # pega a proxima entidade na fila
        jal PROC_REMOVER_ENTIDADE               # remove a entidade

        addi s0, s0, -4                          # vai pra proxima entidade
        j P_EM1_DELETAR_LOOP

P_EM1_DELETAR_FIM:
        sw zero, tamanho_fila_entidades_a_serem_deletadas, t0

P_EM1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        addi sp, sp, 16
        ret
