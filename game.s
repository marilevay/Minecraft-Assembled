.data
.include "main_transparent.data"
.include "tile.data"
Matrix: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Char_Pos: .half 0, 0, 0, 0
Map: .word 0x38383838

.text

# MAIN -> SETUP
# -> GAME


#função principal do jogo: controlar o andamento das fases
MAIN:	li s0, 0xFF000000 #endereço do frame 0
	li s1, 0xFF100000 #endereço do frame 1
	li s2, 0xFF200604 #endereço da escolha de frame
	li s3, 0xFF200000 #endereço do teclado
	la s4, Matrix
	la s5, Char_Pos
	li a0, 1 #fase
	call SETUP #seta a fase para jogo
	call GAME #jogo
	li a7, 10
	ecall #fim

#função de configuração das fases e do menu do jogador	
SETUP:	#a0 = fase atual
	mv s8, a0 #s8 = fase atual
	mv s7, ra #s7 = return to MAIN
	li a0, 0
	call DMAP #desenha o mapa correspondente nos dois frames
	li a0, 1
	call DMAP
	jalr zero, s7, 0
	
	
GAME:	li a3, 0 #frame inicial é 0
GLOOP:	lh a1, 0(s5) #a1: x atual
	lh a2, 2(s5) #a2: y atual
	sh a1, 4(s5)
	sh a2, 6(s5)
	
	li t3, 0 # dx
	li t4, 0 # dy
	call INPUT # retorna a ação no a0
GC0:	li t2, 1 #comparador
	bne a0, t2, GC1
	li t4, -12
	j RES
GC1:	li t2, 2 #comparador
	bne a0, t2, GC2
	li t3, 12
	j RES
GC2:	li t2, 3 #comparador
	bne a0, t2, GC3
	li t4, 12
	j RES
GC3:	li t2, 4 #comparador
	bne a0, t2, GC4
	li t3, -12
	j RES
GC4:	li t2, 5 #comparador
	bne a0, t2, RES
	ret 
RES:	mv a4, t3 #seta dx para a função
	mv a5, t4 #seta dy para a função
	call MOVE #retorna o a1 (x) e o a2(y) atualizados, seta o a0
	call DRAW #desenha o personagem na posição correta
	sw a3 0(s2) #troca os frames e mostra a imagem pronta
	lh a1, 4(s5) #posição x antiga
	lh a2, 6(s5) #posição y antiga
	la a0, tile
	xori a3, a3, 1 #muda os frames
	call DRAW #apaga o rastro do personagem
	j GLOOP
	
	
#função de mover o personagem
# a1: x atual; a2: y atual; a4: dx; a5: dy;
# retorna no a0 a imagem correspondente
MOVE:	#t0 = x+dx; t1 = y+dy; t2=228
	la a0, main_transparent
	
	add t0, a1, a4
	add t1, a2, a5
	li t2, 228
	bgt t0, t2, MEND
	blt t0, zero, MEND
	bgt t1, t2, MEND
	blt t1, zero, MEND
	mv a1, t0
	mv a2, t1
	sh a1, 0(s5)
	sh a2, 2(s5)
MEND:	ret
	
#devolve a tecla pressionada no teclado, indicando a ação do personagem	
INPUT:	#s3 = KDMMIO; a0 = código da ação do personagem (retorno)
	lw t0, 0(s3)
	andi t0, t0, 0x0001
	li a0, 0
	beq t0, zero, TECLA #sem tecla pressionada
	lw t1, 4(s3) #lê a tecla pressionada
	#comparar valores ASCII e retornar código da ação
C0:	li t2, 'w'
	bne t1, t2, C1
	li a0, 1
	j TECLA
C1:	li t2, 'd'
	bne t1, t2, C2
	li a0, 2
	j TECLA
C2:	li t2, 's'
	bne t1, t2, C3
	li a0, 3
	j TECLA
C3:	li t2, 'a'
	bne t1, t2, C4
	li a0, 4
	j TECLA	
C4:	li t2, 'p'
	bne t1, t2, TECLA
	li a0, 5
TECLA:	ret #a0 = {0: nada, 1: cima, 2: direita,
	    #      3: baixo, 4: esquerda, 5: tiro}

DMAP:	#a0 = frame
	li t0, 0xFF0
	add t0, t0, a0
	slli t0, t0, 12
	la t2, Map
	addi t1, t0, 0x012c
	slli t0, t0, 8
	slli t1, t1, 8
MLOOP:	beq t0, t1, EL
	lw t3, 0(t2)
	sw t3, 0(t0)
	addi t0, t0, 4
	j MLOOP
EL:	ret

DRAW:	#a0 = endereço da imagem; a1 = x; a2 = y; a3 = frame;
	#t0 = q linhas; t1 = q colunas; t2 = contador de linha; t3 = contador de coluna; t4 = endereço do bitmap display;
	#t5 = 320; t6 = conteúdo do pixel
	lw t0, 0(a0) #linhas da imagem
	lw t1, 4(a0) #colunas da imagem
	addi a0, a0, 8
	li t2, 0 #iterador de linha
	li t3, 0 #iterador de coluna
	li t5, 320 # t5 = 320
	li t4, 0xFF0
	add t4, t4, a3
	slli t4, t4, 20 #frame
	add t4, t4, a1
	mul a2, a2, t5 #endereço = endereço base + x + 320*y
	add t4, t4, a2 #endereço de desenho
D_ROW:	bge t2, t0, END_LOOP
D_COL:	bge t3, t1, N_ROW
	lw t6, 0(a0)
	sw t6, 0(t4)
	addi t4, t4, 4
	addi a0, a0, 4
	addi t3, t3, 4
	j D_COL
N_ROW:	mv t3, zero #contador de colunas volta para zero
	addi t2, t2, 1
	addi t4, t4, 320
	sub t4, t4, t1 #seta t4 para a próxima linha
	j D_ROW
END_LOOP:	ret
