# HEAP
# A memoria global alocavel e desalocavel 
# acessada por malloc e free

# MANTER VALORES BINARIOS ABAIXO COMO POTENCIAS DE 2 !!!!!
.eqv HEAP_TAMANHO 32738                 # 32 KiB
.eqv HEAP_REGISTRO_TAMANHO 2048         # 2 KiB

.eqv REGISTRO_RAZAO 16                  # 1B de registro para cada 16B de heap
.eqv REGISTRO_RAZAO_POTENCIA_2 4        # 16 = 2^4

.data

.align 2                                # alinha com words para impedir problemas de misaligned access
memoria_heap:                   .space HEAP_TAMANHO 
memoria_heap_registro_alocacao: .space HEAP_REGISTRO_TAMANHO