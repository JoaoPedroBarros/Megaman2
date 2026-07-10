# Tabelas de drop
#
# Tabelas contendo os powerups que podem ser dropados 
# pelos inimigos e suas chances.

.data

# cada tabela funciona da seguinte maneira:
#
# o codigo de drop gera um numero aleatorio entre 0 e 99
# depois, ele seleciona uma das entradas da tabela de acordo com o PESO (ex., peso 50 = 50% de chance)
# se o tipo da entrada selecionada for TIPO_NULO, ele nao faz nada
# senao, ele spawna um powerup de acordo com o TIPO e com o VALOR

# index dentro de cada entrada (linha) da tabela
.eqv DROP.PESO          0
.eqv DROP.TIPO          1
.eqv DROP.VALOR         2

# tamanho de cada entrada
.eqv DROP.TAMANHO       3

# marcador de fim de tabela
.eqv DROP_FIM           0

# por exemplo:
DROP_TABLE_EXEMPLO: 
        .byte 75, TIPO_NULO, 0          # 75% de chance de nenhum drop
        .byte 10, TIPO_VIDA, 3          # 10% de chance de powerup de +3 de vida
        .byte 10, TIPO_MUNICAO, 5       # 10% de chance de powerup de +5 de municao
        .byte 5, TIPO_VIDA, 6           # 5% de chance de powerup de +6 de vida
        .byte DROP_FIM                  # fim

# Note que a ORDEM das linhas nao importa, apesar de que eh mais 
# performatico deixar as linhas com maior peso mais em cima. 
#
# Outra coisa importante: O peso das linhas deve somar para 100
# para o funcionamento correto do drop.


        

# valores exemplo. devem ser balanceados posteriormente
DROP_TABLE_SCHNOZ:
        .byte 70, TIPO_NULO, 0
        .byte 20, TIPO_VIDA, 3
        .byte 10, TIPO_MUNICAO, 5
        .byte DROP_FIM

DROP_TABLE_JUMPER:
        .byte 50, TIPO_NULO, 0
        .byte 30, TIPO_MUNICAO, 5
        .byte 20, TIPO_VIDA, 3
        .byte DROP_FIM

.text