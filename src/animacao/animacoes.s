# Animacoes
#
# Contem as animacoes do jogo escritas na linguagem de scripting
# de animacoes.


JOGADOR.ANIMACAO.ANDAR: .word
        OP_SETSPRITE sprite_bruxa_andando
        OP_SETFRAME 0
        OP_WAIT 4
        OP_SETFRAME 1
        OP_WAIT 4
        OP_SETFRAME 2
        OP_WAIT 4
        OP_SETFRAME 3
        OP_WAIT 4
        OP_SETFRAME 2
        OP_WAIT 4
        OP_JUMP -8              # frame 0 -> 1 -> 2 -> 3 -> 2 -> 1 -> 2 -> 3 -> 2 -> 1 ->...
        # sem OP_END necessario pois a animacao loopa

JOGADOR.ANIMACAO.IDLE: .word
        OP_SETSPRITE sprite_bruxa
        OP_SETFRAME 0
        OP_END


JOGADOR.ANIMACAO.PULAR: .word
        OP_SETSPRITE sprite_bruxa_pulo
        OP_SETFRAME 0
        OP_WAIT 2
        OP_SETFRAME 1
        OP_WAIT 2
        OP_SETFRAME 2
        OP_WAIT 2
        OP_SETFRAME 3
        OP_WAIT 3
        OP_SETFRAME 4
        OP_WAIT 3
        OP_SETFRAME 5
        OP_WAIT 5
        OP_SETFRAME 6
        OP_WAIT 5
        OP_SETFRAME 7
        OP_WAIT 5
        OP_SETFRAME 8
        OP_WAIT 6
        OP_SETFRAME 9
        OP_WAIT 15
        OP_SETFRAME 8
        OP_WAIT 5
        OP_SETANIM sprite_bruxa_queda

JOGADOR.ANIMACAO.CAIR: .word
        OP_SETSPRITE sprite_bruxa_queda
        OP_SETFRAME 0
        OP_END

JOGADOR.ANIMACAO.VASSOURA: .word
        OP_SETSPRITE sprite_bruxa_vassoura
        OP_SETFRAME 0
        OP_END

JOGADOR.ANIMACAO.ATIRAR:
        OP_SETSPRITE sprite_bruxa_feitico
        OP_SETFRAME 0
        OP_WAIT 1
        OP_SETFRAME 1
        OP_WAIT 1
        OP_SETFRAME 2
        OP_WAIT 1
        OP_SETFRAME 3
        OP_WAIT 1
        OP_SETFRAME 4
        OP_WAIT 1
        OP_SETFRAME 5
        OP_WAIT 1
        OP_SETFRAME 6
        OP_WAIT 3
        OP_SETFRAME 7
        OP_WAIT 1
        OP_SETFRAME 8
        OP_WAIT 1
        OP_SETFRAME 9
        OP_WAIT 1
        OP_SETFRAME 10
        OP_WAIT 1
        OP_SETFRAME 11
        OP_WAIT 1
        OP_SETANIM JOGADOR.ANIMACAO.IDLE

SCHNOZ.ANIMACAO.ANDAR:  .word
        OP_SETSPRITE sprite_schnoz
        OP_SETFRAME 0
        OP_WAIT 4
        OP_SETFRAME 1
        OP_WAIT 4
        OP_SETFRAME 0
        OP_WAIT 4
        OP_SETFRAME 2
        OP_WAIT 4
        OP_JUMP -8 # assim como a movimentacao do jogador, a animacao loopa na seguinte ordem: 0 -> 1 -> 0 -> 2 -> 0 -> 1 ...

SCHNOZ.ANIMACAO.SPAWN:  .word
        OP_SETSPRITE sprite_spawn
        OP_SETFRAME 0
        OP_END

JUMPER.ANIMACAO.PULO:   .word
        OP_SETSPRITE sprite_dragao
        OP_SETFRAME 0
        OP_WAIT 8
        OP_SETFRAME 1
        OP_WAIT 8
        OP_JUMP -4 

JUMPER.ANIMACAO.SPAWN:  .word
        OP_SETSPRITE sprite_spawn
        OP_SETFRAME 0
        OP_END

