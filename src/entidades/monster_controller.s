# classe responsavel por controlar o spawn de monstros. Sempre havera simultaneamente 5 monstros na tela do jogador.
# Se um morrer, chama o procedimento para criar um novo. Se ja tiver chegado no limite, pula o procedimento

.data

    .eqv contador_monster 0
    .eqv timer_monster 1

    MONSTER_CONTROLLER: .byte 0 # acho melhor que seja estatico para nao depender de referencia.
    .byte 60 # cooldown de 2 segundo para os monstros nao ficarem amontoados

.text

PROC_MONSTER_CONTROLLER:

    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, MONSTER_CONTROLLER
    lb t1, contador_monster(t0)
    lb t2, timer_monster(t0)

    addi t2, t2, -1
    sb t2, timer_monster(t0)

    bnez t2, SEM_SPAWN_MONSTRO

    li t2, 60
    sb t2, timer_monster(t0)

    li t2, 3
    beq t1, t2, SEM_SPAWN_MONSTRO

    addi t1, t1, 1
    sb t1, contador_monster(t0)

    la t0, jogador
    lw t1, 0(t0) # carrega a struct basica do jogador

    lw t2, entidade.STRUCT_ESPECIFICA(t1)
    lb t2, JOGADOR.FLAG_BOSSFIGHT(t2)

    bnez t2, SEM_SPAWN_MONSTRO

    csrr a0, cycle # esse primeiro serve para obter a posicao X do novo mosntro
    li a1, 130 
    li a7, 42
    
    ecall
    
    lw t2, entidade.X_Q12(t1)
    srai t2, t2, 12
    add a0, a0, t2
    mv t3, a0

    lw t2, entidade.Y_Q12(t1)
    srai t2, t2, 12
    addi t2, t2, -20
    mv t4, t2

    csrr a0, cycle
    li a1, 2
    li a7, 42

    jal Random2 

    beqz a0, SPAWN_SCHNOZ

    li a0, ENTIDADE_JUMPER
    mv a1, t3
    mv a2, t4
    jal PROC_ADICIONAR_ENTIDADE

SPAWN_SCHNOZ:

    li a0, ENTIDADE_SCHNOZ
    mv a1, t3
    mv a2, t4
    jal PROC_ADICIONAR_ENTIDADE


SEM_SPAWN_MONSTRO:


    lw ra, 0(sp)
    addi sp, sp, 4
    ret