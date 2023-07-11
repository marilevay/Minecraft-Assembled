.data
.include "game.data"
.include "main_transparent.data"
.include "zumbi_transparent.data"
.include "enderman_transparent.data"
.include "creeper_transparent.data"
.include "tile.data"
Map: .word 0x38383838
.text

# MAIN -> SETUP
# -> GAME

#função principal do jogo: controlar o andamento das fases
MAIN:	li s0, 0xFF000000 #endereço do frame 0
	li s1, 0xFF100000 #endereço do frame 1
	li s2, 0xFF200604 #endereço da escolha de frame
	li s3, 0xFF200000 #endereço do teclado
	la s4, matrix #matriz com as informações do mapa
	la s5, char #endereço das informações do personagem
	la s6, enemies #endereço das informações dos inimigos
	la s7, shots #endereço das informações dos tiros
	#s8 : endereço de retorno para procedimentos com múltiplas chamadas
	li a0, 1 #fase
	call SETUP #seta a fase para jogo
	call GAME #jogo
	li a7, 10
	ecall #fim

#função de configuração das fases e do menu do jogador	
SETUP:	#a0 = fase atual
	mv s8, ra #s8 = return to MAIN
	li a0, 0
	call DMAP #desenha o mapa correspondente nos dois frames
	li a0, 1
	call DMAP
	jalr zero, s8, 0
	
#função que efetivamente roda o jogo: loop por instante de tempo das ações do personagem e dos inimigos
GAME:	li a3, 0 #frame inicial é 0
	li a4, 3
	sb a4, 11(s5) #direção inicial do personagem é para baixo
#loop do jogo
GLOOP:	li a7, 32
	li a0, 100 #instante de tempo: 0,1s
	ecall
# Resolução do personagem
# s5: informações do personagem
	lh a1, 0(s5) #a1: x atual
	lh a2, 2(s5) #a2: y atual
	lb a4, 11(s5) #a4: direção atual
	li a5, 1
	sh a1, 4(s5)
	sh a2, 6(s5)
	call INPUT # retorna a ação no a0
	li t0, 0
	beq a0, t0, CFIM
	li t0, 5
	beq a0, t0, CFIM
	mv t0, a4 #direção antiga
	mv a4, a0 #nova direção
	bne t0, a4, CFIM #muda de direção sem andar
	call MOVE
CFIM:	li a5, 0
	call CHOOSE
	sh a1, 0(s5)
	sh a2, 2(s5)
	sb a4, 11(s5)
	call DRAW #desenha o personagem na posição correta
	sw a3 0(s2) #troca os frames e mostra a imagem pronta
	lh a1, 4(s5) #posição x antiga
	lh a2, 6(s5) #posição y antiga
	la a0, tile
	addi a0, a0, 8
	xori a3, a3, 1 #muda os frames
	call DRAW #apaga o rastro do personagem
	xori a3, a3, 1 #volta ao frame atual
# Resolução dos inimigos
# s6: lista de inimigos
	lw t0, 0(s6)
	mv t6, s6
	addi t6, t6, 4 #t6: endereço do primeiro inimigo
	slli t0, t0, 2
	add t5, t6, t0 #t5: primeiro espaço sem inimigos
ELOOP:	beq t6, t5, EFIM
	lb t0, 8(t6) #vida atual do inimigo
	lh a1, 0(t6)
	lh a2, 2(t6) #posição atual do inimigo
	lb a4, 11(t6) #direção atual do inimigo
	lb a5, 9(t6) #id do inimigo
	addi t6, t6, 12 #seta próxima célula de inimigo
	beq t0, zero, ELOOP #ignorar inimigos mortos
	lh t1, 4(s5)
	lh t2, 6(s5) #posição antiga do personagem a ser seguida
	#cálculo: inimigos muito longe do personagem não fazem nada, 
	#inimigos que atiram e têm o personagem na mira atiram, 
	#inimigos melee adjacentes causam dano (creeper morre),
	#outros ajustam direção e seguem o personagem
	#ação: ativar flag de dano no personagem, adicionar na fila de projéteis,
	#mover o inimigo e desenhar sua imagem e cobertura de rastro
EFIM:	li zero, 0 #fim da resolução dos inimigos	
# Resolução dos projéteis
#s7: fila wrap-up de projéteis
	lw t0, 0(s7)
# Fim do instante de tempo
	xori a3, a3, 1 #prepara próxumo frame
	j GLOOP


#selecionar a imagem a ser desenhada
#a4: direção; a5: id;
#retorna no a0 a imagem correspondente
CHOOSE:	li t4, 144 #tamanho da imagem
MIC0:	li t2, 0 #comparador
	bne a5, t2, MIC1
	la a0, main_transparent
	j MSI
MIC1:	li t2, 1
	bne a5, t2, MIC2
	la a0, zumbi_transparent
	j MSI
MIC2:	li t2, 2
	bne a5, t2, MIC3
	la a0, creeper_transparent
	j MSI
MIC3:	la a0, enderman_transparent
	#escolhe a rotação da imagem com base na direção
MSI:	addi a0, a0, 8 #pula as linhas e colunas
	addi a4, a4, -1 #direção -= 1 (cima = 0)
	mul t3, t4, a4 #pular direção * 144 bytes para chegar na imagem correta
	add a0, a0, t3 #seleciona a imagem correta
	addi a4, a4, 1 #volta ao padrão
	ret

	
#função de mover o personagem
# a1: x atual; a2: y atual; a4: direção; a5: id;
#atualizar a1 e a2 se possível
MOVE:	li t0, 0 #dx
	li t1, 0 #dy
MC0:	li t2, 1 #comparador
	bne a4, t2, MC1
	li t1, -12
	j MMOV
MC1:	li t2, 2 #comparador
	bne a4, t2, MC2
	li t0, 12
	j MMOV
MC2:	li t2, 3 #comparador
	bne a4, t2, MC3
	li t1, 12
	j MMOV
MC3:	li t2, 4 #comparador
	bne a4, t2, MMOV
	li t0, -12
MMOV:	add t3, a1, t0 #nx
	add t4, a2, t1 #ny
	li t2, 228
	bgt t3, t2, MEND
	blt t3, zero, MEND
	bgt t4, t2, MEND
	blt t4, zero, MEND
	li t2, 12
	div t3, t3, t2 #nx/12 = posx
	div t4, t4, t2 #ny/12 = posy
	div t0, t0, t2 #dx/12
	div t1, t1, t2 #dy/12
	li t2, 20
	mul t4, t4, t2 #ny *= 20
	mul t1, t1, t2 #dy *= 20
	mv t5, s4
	add t5, t5, t3 #posição na matrix += x
	add t5, t5, t4 #npos += 20y
	sub t6, t5, t0 #oldpos = pos - dx
	sub t6, t6, t1 #oldpos -= 20dy
	lb t2, 0(t5) #t2 = conteúdo na matriz na npos
	bne t2, zero, MEND #só permite a movimentação em caso de espaço vazio
	sb a5, 0(t5) #guarda o id na posição
	sb zero, 0(t6) #a posição antiga está vazia
	li t2, 20
	div t4, t4, t2
	li t2, 12
	mul t4, t4, t2
	mul t3, t3, t2
	mv a1, t3
	mv a2, t4
	
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

#procedimento de inicializar o mapa no bitmap display para início de jogo
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

#função de desenho com base em uma imagem 12x12 e sua posição x, y
DRAW:	#a0 = endereço da imagem; a1 = x; a2 = y; a3 = frame;
	#t0 = q linhas; t1 = q colunas; t2 = contador de linha; t3 = contador de coluna; t4 = endereço do bitmap display;
	#t5 = 320; t6 = conteúdo do pixel
	li t0, 12
	li t1, 12
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
