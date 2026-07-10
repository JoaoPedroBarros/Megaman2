# PROC_EVENTOS_MANAGER
#
# Administra os eventos existentes.
#
# (sem argumentos, retornos)

PROC_EVENTOS_MANAGER:
        addi sp, sp, -16
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)


        # for (int i = qtd_de_eventos-1; i >= 0; i--)
        lw s0, qtd_de_eventos
        addi s0, s0, -1
P_EM2_FOR_LOOP:
                bltz s0, P_EM2_RET

                slli t0, s0, 2
                la t1, array_eventos
                add s1, t1, t0          # pega eventos[i] (Evento*)
                lw s2, (s1)             # pega a struct de evento
                lw t3, struct_evento.ATIVO(s2)
                beqz t3, P_EM2_REMOVER_EVENTO   # remove o evento se inativo!

                lw t0, struct_evento.FRAME_EXEC(s2)
                lw t1, frame_counter
                bgt t0, t1, P_EM2_FOR_LOOP_CONT # nao executa se (eventos[i]->frame > frame_atual)

        P_EM2_EXECUTAR_EVENTO:
                lw t0, struct_evento.PROC(s2)
                lw a0, struct_evento.DADOS(s2)
                jalr ra, t0, 0                  # executa o procedimento do evento
        
        P_EM2_REMOVER_EVENTO:
                la t0, qtd_de_eventos
                lw t1, (t0)
                addi t1, t1, -1
                sw t1, (t0)             # decrementa qtd_de_eventos
                slli t1, t1, 2
                la t0, array_eventos
                add t0, t0, t1          # pega eventos[--qtd_de_eventos]

                lw t1, (t0)
                sw t1, (s1)             # eventos[i] = eventos[--qtd_de_eventos]

                mv a0, s2
                jal PROC_FREE           # da free no eventos[i] antigo

        P_EM2_FOR_LOOP_CONT:
                addi s0, s0, -1
                j P_EM2_FOR_LOOP

P_EM2_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        addi sp, sp, 16
        ret

#eventos_manager(){
#.   for (int i = qtd_de_eventos-1; i >= 0; i--)
#.   {
#.       if (!eventos[i]->ativo){
#.               free(eventos[i]);
#.               eventos[i] = eventos[--qtd_de_eventos];
#.               continue;
#.       }
#.       if (eventos[i]->frame <= frame_atual)
#.       {
#.           eventos[i]->proc(eventos[i]->dados);
#.           free(eventos[i]);
#.
#.           eventos[i] = eventos[--qtd_de_eventos];
#.       }
#.   }
#}