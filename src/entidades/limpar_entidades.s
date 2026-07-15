# PROC_LIMPAR_ENTIDADES
#
# Remove TODAS as entidades.
#
# (sem argumentos, retornos)

PROC_LIMPAR_ENTIDADES:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        la s0, array_entidades
        lw s1, tamanho_array_entidades
        add s1, s1, s0
        P_LE2_LOOP:
                bge s0, s1, P_LE2_LOOP_FIM

                lw a0, array_entidades.STRUCT_BASICA(s0)
                lw t0, array_entidades.PROC_DESTRUTOR(s0)
                jalr ra, t0, 0  # chama o destrutor

                lw a0, array_entidades.STRUCT_BASICA(s0)
                jal PROC_FREE
                
                addi s0, s0, array_entidades.BYTES_POR_ENTRADA
                j P_LE2_LOOP
        P_LE2_LOOP_FIM:
        sw zero, tamanho_array_entidades, t0
        
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret
        
