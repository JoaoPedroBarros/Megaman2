# Definicoes de audio

.data
struct_canal_de_audio:
        .eqv struct_canal_de_audio.ATIVO                0       # se a track estah ativa ou nao
        .eqv struct_canal_de_audio.LOOP                 1       # se a track estah com loop ligado
        .eqv struct_canal_de_audio.VOLUME               2       # volume da track (0-127)
        .eqv struct_canal_de_audio.ENDERECO_FONTE       4       # label fonte do audio que estah tocando
        .eqv struct_canal_de_audio.PROXIMA_NOTA         8       # label da proxima nota que deve tocar
        .eqv struct_canal_de_audio.TIMESTAMP            12      # timestamp de quando a track comecou a tocar

        .eqv struct_canal_de_audio.TAMANHO              16      

# notas individuais nos arquivos
struct_nota:
        .eqv struct_nota.PITCH                          0       # byte: nota sendo tocada
        .eqv struct_nota.VOLUME                         1       # byte: volume da nota
        .eqv struct_nota.DURACAO                        2       # half: duracao da nota
        .eqv struct_nota.MS_COMECO                      4       # word: quantos ms deve tocar depois do comeco da track

        .eqv struct_nota.TAMANHO                        8       


# oito canais. o primeiro estah reservado para a musica.
.eqv canais_de_audio.QUANTIDADE 8
canais_de_audio:
        .word 0 0 0 0   
        .word 0 0 0 0    
        .word 0 0 0 0   
        .word 0 0 0 0   
        .word 0 0 0 0
        .word 0 0 0 0
        .word 0 0 0 0
        .word 0 0 0 0