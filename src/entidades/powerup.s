# ENTIDADE_POWERUP
#
# Entidades que sao dropadas geralmente quando o jogador mata um inimigo.
# Restauram uma ou mais stats do jogador

.data 
ENTIDADE_POWERUP.tipos:
        .eqv TIPO_NULO          0 # nenhum tipo definido
        .eqv TIPO_VIDA          1 # restaura vida
        .eqv TIPO_MUNICAO       2 # restaura municao


# TO-DO: colocar sprites corretos qnd o Eduardo as criar
ENTIDADE_POWERUP.sprites:
        .word sprite_feitico6           # sprite do tipo 1 (TIPO_VIDA)
        .word sprite_feitico_vento      # sprite do tipo 2 (TIPO_MUNICAO)

ENTIDADE_POWERUP.struct:
        .eqv ENTIDADE_POWERUP.TIPO              0       # tipo de powerup (ver tabela acima)
        .eqv ENTIDADE_POWERUP.SPRITE            4       # sprite de textura
        .eqv ENTIDADE_POWERUP.VALOR             8       # valor a ser adicionado/restaurado ah stat relevante
        .eqv ENTIDADE_POWERUP.TEMPO_DE_VIDA     12      # quantos frames ateh o powerup despawnar

.eqv ENTIDADE_POWERUP.TAMANHO_STRUCT 16

.eqv ENTIDADE_POWERUP.TEMPO_DE_PISQUE           50      # a partir de quanto tempo de vida a entidade deve comecar a piscar
.eqv ENTIDADE_POWERUP.TEMPO_PADRAO              400     # tempo de vida padrao de um powerup


.text
# argumentos: a0 - struct basica da entidade
#             a1 - X int
#             a2 - Y int
# retorno:    (nenhum)
ENTIDADE_POWERUP.NOVO:
        slli a1, a1, 12
        slli a2, a2, 12
        sw a1, entidade.X_Q12(a0)
        sw a2, entidade.Y_Q12(a0)

        definir_hitbox(a0, 0, 0, 16, 16)    # temporario! vai depender no sprite final

        sw zero, entidade.COLIDIVEL(a0)     # nao eh colidivel por enquanto, soh quando o tipo for definido
        sw zero, entidade.HOSTIL(a0)

        lw t1, entidade.STRUCT_ESPECIFICA(a0)
        li t0, TIPO_NULO
        sw t0, ENTIDADE_POWERUP.TIPO(t1)    # salva sem tipo por enquanto
        ret


# METODO PARA DEFINIR TIPO DO POWERUP
# Argumentos:   a0 - entidade em si
#               a1 - tipo de powerup (ver tabela no inicio do arquivo)
#               a2 - valor do powerup (e.g. 20 de vida, 10 de municao, etc.)
#               a3 - por quantos frames o powerup deve existir
#
# (sem retornos)
ENTIDADE_POWERUP.INIT:
        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        sw a1, ENTIDADE_POWERUP.TIPO(t0)        # salva o tipo em powerup.tipo

        addi a1, a1, -1
        slli a1, a1, 2
        la t1, ENTIDADE_POWERUP.sprites
        add t1, t1, a1
        lw t1, (t1)                             # carrega sprites[tipo-1] da tabela
        sw t1, ENTIDADE_POWERUP.SPRITE(t0)      # salva sprites[tipo-1] em powerup.sprite

        sw a2, ENTIDADE_POWERUP.VALOR(t0)       # salva valor em powerup.valor

        sw a3, ENTIDADE_POWERUP.TEMPO_DE_VIDA(t0) # salva tempo_de_vida em powerup.tempo_de_vida

        li t0, 1
        sw t0, entidade.COLIDIVEL(a0)

        ret

# argumento: a0 - struct basica da entidade
# retorno:   a0 - se a entidade estah viva (1) ou nao (0)
ENTIDADE_POWERUP.PROC:
        addi sp, sp, -4
        sw ra, (sp)

        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        lw t1, ENTIDADE_POWERUP.TEMPO_DE_VIDA(t0)
        addi t1, t1, -1 # powerup.tempo_de_vida--;
        sw t1, ENTIDADE_POWERUP.TEMPO_DE_VIDA(t0)
        blez t1, ENTIDADE_POWERUP.PROC._MORRE # se deleta se tempo_de_vida <= 0

        lw t0, entidade.VELOCIDADE_Y_Q12(a0)
        li t1, GRAVIDADE_PADRAO
        add t0, t0, t1
        sw t0, entidade.VELOCIDADE_Y_Q12(a0)

        jal PROC_MOVER_ENTIDADE

