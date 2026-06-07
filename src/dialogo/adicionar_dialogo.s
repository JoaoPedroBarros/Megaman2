# PROC_ADICIONAR_DIALOGO
# 
# Coloca um dialogo na fila de dialogos
#
# Argumentos:
# a0 - String de dialogo
# a1 - Nome a ser mostrado no dialogo (nome de quem estah falando)
# a2 - Frames entre cada caractere
#        ( quanto MENOR, MAIS RAPIDO vai ser o texto
#          0 = sem efeito typewriter
#          recomendado: 2 frames/caractere )

PROC_ADICIONAR_DIALOGO:
        addi sp, sp, -20
        sw ra, (sp)
        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a2, 12(sp)
        sw s0, 16(sp)

        # aloca espaco para novo dialogo
        li a0, dialogo.TAMANHO_STRUCT
        jal PROC_MALLOC
        beqz a0, P_AD1_RET              # cancela se memoria insuficiente!
        
        mv s0, a0                       # guarda o endereco da struct nova

        # salva os parametros da string
        lw a0, 4(sp)    
        sw a0, dialogo.STRING(s0)   
        jal PROC_TAMANHO_STRING
        sw a0, dialogo.TAMANHO(s0)
        sw zero, dialogo.CONTADOR_CARACTERES(s0)
        sw zero, dialogo.CONTADOR_FRAMES(s0)
        lw t0, 8(sp)
        sw t0, dialogo.NOME_FALANTE(s0)
        lw t0, 12(sp)
        sw t0, dialogo.DELAY_ENTRE_CARACTERES(s0)
        sw t0, dialogo.FRAME_PROXIMO_CARACTERE(s0)      # proximo caractere = 0 + delay
        sw zero, dialogo.PROXIMO_DIALOGO(s0)    # ultimo da fila


        la t0, struct_dialogo_estatica
        lw t1, struct_dialogo_estatica.EM_PROGRESSO(t0)
        bnez t1, P_AD1_ENFILEIRAR # se houver dialogo na fila, coloca.
        # senao, ativa o dialogo e coloca o atual como primeiro da fila
        # (note que, mais a frente, tambem vai ser o ultimo, visto que
        # a fila so vai ter um elemento!)
        li t1, 1
        sw t1, struct_dialogo_estatica.EM_PROGRESSO(t0)
        sw s0, struct_dialogo_estatica.DIALOGO_ATUAL(t0)
        j P_AD1_FINALIZAR
P_AD1_ENFILEIRAR:
        lw t1, struct_dialogo_estatica.ULTIMO_DIALOGO_DA_FILA(t0)
        sw s0, dialogo.PROXIMO_DIALOGO(t1)
P_AD1_FINALIZAR:
        sw s0, struct_dialogo_estatica.ULTIMO_DIALOGO_DA_FILA(t0)       # coloca no final da fila

P_AD1_RET:
        lw ra, (sp)
        lw s0, 16(sp)
        addi sp, sp, 20
        ret
