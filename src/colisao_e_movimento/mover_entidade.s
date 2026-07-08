# PROC_MOVER_ENTIDADE
# Move uma entidade de acordo com a velocidade dela,
# colidindo com tiles solidos no caminho.
#
# Argumentos:
# a0 - Endereco da struct basica da entidade

PROC_MOVER_ENTIDADE:
        addi sp, sp, -32
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)
        sw s4, 20(sp)
        sw s5, 24(sp)
        sw s6, 28(sp)

        mv s0, a0               # guarda o endereco para a struct

P_ME1_EIXO_X:
        lw t5, entidade.X_Q12(s0)               
        srai t0, t5, 12                         
        lw t6, entidade.HITBOX_DESLOCAMENTO_X(s0)
        add t0, t0, t6                          # t0 = esquerda_antiga = entidade.hitbox_x

        lw t4, entidade.VELOCIDADE_X_Q12(s0)    # t4 = entidade.velocidade_x
        add t2, t5, t4                          
        srai t2, t2, 12                         
        add t2, t2, t6                          # t2 = esquerda_nova = (int) (entidade.x + entidade.velocidade_x) + entidade.hitbox_x

        lw t3, entidade.HITBOX_LARGURA(s0)     
        add t1, t3, t0
        addi t1, t1, -1                         # t1 = direita_antiga = entidade.hitbox_x + entidade.hitbox_largura - 1

        add t3, t3, t2
        addi t3, t3, -1                         # t3 = direita_nova = esquerda_nova + entidade.hitbox_largura - 1

        lw t5, entidade.Y_Q12(s0)       
        srai t5, t5, 12        
        lw t6, entidade.HITBOX_DESLOCAMENTO_Y(s0)
        add t6, t5, t6
        srai s1, t6, LOG2_TAMANHO_TILE          # s1 = tile_cima = (int) entidade.hitbox_y / TAMANHO_TILE 

        addi s2, t6, -1
        lw t6, entidade.HITBOX_ALTURA(s0)
        add s2, s2, t6
        srai s2, s2, LOG2_TAMANHO_TILE          # s2 = tile_baixo = ((int) entidade.hitbox_y + entidade.hitbox_altura - 1) / TAMANHO_TILE

        beqz t4, P_ME1_EIXO_Y                   # if (entidade.velocidade_x == 0) goto eixo_y
        blt t0, t2, P_ME1_VELOCIDADE_X_POSITIVA # if (esquerda_antiga < esquerda_nova) goto x_positivo
        blt t3, t1, P_ME1_VELOCIDADE_X_NEGATIVA # else if (direita_nova < direita_antiga) goto x_negativo
        j P_ME1_EIXO_X_APLICAR                  # else goto aplicar_velocidade_x

        P_ME1_VELOCIDADE_X_POSITIVA:
                srai s3, t1, LOG2_TAMANHO_TILE  # s3 = coluna_antiga = direita_antiga / TAMANHO_TILE
                srai s4, t3, LOG2_TAMANHO_TILE  # s4 = coluna_nova = direita_nova / TAMANHO_TILE

                addi s5, s3, 1                  # s5 = coluna = coluna_antiga + 1
                P_ME1_FOR_LOOP_COLUNA_XP:          # for (coluna = coluna_antiga + 1, coluna <= coluna_nova, coluna++)
                        bgt s5, s4, P_ME1_EIXO_X_APLICAR        

                        mv s6, s1                       # s6 = linha = tile_cima
                        P_ME1_FOR_LOOP_LINHA_XP:           # for (linha = tile_cima, linha <= tile_baixo, linha++)
                                bgt s6, s2, P_ME1_FOR_LOOP_LINHA_XP_FIM

                                mv a0, s5
                                mv a1, s6
                                jal PROC_CALCULAR_TILE_COLISAO_COLUNA_LINHA # tile = tilemap.tile_em(column, row)
                                
                                la t0, flags_tile_colisao
                                add t0, t0, a0
                                lb t0, (t0)
                                andi t0, t0, FLAG_COLISAO_DIREITA

                                beqz t0, P_ME1_FOR_LOOP_LINHA_XP_CONTINUE
                               
                                sw zero, entidade.VELOCIDADE_X_Q12(s0)  # entidade.velocidade_x = 0
                                slli t0, s5, LOG2_TAMANHO_TILE                 
                                lw t1, entidade.HITBOX_LARGURA(s0)
                                sub t0, t0, t1                  
                                lw t1, entidade.HITBOX_DESLOCAMENTO_X(s0)
                                sub t0, t0, t1
                                slli t0, t0, 12
                                sw t0, entidade.X_Q12(s0)       # entidade.x = (int_q12) (coluna * TAMANHO_TILE - entidade.hitbox_largura - entidade.hitbox_deslocamento_x)
                                j P_ME1_EIXO_Y                  # goto eixo_y

                                P_ME1_FOR_LOOP_LINHA_XP_CONTINUE:
                                addi s6, s6, 1
                                j P_ME1_FOR_LOOP_LINHA_XP
                        P_ME1_FOR_LOOP_LINHA_XP_FIM:

                        addi s5, s5, 1                   # coluna++
                        j P_ME1_FOR_LOOP_COLUNA_XP
        P_ME1_VELOCIDADE_X_NEGATIVA:
                srai s3, t0, LOG2_TAMANHO_TILE  # s3 = coluna_antiga = esquerda_antiga / TAMANHO_TILE
                srai s4, t2, LOG2_TAMANHO_TILE  # s4 = coluna_nova = esquerda_nova / TAMANHO_TILE

                addi s5, s3, -1                 # s5 = coluna = coluna_antiga - 1
                P_ME1_FOR_LOOP_COLUNA_XN:          # for (coluna = coluna_antiga - 1, coluna >= coluna_nova, coluna--)
                        blt s5, s4, P_ME1_EIXO_X_APLICAR        

                        mv s6, s1                       # s6 = linha = tile_cima
                        P_ME1_FOR_LOOP_LINHA_XN:           # for (linha = tile_cima, linha <= tile_baixo, linha++)
                                bgt s6, s2, P_ME1_FOR_LOOP_LINHA_XN_FIM

                                mv a0, s5
                                mv a1, s6
                                jal PROC_CALCULAR_TILE_COLISAO_COLUNA_LINHA # tile = tilemap.tile_em(column, row)
                                
                                la t0, flags_tile_colisao
                                add t0, t0, a0
                                lb t0, (t0)
                                andi t0, t0, FLAG_COLISAO_ESQUERDA

                                beqz t0, P_ME1_FOR_LOOP_LINHA_XN_CONTINUE
                               
                                sw zero, entidade.VELOCIDADE_X_Q12(s0)  # entidade.velocidade_x = 0
                                addi t0, s5, 1
                                slli t0, t0, LOG2_TAMANHO_TILE                                
                                lw t1, entidade.HITBOX_DESLOCAMENTO_X(s0)
                                sub t0, t0, t1

                                slli t0, t0, 12
                                sw t0, entidade.X_Q12(s0)       # entidade.x = (int_q12) ((coluna + 1) * TAMANHO_TILE) - entidade.hitbox_x
                                j P_ME1_EIXO_Y                  # goto eixo_y

                                P_ME1_FOR_LOOP_LINHA_XN_CONTINUE:
                                addi s6, s6, 1
                                j P_ME1_FOR_LOOP_LINHA_XN
                        P_ME1_FOR_LOOP_LINHA_XN_FIM:

                        addi s5, s5, -1                   # coluna--
                        j P_ME1_FOR_LOOP_COLUNA_XN

