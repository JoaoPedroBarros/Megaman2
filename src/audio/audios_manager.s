# PROC_AUDIOS_MANAGER
#
# Administra os canais de audio do programa, tocando-os e atualizando status.
#
# (sem argumentos, retornos)

PROC_AUDIOS_MANAGER:        
        li t0, 0
        li t1, canais_de_audio.QUANTIDADE
        la t2, canais_de_audio
        li t3, struct_canal_de_audio.TAMANHO
P_AM1_LOOP: # for (int i = 0; i < canais.size; i++) atualizar(canais[i]);
        bge t0, t1, P_AM1_RET

P_AM1_ATUALIZAR:
        lbu t4, struct_canal_de_audio.ATIVO(t2)
        beqz t4, P_AM1_LOOP_CONT     # nada a se fazer se o canal estah inativo

        # carrega a proxima nota a se tocar
        lw t4, struct_canal_de_audio.PROXIMA_NOTA(t2)
        lhu t5, struct_nota.DURACAO(t4)
        beqz t5, P_AM1_FIM_DA_TRACK

        lw t5, struct_canal_de_audio.TIMESTAMP(t2)
	csrr t6, time
	sub t5, t6, t5			# milisegundos desde o comeco do canal comecar a tocar
        

P_AM1_TOCAR_NOTA:
        lw t6, struct_nota.MS_COMECO(t4)
        bgt t6, t5, P_AM1_LOOP_CONT     # nao toca se nao eh a hora

        lb a0, struct_nota.PITCH(t4)
	lhu a1, struct_nota.DURACAO(t4)
	mv a2, zero                     # unico instrumento

        lbu t6, struct_canal_de_audio.VOLUME(t2)
	lbu a3, struct_nota.VOLUME(t4)
        mul a3, a3, t6  # volume = nota.volume * canal.volume
	li a7, 31
        
	ecall   # toca a nota!!!!

P_AM1_CHECAR_PROXIMA_NOTA:
        addi t4, t4, struct_nota.TAMANHO
        sw t4, struct_canal_de_audio.PROXIMA_NOTA(t2)   # salva a proxima nota
        lhu t6, struct_nota.DURACAO(t4)
        bgtz t6, P_AM1_TOCAR_NOTA                       # ve se tem que tocar a proxima nota

P_AM1_FIM_DA_TRACK:
        lb t6, struct_canal_de_audio.LOOP(t2)
        beqz t6, P_AM1_DESATIVAR_CANAL

P_AM1_LOOPAR_TRACK:
        lw t6, struct_canal_de_audio.ENDERECO_FONTE(t2)
        sw t6, struct_canal_de_audio.PROXIMA_NOTA(t2)
        csrr t6, time
        li t5, struct_nota.TAMANHO
        sub t4, t4, t5
        lhu t5, struct_nota.DURACAO(t4) # pega a duracao da nota ANTERIOR
        add t6, t6, t5
        sw t6, struct_canal_de_audio.TIMESTAMP(t2)      # salva o comeco da track como no futuro para melhorar as chances de um loop clean
        j P_AM1_LOOP_CONT

P_AM1_DESATIVAR_CANAL:
        sb zero, struct_canal_de_audio.ATIVO(t2)
        j P_AM1_RET

P_AM1_LOOP_CONT:
        addi t0, t0, 1
        add t2, t2, t3
        j P_AM1_LOOP

P_AM1_RET:
        ret