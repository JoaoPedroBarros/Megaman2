##############################################################
# PROC_DESENHAR		 				     #
# troca o frame ativo, mostrando tudo que foi desenhado      #
# desde a ultima troca.					     #
# 							     #
# ARGUMENTOS:						     #
#	(nenhum)					     #
# RETORNOS:                                                  #
#       (nenhum)                                             #
##############################################################

.text

PROC_DESENHAR:		lw t1, FRAME_BUFFER_PTR		# carrega o endereco do frame buffer
			lw t2, FRAME_BUFFER_FIM_PTR	# endereco final 
			li t3, FRAME_0			# 0xFF000000 - endereco inicial
	
			li t0, 0xFF200604		# word de trocar buffer
			la t4, FRAME_ATUAL
			lw t5, (t4)
			bnez t5, P_D1_TROCAR_P_FRAME_0

P_D1_TROCAR_P_FRAME_1:
			li t1, 1
			sw t1,0(t0)
			sw t1,0(t4)
			li t0, FRAME_0
			sw t0, FRAME_BUFFER_PTR, t1
			li t0, FRAME_0_FIM
			sw t0, FRAME_BUFFER_FIM_PTR, t1
			ret

P_D1_TROCAR_P_FRAME_0:
			sw zero,0(t0)
			sw zero,0(t4)
			li t0, FRAME_1
			sw t0, FRAME_BUFFER_PTR, t1
			li t0, FRAME_1_FIM
			sw t0, FRAME_BUFFER_FIM_PTR, t1
			ret
	
