# PROC_ADICIONAR_ENTIDADE
# Cria uma entidade em uma posicao X Y e adiciona ela ah lista de entidades.
#
# ARGUMENTOS
#       a0 - tipo da entidade (ver definicoes_entidades.s)
#       a1 - posicao X (absoluta)
#       a2 - posicao Y (absoluta)
# RETORNO
#       (nenhum)

PROC_ADICIONAR_ENTIDADE:
        addi sp, sp, -16
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)

        la s0, lista_entidades
        mv s1, a1       # salva X
        mv s2, a2       # salva Y

P_AE1_PROCURAR_LOOP:
        lw t1, lista_entidades.TIPO_ENTRADA(s0) # pega o tipo da entrada na tabela
        bltz t1, P_AE1_RET              # se < 0, significa que chegamos ao fim da tabela sem encontrara a entidade.
        beq a0, t1, P_AE1_REGISTRAR     # se tipo_tabela == tipo_argumento, encontramos! registrar
        addi s0, s0, lista_entidades.BYTES_POR_ENTRADA # pula para a proxima entrada
        j P_AE1_PROCURAR_LOOP           # continua procurando se nao encontramos ainda

P_AE1_REGISTRAR:

        lw t0, lista_entidades.TAMANHO_STRUCT_ENTRADA(s0)
        li t1, struct_basica_entidade.TAMANHO
        add a0, t0, t1 
        jal PROC_MALLOC         # aloca espaco para a struct basica e a struct especifica!   

        # pula pro proximo espaco livre no array de *entidades*
        la t3, array_entidades
        la t4, tamanho_array_entidades
        lw t5, (t4)
        add t3, t3, t5

        # "aloca" uma entrada de entidade no array
        addi t5, t5, array_entidades.BYTES_POR_ENTRADA
        sw t5, (t4)

        # salva a entidade
        sw a0, array_entidades.STRUCT_BASICA(t3)
        lw t5, lista_entidades.PROC_POR_FRAME(s0)
        sw t5, array_entidades.PROC_POR_FRAME(t3)
        lw t5, lista_entidades.PROC_DESENHAR(s0)
        sw t5, array_entidades.PROC_DESENHAR(t3)

        # guarda a referencia para a struct especifica dela
        # vamos guarda-la imediatamente depois da struct basica, no espaco alocado!
        addi t0, a0, struct_basica_entidade.TAMANHO 
        sw t0, entidade.STRUCT_ESPECIFICA(a0)

        # guarda posicao tbm
        sw s1, entidade.X(a0)
        sw s2, entidade.Y(a0)

        # chama a funcao de criacao passando a struct basica e a posicao X e Y
        # a0 - STRUCT BASICA - jah posicionado
        mv a1, s1               # recupera X
        mv a2, s2               # recupera Y
        lw t0, lista_entidades.PROC_DE_CRIACAO(s0)
        jalr ra, t0, 0          # pula pro procedimento de criacao da entidade
        
P_AE1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        addi sp, sp, 16
        ret