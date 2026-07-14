# PROC_ROLAR_POWERUP
#
# Cria (ou nao) um powerup de acordo com 
# uma drop table.
#
# Argumentos:
# a0 - entidade
# a1 - drop_table
#
# (sem retornos)

PROC_ROLAR_POWERUP:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        beqz a1, P_RP1_RET # se !drop_table, retorna

        # guarda os argumentos!
        mv s0, a0
        mv s1, a1

        # numero aleatorio em [0, 100[
        csrr a0, cycle # semente aleatoria (irrelevante no DE1, mas necessario no RARS e FPGRARS)
        li a1, 100
        li a7, 42
        
        ecall
        # numero aleatorio em a0

P_RP1_LOOP:
        lbu t1, DROP.PESO(s1)           # pega o peso da proxima entrada
        beqz t1, P_RP1_RET              # retorna se chegamos no final da tabela (peso 0)
        sub a0, a0, t1          
        bltz a0, P_RP1_ADICIONAR        # se o numero aleatorio corresponde a essa entrada, faz o drop de acordo com ela
        addi s1, s1, DROP.TAMANHO       # senao, avanca para a proxima entrada e continua o loop
        j P_RP1_LOOP
        
P_RP1_ADICIONAR:
        lbu t1, DROP.TIPO(s1)
        beqz t1, P_RP1_RET              # se o tipo for TIPO_NULO, nao devemos dropar nada

        # senao, spawna um powerup
        li a0, ENTIDADE_POWERUP
        lw a1, entidade.X_Q12(s0)
        srai a1, a1, 12
        lw a2, entidade.Y_Q12(s0)
        srai a2, a2, 12
        jal PROC_ADICIONAR_ENTIDADE

        # e coloca o tipo correspondente

        # a0 = powerup, ja carregado
        lbu a1, DROP.TIPO(s1)
        lbu a2, DROP.VALOR(s1)
        li a3, ENTIDADE_POWERUP.TEMPO_PADRAO
        jal ENTIDADE_POWERUP.INIT # inicia o powerup com o tipo e valor corretos

P_RP1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret