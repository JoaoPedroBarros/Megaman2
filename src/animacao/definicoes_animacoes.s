# Definicoes de animacoes
#
# Contem tudo relacionado ahs animacoes das entidades
# e a linguagem de scripting de animacoes



struct_animacao_controller:
        .eqv struct_animacao_controller.PC              0       # instrucao de animacao atual sendo executada
        .eqv struct_animacao_controller.ANIMACAO        4       # label da animacao atual
        .eqv struct_animacao_controller.SPRITE          8       # sprite de animacao atual
        .eqv struct_animacao_controller.PALETA          12      # paleta do sprite atual (se aplicavel)
        .eqv struct_animacao_controller.FRAME           16      # frame de animacao atual
        .eqv struct_animacao_controller.WAIT_TIMER      20      # timer de espera ateh executar a proxima instrucao

        .eqv struct_animacao_controller.TAMANHO         24      


# instruction set
        .eqv OP_WAIT            1       # OP_WAIT, N: espera N frames ateh executar a proxima instrucao (n: unsigned int)
        .eqv OP_SETSPRITE       2       # OP_SETSPRITE, label: muda o sprite de animacao
        .eqv OP_SETPALETA       3       # OP_SETPALETA, label: muda a paleta de animacao
        .eqv OP_SETFRAME        4       # OP_SETFRAME, n: muda o frame de animacao
        .eqv OP_SETANIM         5       # OP_SETANIM, label: transiciona para outra animacao
        .eqv OP_JUMP            6       # OP_JUMP, n: adiciona n instrucoes ao PC da animacao (n: signed int)
        .eqv OP_END             7       # OP_END, 0: termina a animacao atual


        .eqv OP_INVALIDA        0       # instrucao invalida

        # EXEMPLOS podem ser encontrados em animacoes.s

# posicao 
        .eqv instr_animacao.OPCODE    0       # o opcode eh a primeira word de uma linha (e.g. OP_SETSPRITE)
        .eqv instr_animacao.OPERANDO  4       # o operando eh a segunda word de uma linha (e.g. sprite_1)