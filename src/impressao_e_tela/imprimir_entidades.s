# PROC_IMPRIMIR_ENTIDADES
#
# Imprime todas as entidades

PROC_IMPRIMIR_ENTIDADES:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        mv s0, zero                             # i = 0
        lw s1, tamanho_array_entidades          # i < bytes_utilizados
P_IE1_LOOP:
        bge s0, s1, P_IE1_RET                   # se !(i < qtd_entidades), retorna

        la t0, array_entidades
        add t0, t0, s0                         # pega &array_entidades[i]

        lw a0, array_entidades.STRUCT_BASICA(t0)
        lw t0, array_entidades.PROC_DESENHAR(t0)
        jalr ra, t0, 0                          # realiza o procedimento por frame

        addi s0, s0, array_entidades.BYTES_POR_ENTRADA # vai pra proxima entidade
        j P_IE1_LOOP                            # continua o loop
P_IE1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret
