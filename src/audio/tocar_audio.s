# PROC_TOCAR_AUDIO
#
# Coloca um audio para tocar.
#
# Argumentos:
# a0 - endereco do audio
# a1 - canal de audio para tocar (0: qualquer um; n>0: canal n)
# a2 - caso um canal seja fornecido, se o canal deve ser sobrescrito (1) ou nao (0), se ele estiver ativo
# a3 - se o audio deve ser tocado em loop (1) ou nao (0)
# a4 - volume do audio (de 0 a 127)
#
# Retorno:
# a0 - track que o audio comecou a tocar (de 1 a n) ou falha (0)

PROC_TOCAR_AUDIO:
        bgtz a1, P_TA1_CANAL_ESPECIFICO

P_TA1_PROCURAR:
# procura um ativo
        li a1, 0
        li t2, canais_de_audio.QUANTIDADE
        li t3, struct_canal_de_audio.TAMANHO
        la t0, canais_de_audio
P_TA1_PROCURAR_LOOP:
        lbu t4, struct_canal_de_audio.ATIVO(t0)
        beqz t4, P_TA1_COLOCAR_PARA_TOCAR # se achar o canal, comeca a tocar
        add t0, t0, t3
        addi a1, a1, 1
        blt a1, t2, P_TA1_PROCURAR_LOOP # continua procurando se ainda hah canais para cacar
        j P_TA1_FALHA                   # falha se nao encontrarmos

P_TA1_CANAL_ESPECIFICO:
        li t0, canais_de_audio.QUANTIDADE
        bgt a1, t0, P_TA1_FALHA # se n > quantidade, o canal nao existe. retorna falha

        addi a1, a1, -1         # converte para index de canal (0 a n)
        li t0, struct_canal_de_audio.TAMANHO
        mul t0, t0, a1
        la t1, canais_de_audio
        add t0, t1, t0  # pega o endereco do canal 

        lbu t1, struct_canal_de_audio.ATIVO(t0)
        seqz t2, a2
        and t2, t2, t1   
        bnez t2, P_TA1_FALHA    # se (!sobrescrever && ativo), nao podemos tocar aqui

P_TA1_COLOCAR_PARA_TOCAR:

        # salva todas as informacoes na track encontrada/fornecida
        li t1, 1
        sb t1, struct_canal_de_audio.ATIVO(t0)
        sb a3, struct_canal_de_audio.LOOP(t0)
        sb a4, struct_canal_de_audio.VOLUME(t0)
        sw a0, struct_canal_de_audio.ENDERECO_FONTE(t0)
        sw a0, struct_canal_de_audio.PROXIMA_NOTA(t0)
        csrr t1, time
        sw t1, struct_canal_de_audio.TIMESTAMP(t0)      # comeca a tocar AGORA

P_TA1_SUCESSO:
        addi a0, a1, 1  # retorna o numero do canal
        ret
        
P_TA1_FALHA:
        li a0, 0
        ret