ENTIDADE_POWERUP.PROC._VIVE:
        li a0, 1
        j ENTIDADE_POWERUP.PROC._RET

ENTIDADE_POWERUP.PROC._MORRE:
        li a0, 0

ENTIDADE_POWERUP.PROC._RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret                     

# argumento: a0 - struct basica da entidade
# (sem retornos)
ENTIDADE_POWERUP.DRAW:  
        addi sp, sp, -4
        sw ra, (sp)

        lw t0, entidade.STRUCT_ESPECIFICA(a0)

        lw t1, ENTIDADE_POWERUP.TEMPO_DE_VIDA(t0)
        li t2, ENTIDADE_POWERUP.TEMPO_DE_PISQUE

        bgt t1, t2, ENTIDADE_POWERUP.DRAW._CONT
        # se tempo_de_vida < tempo_de_pisque... pisca

        # apenas imprime ele quando tempo_de_vida mod 4 == 2 | 3.
        andi t1, t1, 0x02   
        beqz t1, ENTIDADE_POWERUP.DRAW._RET

ENTIDADE_POWERUP.DRAW._CONT:

        # calcula posicao absoluta para imprimir
        lw a1, entidade.X_Q12(a0)
        lw a2, entidade.Y_Q12(a0)
        srai a1, a1, 12
        srai a2, a2, 12
        la t3, camera
        lw t1, camera_x(t3)
        lw t2, camera_y(t3)
        sub a1, a1, t1          
        sub a2, a2, t2        

        # carrega a sprite a ser impressa
        lw a0, ENTIDADE_POWERUP.SPRITE(t0)
                
        # carrega as dimensoes da textura e passa o endereco do primeiro byte de cor
        lw a3, (a0)
        lw a4, 4(a0)
        addi a0, a0, 8 
        jal PROC_IMPRIMIR_TEXTURA

ENTIDADE_POWERUP.DRAW._RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret
        

# argumentos:   a0 - entidade desse tipo colidindo      (self)
#               a1 - outra entidade com quem colidimos  (other)
#
# retorno: a0 - se a entidade estah viva (1) ou nao (0)
ENTIDADE_POWERUP.COLISAO:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)

        lw t0, entidade.TIPO(a1)
        li t1, ENTIDADE_JOGADOR
        bne t0, t1, ENTIDADE_POWERUP.COLISAO._VIVE       # ignora entidades que nao forem o jogador

        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        lw s0, entidade.STRUCT_ESPECIFICA(a1)

        lw t2, ENTIDADE_POWERUP.TIPO(t0)
        lw t3, ENTIDADE_POWERUP.VALOR(t0)

        li t0, TIPO_VIDA
        beq t0, t2, ENTIDADE_POWERUP.COLISAO._ADICIONAR_VIDA
        li t0, TIPO_MUNICAO
        beq t0, t2, ENTIDADE_POWERUP.COLISAO._ADICIONAR_MUNICAO
        j ENTIDADE_POWERUP.COLISAO._MORRE                # se o tipo for invalido, apenas se deleta

ENTIDADE_POWERUP.COLISAO._ADICIONAR_VIDA:
        lb t0, JOGADOR.VIDA(s0)
        lb a0, JOGADOR.VIDA_MAXIMA(s0)
        add a1, t0, t3
        jal PROC_MIN 
        sb a0, JOGADOR.VIDA(s0)       # jogador.vida = min(jogador.vida_maxima, jogador.vida+valor)
#                                       importante manter esse min, pois ele garante que a vida do jogador
#                                       nunca vai passar da vida maxima

        j ENTIDADE_POWERUP.COLISAO._MORRE # remove o powerup, agora que ele foi consumido

ENTIDADE_POWERUP.COLISAO._ADICIONAR_MUNICAO:
        lb t0, JOGADOR.MUNICAO_PROJETIL_VENTO(s0)
        lb a0, JOGADOR.MUNICAO_MAXIMA(s0)
        add a1, t0, t3
        jal PROC_MIN
        sb a0, JOGADOR.MUNICAO_PROJETIL_VENTO(s0) #     jogador.municao = min(jogador.municao, jogador.municao+valor)
#                                                       importante manter esse min, pois ele garante que a municao do 
#                                                       jogador nunca vai passar da municao maxima

        # remove o powerup, agora que ele foi consumido

ENTIDADE_POWERUP.COLISAO._MORRE:
        li a0, 0        # retorna que morreu
        j ENTIDADE_POWERUP.COLISAO._RET

ENTIDADE_POWERUP.COLISAO._VIVE:
        li a0, 1        # retorna que nao morreu

ENTIDADE_POWERUP.COLISAO._RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret
