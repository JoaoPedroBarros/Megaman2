# EXEMPLO de entidade no modelo


# Como representar uma struct? 
# Pegue, por exemplo, essa struct em pseudo c:
#
# struct EXEMPLO{
#       word atributo_1; 
#       half atributo_2;
#       byte atributo_3;
#       byte atributo_4;
# };
#
# Essa struct seria transformada conforme a struct abaixo!

EXEMPLO.struct:
        .eqv EXEMPLO.ATRIBUTO_1 0 
        .eqv EXEMPLO.ATRIBUTO_2 4  
        .eqv EXEMPLO.ATRIBUTO_3 6
        .eqv EXEMPLO.ATRIBUTO_4 7
        .eqv EXEMPLO.TAMANHO_STRUCT 8

# O numero do lado de cada representa a *posicao*, a partir do endereco
# da struct, de onde cada atributo pode ser encontrada.
# o atributo 1 se localiza no comeco.
# o atributo 2 se localiza 1 word depois.
# o atributo 3 se localiza 1 word + 1 half depois.
# o atributo 4 se localiza 1 word + 1 half + 1 byte depois.
#
# assim, quando for acessar um atributo, eh bem simples!
# se o endereco da struct estiver em t0, por exemplo,
# para acessar um atributo X, posso fazer lw t1, EXEMPLO.ATRIBUTO_X(t0)
# e ter o valor guardado la (ou lixo, se a proc de criacao nao tiver
# inicializado os valores corretamente).



# Argumentos (obrigatoriamente):
# a0 - struct basica
# a1 - X
# a2 - Y
# Sem retornos!
EXEMPLO.NOVO:
        sw a1, entidade.X(a0)
        sw a2, entidade.Y(a0)
        lw t0, entidade.STRUCT_ESPECIFICA(a0)   # pega a struct com dados especificos a esse tipo de entidade
        
        # exemplo de inicializacao de atributos
        csrr t1, time
        sw t1, ATRIBUTO_1(t0)   # e.g. um cooldown

        li t1, 4
        sh t0, ATRIBUTO_2(t0)   # e.g. um marcador de estado

        sb zero, ATRIBUTO_3(t0) # e.g. um booleano de "apareceu na tela"
        sb zero, ATRIBUTO_4(t0) # e.g. uma direcao de movimento

        # nao retorna nada! apenas deixa a entidade com valores iniciados.
        ret     

# Argumentos (obrigatoriamente)
# a0 - struct basica
# Sem retornos!
EXEMPLO.PROC:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)

        mv s0, a0       # guarda o argumento de struct basica

#       la t0, textura -- carrega uma textura
        addi a0, t0, 8          # passa a textura, pulando as 2 words de dimensao
        lw a1, entidade.X(s0)
        lw a2, entidade.Y(s0)
        lw a3, (t0)             # largura
        lw a4, 4(t0)            # altura
        jal PROC_IMPRIMIR_TEXTURA

        # incrementa o atributo 2 na struct da entidade
        lw t0, entidade.STRUCT_ESPECIFICA(s0)
        lw t1, EXEMPLO.ATRIBUTO_2(t0)
        addi t1, t1, 1
        sw t1, EXEMPLO.ATRIBUTO_2(t0)

        # + branches, condicionais, checagens, outros procs, etc.
        # inclusive a criacao de outras entidades!

        # spawna outra entidade exemplo
        li a0, ENTIDADE_EXEMPLO 

        # na posicao atual X e Y da entidade jah existente
        lw a1, entidade.X(s0)   
        lw a2, entidade.Y(s0)

        # ...adicionando, no Y, o atributo 2
        lw t0, entidade.STRUCT_ESPECIFICA(s0)
        lw t1, EXEMPLO.ATRIBUTO_2(t0)
        addi a2, a2, t1

        # cria a entidade
        jal PROC_ADICIONAR_ENTIDADE

        # CUIDADO: o jogo nao pode guardar uma quantidade infinita de entidades.
        # tenha cuidado com o numero de entidades que voce for criar!
        
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret

# Argumentos (obrigatoriamente):
# a0 - struct basica
# sem retornos!
EXEMPLO.DESENHAR:
        addi sp, sp, -4
        sw ra, (sp)

        mv t0, a0       # (struct)
        # la a0, textura_exemplo        # textura
        lw a1, entidade.X(t0)           # pos x
        li a2, entidade.Y(t0)           # pos y

        # corrige posicao x e y para ser impresso relativo ah camera
        la t3, camera
        lw t1, camera_x(t3)
        lw t2, camera_y(t3)
        sub a1, a1, t1          
        sub a2, a2, t2          
        
        # dimensoes da textura
        li a3, 20
        li a4, 20

        # poderia ser tbm algo como
        # lw a3, (t0)
        # lw a4, 4(t0)

        jal PROC_IMPRIMIR_TEXTURA

        lw ra, (sp)
        addi sp, sp, 4
        ret

