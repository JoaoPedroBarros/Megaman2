#################################################################
# ROTINA_DEBUG           			       	     	#
# Mostra informacoes de debug                                   #
#################################################################

# prefixo_interno: R_D1_ 

.data

        CONTADOR_FRAMES: .word 0
        DEBUG_FRASE_FPS: .asciz "FPS: "
        DEBUG_FRASE_CICLOS: .asciz "FREQ: ~"
        DEBUG_FRASE_CICLOS_CONT: .asciz " MHz"
        DEBUG_FRASE_CUSTO: .asciz "FPS/100MHz: "

        PRINT_TIMESTAMP:        .word 0
.text

PROC_DEBUG:
        addi sp, sp, -4
        sw ra, (sp)

        # adiciona um ao contador
        la t0, CONTADOR_FRAMES
        lw t1, (t0)
        addi t1, t1, 1
        sw t1, (t0)

        csrr t4, time

        lw t2, PRINT_TIMESTAMP
        sub t2, t4, t2          # t2 = tempo desde PRINT_TIMESTAMP
        li t3, 1000
        sub t5, t2, t3          # t5 = tempo desde PRINT_TIMESTAMP - 1 segundo
        bltz t5, P_D1_RET       # se ainda nao se passou 1 segundo, nao imprime

        sw t4, PRINT_TIMESTAMP, t2 # salva que printamos

        print(DEBUG_FRASE_FPS)
        print_int_ln(t1)

        addi sp, sp, -4
        sw s0, (sp)             # empilha s0

        mv s0, t1               # guarda a qtd de FPS

        # agora calcular a frequencia
        li a0, 10               # argumento: levar em media 10 milissegundos
        jal PROC_CALCULAR_FREQUENCIA_CPU
        mv t0, a0               # retorno: frequencia medida

        li t1, 1000000
        div t1, t0, t1          # pega em MHz

        li t2, 100
        mul t2, s0, t2          # pega 100*FPS
        div t2, t2, t1          # pega 100*FPS / MHz (= FPS/100MHz)

        # imprime o numero de frames no ultimo segundo e a frequencia da CPU
        print(DEBUG_FRASE_CICLOS)
        print_int(t1)
        print(DEBUG_FRASE_CICLOS_CONT)
        quebra_de_linha
        print(DEBUG_FRASE_CUSTO)
        print_int(t2)
        quebra_de_linha
        quebra_de_linha

        sw zero, CONTADOR_FRAMES, t0 # reseta o contador

        lw s0, (sp)
        addi sp, sp, 4  # desempilha s0

P_D1_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret


