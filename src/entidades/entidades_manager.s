# PROC_ENTIDADES_MANAGER
#
# Administra todas as entidades

PROC_ENTIDADES_MANAGER:
        addi sp, sp, -16
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)

        mv s0, zero                             # i = 0
        lw s1, tamanho_array_entidades          # i < bytes_utilizados
P_EM1_LOOP:
        bge s0, s1, P_EM1_RET                   # se !(i < qtd_entidades), break

        la s2, array_entidades
        add s2, s2, s0                         # pega &array_entidades[i]

        lw a0, array_entidades.STRUCT_BASICA(s2)
        lw t0, array_entidades.PROC_POR_FRAME(s2)
        jalr ra, t0, 0                          # realiza o procedimento por frame, passando a struct como argumento

        addi s0, s0, array_entidades.BYTES_POR_ENTRADA # vai pra proxima entidade

        bnez a0, P_EM1_LOOP                     # continua o loop se a entidade ainda existe

        mv a0, s2
        jal PROC_ENFILEIRAR_DELECAO_ENTIDADE    # coloca a entidade para ser deletada
        lw t0, array_entidades.STRUCT_BASICA(s2)
        sw zero, entidade.COLIDIVEL(t0)         # marca ela como nao colidivel para garantir que ela nao interaja com
                                                # outras entidades antes de ser deletada

        j P_EM1_LOOP                            # continua o loop

P_EM1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        addi sp, sp, 16
        ret
