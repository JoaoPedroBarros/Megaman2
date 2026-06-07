.data 
MACRO_DATA_QUEBRA_DE_LINHA: .string "\n"

.text
.macro safe_sleep(%seg)
	.text
	addi sp, sp, -8
	sw a0, (sp)
	sw a7, 4(sp)

	li a0, %seg
	li a7, 32
	ecall

	lw a0, (sp)
	lw a7, 4(sp)
	addi sp, sp, 8
.end_macro

.macro quebra_de_linha
	.text
	li a7, 4
	la a0, MACRO_DATA_QUEBRA_DE_LINHA
	ecall
.end_macro

.macro safe_quebra_de_linha
	.text
	addi sp, sp, -8
	sw a0, (sp)
	sw a7, 4(sp)

	quebra_de_linha

	lw a0, (sp)
	lw a7, 4(sp)
	addi sp, sp, 8
.end_macro

.macro safe_print_int(%int)
	.text
	addi sp, sp, -8
	sw a0, (sp)
	sw a7, 4(sp)

	print_int(%int)

	lw a0, (sp)
	lw a7, 4(sp)
	addi sp, sp, 8
.end_macro

.macro safe_print_int_ln(%int)
	.text
	addi sp, sp, -8
	sw a0, (sp)
	sw a7, 4(sp)

	mv a0, %int
	li a7, 36
	ecall

	quebra_de_linha

	lw a0, (sp)
	lw a7, 4(sp)
	addi sp, sp, 8
.end_macro

.macro imprimir_retangulo(%cor, %X1, %Y1, %X2, %Y2)
	li a0, %cor
	li a1, %X1
	li a2, %Y1
	li a3, %X2
	li a4, %Y2
	jal PROC_IMPRIMIR_RETANGULO
.end_macro

.macro imprimir_outline(%cor, %X1, %Y1, %X2, %Y2, %grossura)
	li a0, %cor
	li a1, %X1
	li a2, %Y1
	li a3, %X2
	li a4, %Y2
        li a5, %grossura
	jal PROC_IMPRIMIR_OUTLINE
.end_macro
