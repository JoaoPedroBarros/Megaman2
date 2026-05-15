# PROC_INICIALIZAR_HEAP
# limpa a heap e a deixa disponivel para uso.

PROC_INICIALIZAR_HEAP:
        la t0, memoria_heap_registro_alocacao
        li t1, HEAP_REGISTRO_TAMANHO
P_IH1_LOOP:
        sw zero, (t0)           # zera 4 bytes de registro
        addi t0, t0, 4          # avanca para os proximos 4
        addi t1, t1, -4         # reduz 4 no contador de bytes faltando
        bgtz t1, P_IH1_LOOP     # se ainda tem bytes no contador, continua
        
        ret                     # termina