P_ME1_EIXO_X_APLICAR:
        # entidade.x = entidade.x + entidade.velocidade_x
        lw t0, entidade.X_Q12(s0)
        lw t1, entidade.VELOCIDADE_X_Q12(s0)
        add t0, t0, t1
        sw t0, entidade.X_Q12(s0)

P_ME1_EIXO_Y:
        lw t5, entidade.Y_Q12(s0)               
        srai t0, t5, 12                         
        lw t6, entidade.HITBOX_DESLOCAMENTO_Y(s0)
        add t0, t0, t6                          # t0 = topo_antigo = entidade.hitbox_y

        lw t3, entidade.HITBOX_ALTURA(s0)     
        add t1, t3, t0
        addi t1, t1, -1                         # t1 = base_antiga = entidade.hitbox_y + entidade.altura - 1

        lw t4, entidade.VELOCIDADE_Y_Q12(s0)    # t4 = entidade.velocidade_y
        add t2, t5, t4                          
        srai t2, t2, 12                         
        lw t6, entidade.HITBOX_DESLOCAMENTO_Y(s0)
        add t2, t2, t6 # t2 = topo_novo = (int) (entidade.y + entidade.velocidade_y)

        add t3, t3, t2
        addi t3, t3, -1                         # t3 = base_nova = topo_novo + entidade.altura - 1

        lw t6, entidade.X_Q12(s0)       
        srai t6, t6, 12        
        lw t5, entidade.HITBOX_DESLOCAMENTO_X(s0)
        add t6, t6, t5
        srai s1, t6, LOG2_TAMANHO_TILE          # s1 = tile_esquerda = entidade.hitbox_x / TAMANHO_TILE 

        addi s2, t6, -1
        lw t6, entidade.HITBOX_LARGURA(s0)
        add s2, s2, t6
        srai s2, s2, LOG2_TAMANHO_TILE          # s2 = tile_direita = (entidade.hitbox_x + entidade.hitbox_largura - 1) / TAMANHO_TILE

        beqz t4, P_ME1_RET                      # if (entidade.velocidade_x == 0) ret
        blt t0, t2, P_ME1_VELOCIDADE_Y_POSITIVA # if (topo_antigo < topo_novo) goto y_positivo
        blt t3, t1, P_ME1_VELOCIDADE_Y_NEGATIVA # else if (base_nova < base_antiga) goto y_negativo
        j P_ME1_EIXO_Y_APLICAR                  #  else goto aplicar_velocidade_y

        P_ME1_VELOCIDADE_Y_POSITIVA:
                sw zero, entidade.NO_CHAO(s0)   # se tiver movimento vertical, a entidade nao estah no chao! importante deixar
                                                # aq, pois a entidade so deixarah de estar no chao se houver movimento de ao
                                                # menos um pixel!

                srai s3, t1, LOG2_TAMANHO_TILE  # s3 = linha_antiga = base_antiga / TAMANHO_TILE
                srai s4, t3, LOG2_TAMANHO_TILE  # s4 = linha_nova = base_nova / TAMANHO_TILE

                addi s5, s3, 1                  # s5 = linha = linha_antiga + 1
                P_ME1_FOR_LOOP_LINHA_YP:          # for (linha = linha_antiga + 1, linha <= linha_nova, linha++)
                        bgt s5, s4, P_ME1_EIXO_Y_APLICAR        

                        mv s6, s1                       # s6 = coluna = tile_esquerda
                        P_ME1_FOR_LOOP_COLUNA_YP:           # for (coluna = tile_esquerda, coluna <= tile_direita, coluna++)
                                bgt s6, s2, P_ME1_FOR_LOOP_COLUNA_YP_FIM

                                mv a0, s6
                                mv a1, s5
                                jal PROC_CALCULAR_TILE_COLISAO_COLUNA_LINHA # tile = tilemap.tile_em(column, row)

                                li t0, TILE_COLISAO_PLATAFORMA
                                lw t1, entidade.FLAGS(s0)
                                sub t0, a0, t0
                                seqz t0, t0     # t0 = tile = PLATAFORMA
                                andi t1, t1, FLAG_ENTIDADE_IGNORAR_PLATAFORMAS
                                and t0, t1, t0

                                # if (tile == plataforma && entidade.flags[ignorar_plataformas] == true) continue
                                bnez t0, P_ME1_FOR_LOOP_COLUNA_YP_CONTINUE

                                la t0, flags_tile_colisao
                                add t0, t0, a0
                                lb t0, (t0)
                                andi t0, t0, FLAG_COLISAO_CIMA

                                beqz t0, P_ME1_FOR_LOOP_COLUNA_YP_CONTINUE
                               
                                sw zero, entidade.VELOCIDADE_Y_Q12(s0)  # entidade.velocidade_y = 0
                                slli t0, s5, LOG2_TAMANHO_TILE                 
                                lw t1, entidade.HITBOX_ALTURA(s0)
                                sub t0, t0, t1                  
                                lw t1, entidade.HITBOX_DESLOCAMENTO_Y(s0)
                                sub t0, t0, t1
                                slli t0, t0, 12
                                sw t0, entidade.Y_Q12(s0)       # entidade.y = (int_q12) (linha * TAMANHO_TILE - entidade.hitbox_altura - entidade.hitbox_deslocamento_y)
                                li t0, 1
                                sw t0, entidade.NO_CHAO(s0)
                                j P_ME1_RET                     # return

                                P_ME1_FOR_LOOP_COLUNA_YP_CONTINUE:
                                addi s6, s6, 1
                                j P_ME1_FOR_LOOP_COLUNA_YP
                        P_ME1_FOR_LOOP_COLUNA_YP_FIM:

                        addi s5, s5, 1                   # linha++
                        j P_ME1_FOR_LOOP_LINHA_YP
        P_ME1_VELOCIDADE_Y_NEGATIVA:
                sw zero, entidade.NO_CHAO(s0)   # se tiver movimento vertical, a entidade nao estah no chao!

                srai s3, t0, LOG2_TAMANHO_TILE  # s3 = linha_antiga = topo_antigo / TAMANHO_TILE
                srai s4, t2, LOG2_TAMANHO_TILE  # s4 = linha_antiga = topo_novo / TAMANHO_TILE

                addi s5, s3, -1                 # s5 = linha = linha_antiga - 1
                P_ME1_FOR_LOOP_LINHA_YN:          # for (linha = linha_antiga - 1, linha >= linha_nova, linha--)
                        blt s5, s4, P_ME1_EIXO_Y_APLICAR        

                        mv s6, s1                       # s6 = coluna = tile_esquerda
                        P_ME1_FOR_LOOP_COLUNA_YN:           # for (coluna = tile_esquerda, coluna <= tile_direita, coluna++)
                                bgt s6, s2, P_ME1_FOR_LOOP_COLUNA_YN_FIM

                                mv a0, s6
                                mv a1, s5
                                jal PROC_CALCULAR_TILE_COLISAO_COLUNA_LINHA # tile = tilemap.tile_em(column, row)
                                
                                la t0, flags_tile_colisao
                                add t0, t0, a0
                                lb t0, (t0)
                                andi t0, t0, FLAG_COLISAO_BAIXO

                                beqz t0, P_ME1_FOR_LOOP_COLUNA_YN_CONTINUE
                               
                                sw zero, entidade.VELOCIDADE_Y_Q12(s0)  # entidade.velocidade_y = 0
                                addi t0, s5, 1
                                slli t0, t0, LOG2_TAMANHO_TILE            
                                lw t1, entidade.HITBOX_DESLOCAMENTO_Y(s0)
                                sub t0, t0, t1                    
                                slli t0, t0, 12
                                sw t0, entidade.Y_Q12(s0)       # entidade.x = (int_q12) ((linha + 1) * TAMANHO_TILE) - entidade.hitbox_deslocamento_y
                                j P_ME1_RET                     # return

                                P_ME1_FOR_LOOP_COLUNA_YN_CONTINUE:
                                addi s6, s6, 1
                                j P_ME1_FOR_LOOP_COLUNA_YN
                        P_ME1_FOR_LOOP_COLUNA_YN_FIM:

                        addi s5, s5, -1                   # linha--
                        j P_ME1_FOR_LOOP_LINHA_YN

P_ME1_EIXO_Y_APLICAR:
        # entidade.y = entidade.y + entidade.velocidade_y
        lw t0, entidade.Y_Q12(s0)
        lw t1, entidade.VELOCIDADE_Y_Q12(s0)
        add t0, t0, t1
        sw t0, entidade.Y_Q12(s0)

P_ME1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        lw s4, 20(sp)
        lw s5, 24(sp)
        lw s6, 28(sp)
        addi sp, sp, 32

        ret # :)

