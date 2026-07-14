# Definicoes sobre o sistema de eventos e
# espaços de memoria utilizados

.data

struct_evento:
        .eqv struct_evento.ATIVO        0       # se o slot de evento estah disponivel ou nao
        .eqv struct_evento.FRAME_EXEC   8
        .eqv struct_evento.PROC         4
        .eqv struct_evento.DADOS        12

        .eqv struct_evento.TAMANHO_STRUCT 16

.eqv ESPACO_ARRAY_EVENTOS 256   # 64 eventos
array_eventos: .byte 0:ESPACO_ARRAY_EVENTOS      # array de ponteiros!
qtd_de_eventos: .word 0                         # contador de eventos