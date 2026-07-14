# PROC_EXECUTAR_ANIMACAO
#
# Executa um script de animacao
#
# a0 - struct de controller de animacao



PROC_EXECUTAR_ANIMACAO:
        lw t0, struct_animacao_controller.PC(a0)
        beqz t0, P_EA1_RET # se !pc, nao faz nada
        lw t1, struct_animacao_controller.WAIT_TIMER(a0)
        beqz t1, P_EA1_DECODIFICAR_INSTRUCAO # se o timer de wait n estah ativo, nao espera

P_EA1_CONTINUA_ESPERANDO:
        addi t1, t1, -1
        sw t1, struct_animacao_controller.WAIT_TIMER(a0)
        bgtu t1, zero, P_EA1_RET # se timer > 0, terminamos

P_EA1_DECODIFICAR_INSTRUCAO:

        lw t2, instr_animacao.OPCODE(t0)        # carrega o opcode da instrucao atual
        lw t3, instr_animacao.OPERANDO(t0)      # e o operando

P_EA1_SWITCH:
        li t4, OP_WAIT
        beq t2, t4, P_EA1_WAIT
        li t4, OP_SETSPRITE
        beq t2, t4, P_EA1_SETSPRITE
        li t4, OP_SETPAL
        beq t2, t4, P_EA1_SETPALETA
        li t4, OP_SETFRAME
        beq t2, t4, P_EA1_SETFRAME
        li t4, OP_SETANIM
        beq t2, t4, P_EA1_SETANIM
        li t4, OP_JUMP
        beq t2, t4, P_EA1_JUMP
        li t4, OP_END
        beq t2, t4, P_EA1_END
        
P_EA1_ERRO:                     # opcode invalido
        sw zero, struct_animacao_controller.PC(a0)
        # print mensagem de debug
        j P_EA1_RET

P_EA1_WAIT:
        addi t0, t0, 8
        sw t0, struct_animacao_controller.PC(a0)
        sw t3, struct_animacao_controller.WAIT_TIMER(a0)
        j P_EA1_RET # coloca para esperar e sai

P_EA1_SETSPRITE:
        sw t3, struct_animacao_controller.SPRITE(a0)
        j P_EA1_PROXIMA_INSTRUCAO

P_EA1_SETPALETA:
        sw t3, struct_animacao_controller.PALETA(a0)
        j P_EA1_PROXIMA_INSTRUCAO

P_EA1_SETFRAME:
        sw t3, struct_animacao_controller.FRAME(a0)
        j P_EA1_PROXIMA_INSTRUCAO

P_EA1_SETANIM:
        sw t3, struct_animacao_controller.PC(a0)
        sw t3, struct_animacao_controller.ANIMACAO(a0)
        mv t0, t3 
        j P_EA1_DECODIFICAR_INSTRUCAO # comeca a executar a partir da nova animacao

P_EA1_JUMP:
        slli t3, t3, 3
        add t0, t0, t3                  # avanca t3 instrucoes para frente (+) ou para tras (-)
        sw t0, struct_animacao_controller.PC(a0)        
        j P_EA1_DECODIFICAR_INSTRUCAO   # decodifica a nova instrucao

P_EA1_END:
        sw zero, struct_animacao_controller.PC(a0)
        j P_EA1_RET

P_EA1_PROXIMA_INSTRUCAO:
        lw t0, struct_animacao_controller.PC(a0)
        addi t0, t0, 8
        sw t0, struct_animacao_controller.PC(a0)        # avanca para a proxima instrucao
        j P_EA1_DECODIFICAR_INSTRUCAO

P_EA1_RET:
        ret