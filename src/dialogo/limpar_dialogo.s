# PROC_LIMPAR_DIALOGO
#
# Limpa a fila de dialogo
#
# (sem argumentos, retornos)

PROC_LIMPAR_DIALOGO:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)

        la t0, struct_dialogo_estatica

        lw s0, struct_dialogo_estatica.DIALOGO_ATUAL(t0)
        beqz s0, P_LD1_RET      # retorna se nao tem nenhum dialogo atualmente

        # salva que nao estah mais em progresso
        sw zero, struct_dialogo_estatica.EM_PROGRESSO(t0)
        sw zero, struct_dialogo_estatica.ULTIMO_DIALOGO_DA_FILA(t0)

P_LD1_LOOP:
        mv a0, s0
        lw s0, dialogo.PROXIMO_DIALOGO(s0)
        jal PROC_FREE   # libera o dialogo atual
        bnez s0, P_LD1_LOOP # continua liberando se ainda houver proximo
        
        la t0, struct_dialogo_estatica
        sw zero, struct_dialogo_estatica.DIALOGO_ATUAL(t0)
        
P_LD1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret