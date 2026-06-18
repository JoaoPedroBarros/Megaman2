# Definicoes dialogo
# 
# Mantem coisas sobre o dialogo a serem usadas pelas funcoes relevantes


.data

struct_dialogo_estatica: .word 0 0 0
        .eqv struct_dialogo_estatica.DIALOGO_ATUAL              0       # ponteiro ao dialogo atual
        .eqv struct_dialogo_estatica.ULTIMO_DIALOGO_DA_FILA     4
        .eqv struct_dialogo_estatica.EM_PROGRESSO               8       # se existe um dialogo sendo mostrado

.eqv TAMANHO_DIALOGO_BUFFER 256                 # !!! tamanho maximo de um dialogo em caracteres
dialogo_buffer: .byte 0:TAMANHO_DIALOGO_BUFFER   # buffer aonde o dialogo atual vai ter seu
                                                # texto copiado

struct_dialogo:
        .eqv dialogo.STRING                     0
        .eqv dialogo.NOME_FALANTE               4
        .eqv dialogo.TAMANHO                    8
        .eqv dialogo.CONTADOR_FRAMES            12
        .eqv dialogo.FRAME_PROXIMO_CARACTERE    16
        .eqv dialogo.CONTADOR_CARACTERES        20
        .eqv dialogo.DELAY_ENTRE_CARACTERES     24
        .eqv dialogo.PROXIMO_DIALOGO            28      # ponteiro para proximo dialogo, se houver
        # adicione atributos conforme necessario

        .eqv dialogo.TAMANHO_STRUCT             32
