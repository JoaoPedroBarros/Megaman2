# PROC_COLISOES_MANAGER
#
# Administra colisoes entre entidades

PROC_COLISOES_MANAGER:
        addi sp, sp, -28
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)
        sw s4, 20(sp)
        sw s5, 24(sp)

        mv s0, zero                             # i = 0
        lw s1, tamanho_array_entidades          # i < bytes_utilizados
P_CM2_LOOP:
        bge s0, s1, P_EM1_RET                   # se !(i < qtd_entidades), break

        la s2, array_entidades
        add s3, s2, s0                         # pega &array_entidades[i]

        lw t0, array_entidades.STRUCT_BASICA(s3)
        lw t1, entidade.COLIDIVEL(t0)
        beqz t1, P_CM2_CONTINUE                 # pula a entidade se ela nao puder colidir!

        addi s4, s0, array_entidades.BYTES_POR_ENTRADA                          # i = j+1
        P_CM2_CHECAR_COLISAO_LOOP:
                
                bge s4, s1, P_CM2_CHECAR_COLISAO_LOOP_FIM # se !(j < qtd_entidades), break
                add s5, s2, s4                  # pega &array_entidades[j]
                lw t1, array_entidades.STRUCT_BASICA(s5)
                lw t2, entidade.COLIDIVEL(t1)
                beqz t2, P_CM2_CHECAR_COLISAO_LOOP_CONTINUE     # se !array_entidades[j]->struct->colidivel nao colide!

                #senao, verifica se houve a colisao
                mv a0, t1
                lw a1, array_entidades.STRUCT_BASICA(s3)
                jal PROC_DETECTAR_COLISAO
                beqz a0, P_CM2_CHECAR_COLISAO_LOOP_CONTINUE

                # se HOUVE colisao

        P_CM2_CHECAR_COLISAO_LOOP_ENTIDADE2:
                lw a0, array_entidades.STRUCT_BASICA(s5)
                lw a1, array_entidades.STRUCT_BASICA(s3)
                lw t0, array_entidades.PROC_COLISAO(s5)
                jalr ra, t0, 0                          # chama a proc de colisao da entidade 2

                bnez a0, P_CM2_CHECAR_COLISAO_LOOP_ENTIDADE1
                # se entidade retornou que morreu, deleta ela

                mv a0, s5
                jal PROC_ENFILEIRAR_DELECAO_ENTIDADE
                lw t0, array_entidades.STRUCT_BASICA(s5)
                sw zero, entidade.COLIDIVEL(t0)

        P_CM2_CHECAR_COLISAO_LOOP_ENTIDADE1:
                lw a0, array_entidades.STRUCT_BASICA(s3)
                lw a1, array_entidades.STRUCT_BASICA(s5)
                lw t0, array_entidades.PROC_COLISAO(s3)
                jalr ra, t0, 0                          # chama a proc de colisao da entidade 1

                bnez a0, P_CM2_CHECAR_COLISAO_LOOP_CONTINUE
                # se entidade retornou que morreu, deleta ela

                mv a0, s3
                jal PROC_ENFILEIRAR_DELECAO_ENTIDADE
                lw t0, array_entidades.STRUCT_BASICA(s3)
                sw zero, entidade.COLIDIVEL(t0)
                j P_CM2_CHECAR_COLISAO_LOOP_FIM # TERMINA o loop para essa entidade se ela nao existe mais!!

        P_CM2_CHECAR_COLISAO_LOOP_CONTINUE:
                addi s4, s4, array_entidades.BYTES_POR_ENTRADA
                
                j P_CM2_CHECAR_COLISAO_LOOP

        P_CM2_CHECAR_COLISAO_LOOP_FIM:
P_CM2_CONTINUE:
        addi s0, s0, array_entidades.BYTES_POR_ENTRADA # vai pra proxima entidade
        j P_CM2_LOOP                            # continua o loop

P_CM2_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        lw s4, 20(sp)
        lw s5, 24(sp)
        addi sp, sp, 28
        ret
