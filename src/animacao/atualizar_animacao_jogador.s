# PROC_ATUALIZAR_ANIMACAO_JOGADOR
#
# Administra transicao da maquina de estados de animacao do jogador
#
# argumentos: a0 - struct basica do jogador

PROC_ATUALIZAR_ANIMACAO_JOGADOR:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)

        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        lw s0, JOGADOR.ANIMACAO_CONTROLLER(t0)
        lb t1, JOGADOR.FLAG_VASSOURA(t0)
        bltz t1, P_AA1_SEM_VASSOURA

P_AA1_VASSOURA:

        # muda para a animacao de vassoura
        mv a0, s0
        la a1, JOGADOR.ANIMACAO.VASSOURA
        jal PROC_DEFINIR_ANIMACAO
        j P_AA1_FIM

P_AA1_SEM_VASSOURA:
        lw t2, struct_animacao_controller.ANIMACAO(s0)
        la t1, JOGADOR.ANIMACAO.CAIR
        beq t1, t2, P_AA1_SEM_VASSOURA_CONT

        lw t0, TECLA_PRESSIONADA
        li t1, 'W'
        beq t0, t1, P_AA1_PULAR
        li t1, 'w'
        beq t0, t1, P_AA1_PULAR

P_AA1_SEM_VASSOURA_CONT:
        lw t0, entidade.NO_CHAO(a0)
        bnez t0, P_AA1_NO_CHAO

        la t1, JOGADOR.ANIMACAO.PULAR
        beq t2, t1, P_AA1_FIM
        la t1, JOGADOR.ANIMACAO.CAIR
        beq t2, t1, P_AA1_FIM

        lw t0, entidade.VELOCIDADE_Y_Q12(a0)
        li t1, 12288
        blt t0, t1, P_AA1_IDLE

P_AA1_QUEDA:
        # muda para a animacao de queda
        mv a0, s0
        la a1, JOGADOR.ANIMACAO.CAIR
        jal PROC_DEFINIR_ANIMACAO
        j P_AA1_FIM

P_AA1_PULAR:
        # muda para a animacao de pulo
        mv a0, s0
        la a1, JOGADOR.ANIMACAO.PULAR
        jal PROC_DEFINIR_ANIMACAO
        j P_AA1_FIM

P_AA1_NO_CHAO:

        lw t0, TECLA_PRESSIONADA
        li t1, 'a'
        beq t1, t0, P_AA1_ANDAR
        li t1, 'A'
        beq t1, t0, P_AA1_ANDAR
        li t1, 'd'
        beq t1, t0, P_AA1_ANDAR
        li t1, 'D'
        beq t1, t0, P_AA1_ANDAR

        li t1, '\n'
        sub t1, t0, t1
        snez t2, t1
        li t1, 'c'
        sub t1, t0, t1
        snez t1, t1
        or t2, t2, t1
        li t1, 'C'
        sub t1, t0, t1
        snez t1, t1
        or t2, t2, t1
        beqz t2, P_AA1_NO_CHAO_CONT # se nenhuma dessas teclas pressionadas, nao vamos atirar agr

        lw t0, entidade.STRUCT_ESPECIFICA(a0)
        lb t0, JOGADOR.COOLDOWN_PROJETIL(t0)
        blez t0, P_AA1_ATIRAR
        
P_AA1_NO_CHAO_CONT:
        lw t0, entidade.VELOCIDADE_X_Q12(a0)
        li t1, 512
        bge t0, t1, P_AA1_ANDAR
        neg t1, t1
        blt t0, t1, P_AA1_ANDAR

        lw t0, struct_animacao_controller.ANIMACAO(s0)
        la t1, JOGADOR.ANIMACAO.ATIRAR
        beq t0, t1, P_AA1_FIM

P_AA1_IDLE:
        # muda para a animacao de idle
        mv a0, s0
        la a1, JOGADOR.ANIMACAO.IDLE
        jal PROC_DEFINIR_ANIMACAO
        j P_AA1_FIM

P_AA1_ATIRAR:
        mv a0, s0
        la a1, JOGADOR.ANIMACAO.ATIRAR
        jal PROC_REINICIAR_ANIMACAO
        j P_AA1_FIM

P_AA1_ANDAR:
        # muda para a animacao de andar
        mv a0, s0
        la a1, JOGADOR.ANIMACAO.ANDAR
        jal PROC_DEFINIR_ANIMACAO

P_AA1_FIM:
        mv a0, s0
        jal PROC_EXECUTAR_ANIMACAO

P_AA1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret

#. update_animation_player(player)
#. if (player.flag_vassoura) {
#.      set_animation(vassoura);
#.      return;
#. } if (!player.on_ground) {
#.      if (player.animation == queda ||
#.          player.animation == pulo) return;
#.      if (key_pressed('W')){
#.              set_animation(pulo);
#.              return;
#.      }
#.      if (player.velocity_y > 3) {
#.              set_animation(queda);
#.              return;
#.      }
#. }
#. if ((key_pressed('Enter') || key_pressed('C'))&& !player.projectile_cooldown) {
#.      reset_animation(feitico);
#.      return;
#. }
#. if (key_pressed('A') || key_pressed('D') || abs(player.velocity_x) > 0.125) {
#.      set_animation(caminhada);
#.      return;
#. }
#.
#. if (player.animation != feitico) set_animation(idle);
#. return;
