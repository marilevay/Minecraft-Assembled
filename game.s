.data
.include "game.data"
.include "phases.data"
.include "../Sprites/main_transparent.data"
.include "../Sprites/enderman_transparent.data"
.include "../Sprites/zumbi_transparent.data"
.include "../Sprites/creeper_transparent.data"
.include "../Sprites/arrow_transparent.data"
.include "../Sprites/enderpearl.data"

.text

# MAIN -> SETUP
# -> GAME -> subroutines
#Registers level: t: subroutines, s: routines, a: routines

#função principal do jogo: controlar o andamento das fases
MAIN:	# 0xFF000000 #endereço do frame 0
	# 0xFF100000 #endereço do frame 1
	# 0xFF200604 #endereço da escolha de frame
	# 0xFF200000 #endereço do teclado
	#s11 : endereço de retorno para procedimentos com múltiplas chamadas
	li a0, 1 #fase
	call SETUP #seta a fase para jogo
	call GAME #jogo
	li a7, 10
	ecall #fim

#função de configuração das fases e do menu do jogador	
#a0 = fase atual (0-2); s11: ra
#seta o endereço "tile" para a imagem do tile correspondente à fase
SETUP:	#s8 = iterador da matriz da fase; s9 = iterador da matriz principal; s10 = endereço da imagem do tile
	#a4 = iterador de posição; a5 = 400 (posição final)
	mv s11, ra #s8 = return to MAIN
	la s0, phase
	li t0, 1600
	mul t0, t0, a0
	add s0, s0, t0 #informações da fase atual
	la s1, matrix
 	li s2, 0
 	li s3, 400
 	la s6, enemies
 	sw zero, 0(s6)
 	
LSETUP:	beq s2, s3, ESETUP

	li t0, 20
	rem a1, s2, t0 #x = pos%20
	div a2, s2, t0 #y = pos/20
	li t0, 12
	mul a1, a1, t0
	mul a2, a2, t0 #posições base 12 (pixels)
	
	lw t0, 0(s0)
	li t1, 10
	blt t0, t1, ISETUP
	
	addi t0, t0, -10
	lw t2, 0(s6) #n de inimigos atualmente
	addi t2, t2, 1
	sw t2, 0(s6) #+1 inimigo
	mv t3, s6
	addi t3, t3, 4
	li t4, 12
	addi t2, t2, -1
	mul t2, t2, t4
	add t3, t3, t2 #primeiro endereço sem inimigos atualmente
	sh a1, 0(t3)
	sh a2, 2(t3)
	sh a1, 4(t3)
	sh a2, 6(t3)
	sb t0, 8(t3) #direção é indiferente
	sb zero, 9(t3) #contador de ação zerado
	sb t0, 10(t3) #id do inimigo
	slli t0, t0, 1
	sb t0, 11(t3) #vida = id*2
	mv t0, zero
	
ISETUP:	sw t0, 0(s1)
SC0:	li t1, 0
	bne t0, t1, SC1
	la s4, ground
	j DSETUP
SC1:	li t1, 3
	bne t0, t1, SC2
	la s4, key
	j DSETUP
SC2:	li t1, 4
	bne t0, t1, SC3
	la s4, door
	j DSETUP
SC3:	li t1, 5
	bne t0, t1, SC4
	la s4, wall
	j DSETUP
SC4:	la s4, portal

DSETUP:	li t0, 144
	mul t0, t0, a0
	addi t0, t0, 8 #incremento para endereços dessa fase
	mv s5, a0
	la a0, ground
	add a0, a0, t0 #cobertura de tile por baixo do elemento
	add s4, s4, t0 #endereço deste elemento
	
	li a3, 0
	call DRAW
	li a3, 1
	call DRAW #desenha ocbertura de tile
	mv a0, s4
	li a3, 0
	call DRAW
	li a3, 1
	call DRAW #desenha elemento da posição
	mv a0, s5 #reseta a0 para valor da fase
	
	addi s0, s0, 4
	addi s1, s1, 4
	addi s2, s2, 1
	j LSETUP

ESETUP:	la s0, ground
	addi s0, s0, 8
	li t0, 144
	mul t0, t0, a0
	add s0, s0, t0 #endereço do tile da fase correspondente
	la s1, tile
	li t0, 0
	li t1, 144
LTILE:	beq t0, t1, ETILE
	lw t2, 0(s0)
	sw t2, 0(s1)
	addi s0, s0, 4
	addi s1, s1, 4
	addi t0, t0, 4
	j LTILE
ETILE:	jalr zero, s11, 0
	
#função que efetivamente roda o jogo: loop por instante de tempo das ações do personagem e dos inimigos
#a3: frame de desenho
GAME:	li a3, 0 #frame inicial é 0
	la s0, char
	li a4, 3
	sb a4, 8(s0) #direção inicial do personagem é para baixo
	la s0, matrix
	li t0, 1
	sw t0, 0(s0) #posição do personagem inicializada no início do jogo
#loop do jogo
GLOOP:	li s0, 0xFF200604 #endereço da escolha de frame
	sw a3, 0(s0) #seleciona o frame deste instante de tempo
	xori a3, a3, 1 #prepara próxumo frame
	li a7, 32
	li a0, 100 
	ecall #instante de tempo: 0,1s
# Resolução do personagem
# s0: informações do personagem
	la s0, char
	lb t0, 11(s0) #vida
	bne t0, zero, CI #se morreu... #seffs perdeu a fase
	li a7, 10
	ecall
CI:	lh a1, 0(s0) #a1: x atual
	lh a2, 2(s0) #a2: y atual
	lb a4, 8(s0) #a4: direção atual
	li a5, 1
	sh a1, 4(s0)
	sh a2, 6(s0)
	lb t1, 10(s0) #levou dano #seffs dano
	beq t1, zero, CDES
	addi t1, t1, -1
	sb t1, 10(s0)
	li t2, 3
	bne t1, t2, CDES #vida descontada imediatamente após receber dano
	addi t0, t0, -1
	sb t0, 11(s0) #perdeu vida mas está invencível por 0,5 segundos
CDES:	call INPUT # retorna a ação no a0
	li t0, 0
	beq a0, t0, CFIM
	li t0, 5
	beq a0, t0, CSHOT
	mv t0, a4 #direção antiga
	mv a4, a0 #nova direção
	bne t0, a4, CFIM #muda de direção sem andar
	call MOVE
	j CFIM
CSHOT:	call NSHOT
CFIM:	sh a1, 0(s0)
	sh a2, 2(s0)
	sb a4, 8(s0)
	la a0, tile
	call DRAW
	li a5, 0
	call CHOOSE
	call DRAW #desenha o personagem na posição correta sobre o tile da fase
	la a0, tile
	xori a3, a3, 1 #muda os frames
	call DRAW #apaga o rastro do personagem
	lh a1, 4(s0) #posição x antiga
	lh a2, 6(s0) #posição y antiga
	call DRAW
	xori a3, a3, 1 #volta ao frame atual
# Resolução dos inimigos
# s0: lista de inimigos
	la s0, enemies
	lw t0, 0(s0)
	addi s0, s0, 4 #iterador da posição de inimigo
	li t1, 12
	mul t0, t0, t1 #espaços com inimigos
	add s1, s0, t0 #s1: primeiro espaço sem inimigos
ELOOP:	beq s0, s1, EFIM
	lb t0, 11(s0) #vida atual do inimigo
	lh a1, 0(s0)
	lh a2, 2(s0) #posição atual do inimigo
	sh a1, 4(s0)
	sh a2, 6(s0) #posição antiga do inimigo guardada
	lb a4, 8(s0) #direção atual do inimigo
	lb a5, 10(s0) #id do inimigo
	addi s0, s0, 12 #seta próxima célula de inimigo
	beq t0, zero, ELOOP #ignorar inimigos mortos
	bgt t0, zero, EDES
	addi s0, s0, -12
	sb zero, 11(s0)
	j ETRC
EDES:	addi s0, s0, -12
	lb t0, 9(s0) #contador de ação
	addi t0, t0, 1
	sb t0, 9(s0) #contador++
	li t1, 2
	bne a5, t1, EACT #creeper ataca a cada 5 instantes de tempo
	li t1, 6
	blt t0, t1, EDRAW
EACT:	li t1, 4
	blt t0, t1, EDRAW #pode não ser a vez de agir ainda
	sb zero, 9(s0) #zera o contador depois de decidir agir
	la s2, char
	lh t0, 4(s2) #old x (char)
	lh t1, 6(s2) #old y (char)
	sub t0, t0, a1 #dx
	sub t1, t1, a2 #dy
	mv t2, t0
	mv t3, t1
MODX:	bge t2, zero, MODY
	li t4, -1
	mul t2, t2, t4 # |dx|
MODY:	bge t3, zero, MODC
	li t4, -1
	mul t3, t3, t4 # |dy|
MODC:	slt t4, t2, t3 #t4 = 0: |dx| >= |dy|
EA3:	li t2, 3
	blt a5, t2, EA12
	beq t0, zero, ESHOTY
	beq t1, zero, ESHOTX
EA3X:	beq t4, zero, EA3Y
	slt t3, t0, zero
	slli t3, t3, 1 #direção x
	li a4, 2
	add a4, a4, t3
	j EMOV
EA3Y:	slt t3, zero, t1
	slli t3, t3, 1 #direção y
	li a4, 1
	add a4, a4, t3
	j EMOV
ESHOTX:	slt t3, t0, zero
	slli t3, t3, 1
	li a4, 2
	add a4, a4, t3 #direção x setada
	j ESHOT
ESHOTY:	slt t3, zero, t1
	slli t3, t3, 1
	li a4, 1
	add a4, a4, t3 #direção y setada
	j ESHOT
ESHOT:	sb a4, 8(s0)
	call NSHOT #enderman atira
	j EDRAW
EA12:	li t2, 1
EA12X:	beq t4, t2, EA12Y
	slt t3, t0, zero
	slli t3, t3, 1 #0: direita, 2: esquerda
	li a4, 2
	add a4, a4, t3 #a4 = 2 => direita, a4 = 4 => esquerda
	j EMOV
EA12Y: 	slt t3, zero, t1
	slli t3, t3, 1 #0: cima, 2: baixo
	li a4, 1
	add a4, a4, t3 #1: cima, 3:baixo
EMOV:	sb a4, 8(s0) #salva direção
	mv s2, a5 #guarda o id
	la t3, enemies
	sub a5, s0, t3
	addi a5, a5, 10 #indice da célula do inimigo + 10
	call MOVE
	sh a1, 0(s0)
	sh a2, 2(s0) #atualiza posições
	mv a5, s2 #recupera o id
EDRAW:	la a0, tile
	call DRAW 
	call CHOOSE
	call DRAW #desenha inimigo na nova posição
ETRC:	la a0, tile
	xori a3, a3, 1
	call DRAW
	lh a1, 4(s0)
	lh a2, 6(s0)
	call DRAW
	xori a3, a3, 1 #apaga o rastro do inimigo no frame anterior
	addi s0, s0, 12
	j ELOOP
EFIM:	li zero, 0 #fim da resolução dos inimigos	
# Resolução dos projéteis
#s0: fila wrap-up de projéteis
	la s0, shots
	addi s0, s0, 4
	li t0, 2400
	add s1, s0, t0
SLOOP:	beq s0, s1, SFIM
	lb t0, 11(s0)
	addi s0, s0, 12
	beq t0, zero, SLOOP #tiro pode estar desativado
	addi s0, s0, -12
	lh a1, 0(s0)
	lh a2, 2(s0)
	sh a1, 4(s0)
	sh a2, 6(s0)
	lb a4, 8(s0)
	lb a5, 10(s0)
	li t0, -1
	mul a5, a5, t0
	call MOVE #se não moveu, desativar
	lh t0, 4(s0)
	lh t1, 6(s0)
	bne a1, t0, SMOV
	bne a2, t1, SMOV
	sb zero, 11(s0)
	j STRC
SMOV:	sh a1, 0(s0)
	sh a2, 2(s0)
	la a0, tile
	call DRAW
	li t2, -1
	mul a5, a5, t2
	srai a5, a5, 1
	addi a5, a5, 4
	call CHOOSE
	call DRAW
STRC:	la a0, tile
	xori a3, a3, 1
	call DRAW
	lh a1, 4(s0)
	lh a2, 6(s0)
	call DRAW
	xori a3, a3, 1
	addi s0, s0, 12
	j SLOOP
SFIM:	li zero, 0
# Fim do instante de tempo
	
	j GLOOP
	
	
#inserir uma instância de projétil na fila wrap-up
#a1: x, a2: y, a4: dir, a5: id
NSHOT:	la t0, shots
	lw t1, 0(t0) #incremento ao endereço para chegar ao primeiro espaço vazio
	addi t0, t0, 4
	li t2, 12
	mul t1, t1, t2 #incremento * 12
	add t0, t0 t1 #endereço para registro de novo tiro
	sh a1, 0(t0)
	sh a2, 2(t0)
	sh a1, 4(t0)
	sh a2, 6(t0) #posição
	sb a5, 10(t0) #id
	li t1, 1
	sb t1, 11(t0) #ativo
	sb a4, 8(t0) #direção = direção do personagem
	la t0, shots
	lw t1, 0(t0)
	addi t1, t1, 1 #incremento++
	li t2, 200
	rem t1, t1, t2 #incremento %= max
	sw t1, 0(t0)
	ret #seffs shot personagem x enderman


#selecionar a imagem a ser desenhada
#a4: direção (1-4); a5: id (0-3);
#retorna no a0 o endereço da imagem correspondente
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
MIC3:	li t2, 3
	bne a5, t2, MIC4
	la a0, enderman_transparent
	j MSI
MIC4:	li t2, 4
	bne a5, t2, MIC5
	la a0, arrow_transparent
	j MSI
MIC5:	la a0, enderpearl
	#escolhe a rotação da imagem com base na direção
MSI:	addi a0, a0, 8 #pula as linhas e colunas
	addi a4, a4, -1 #direção -= 1 (cima = 0)
	mul t3, t4, a4 #pular direção * 144 bytes para chegar na imagem correta
	add a0, a0, t3 #seleciona a imagem correta
	addi a4, a4, 1 #volta ao padrão
	ret

	
#função de mover o personagem
# a1: x atual; a2: y atual; a4: direção; a5: id(-3/-1/1/posição na lista de inimigos(+10));
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
	bgt t3, t2, MEND1
	blt t3, zero, MEND1
	bgt t4, t2, MEND1
	blt t4, zero, MEND1
	li t2, 3
	div t3, t3, t2 #nx/12 = posx
	div t4, t4, t2 #ny/12 = posy
	div t0, t0, t2 #dx/12
	div t1, t1, t2 #dy/12
	li t2, 20
	mul t4, t4, t2 #ny *= 20
	mul t1, t1, t2 #dy *= 20
	la t5, matrix
	add t5, t5, t3 #posição na matrix += x
	add t5, t5, t4 #npos += 20y
	sub t6, t5, t0 #oldpos = pos - dx
	sub t6, t6, t1 #oldpos -= 20dy
	lw t0, 0(t5) #t0 = conteúdo na matriz na npos
	j MIDS
MEND1:	li t2, 3
	div t3, a1, t2
	div t4, a2, t2
	li t2, 20
	mul t4, t4, t2
	la t6, matrix
	add t6, t6, t3
	add t6, t6, t4
	blt a5, zero, MENDS
	ret
MIDS:	bgt a5, zero, MIDE #if is shot
	beq zero, t0, MSM #só mover em caso de espaço vazio
	li t1, -1
MSC:	bne a5, t1, MSE
	li t1, 10
	blt t0, t1, MENDS #se não é espaço vazio e não é inimigo, é obstáculo
	addi t0, t0, -10
	la t2, enemies
	add t0, t2, t0
	lb t1, 11(t0)
	addi t1, t1, -1
	sb t1, 11(t0)
	bne zero, t1, MENDS #se o inimigo não morreu, apenas retorne
	addi t1, t1, -1
	sb t1, 11(t0) #morreu mas não foi apagado do mapa
	sw zero, 0(t5) #apaga da matriz: morto no mapa
	j MENDS
MSE:	li t1, 1
	bne t0, t1, MENDS #se não for um personagem, enderpearl some
	la t0, char
	lb t1, 10(t0)
	bgt t1, zero, MENDS #persongaem em estado de invencibilidade
	li t1, 4
	sb t1, 10(t0) #contador de dano = 4 (personagem invencível)
	j MENDS
MSM:	sw a5, 0(t5)
	li t1, 20
	div t4, t4, t1
	li t1, 3
	mul t4, t4, t1
	mul t3, t3, t1
	mv a1, t3
	mv a2, t4
MENDS:	lw t0, 0(t6)
	bge t0, zero, MEND2
	sw zero, 0(t6) #apaga tiro da posição antiga
MEND2:	ret
MIDE:	li t1, 10 #if is enemy
	blt a5, t1, MIDC
	li t1, 3
	bge t0, t1, MEND #obstáculo ou outro inimigo
	blt t0, zero, MEND #projétil
	beq t0, zero, MEM #move apenas para espaço vazio
	la t0, char
	lb t1, 10(t0)
	bgt t1, zero, MEND #persongaem em estado de invencibilidade
	li t1, 4
	sb t1, 10(t0) #contador de dano = 4 (personagem invencível)
	la t2, enemies
	addi a5, a5, -10
	add t0, t2, a5
	lb t2, 10(t0)
	addi a5, a5, 10
	li t1, 2
	bne t1, t2, MEND #caso seja um creeper quem causou dano...
	li a7, 10
	ecall #personagem deve morrer aqui!
MEM:	sw zero, 0(t6)
	sw a5, 0(t5) #atualiza posições
	li t1, 20
	div t4, t4, t1
	li t1, 3
	mul t4, t4, t1
	mul t3, t3, t1
	mv a1, t3
	mv a2, t4
	j MEND
MIDC:	beq t0, zero, MCM #if empty space proceed
	li t1, 10
	bge t0, t1, MEND #char cant move towards enemy
	blt t0, zero, MEND #char cant move towards shot
MCC0:	li t1, 3
	bne t0, t1, MCC1 #if key #seffs pickup (=baque)
	la t0, char
	li t1, 1
	sb t1, 9(t0) #personagem tem a chave
	j MCM #chave agora é um espaço vazio
MCC1:	li t1, 4
	bne t0, t1, MCC2 #if door
	la t0, char
	lb t1, 9(t0)
	beq t1, zero, MEND #sem chave, a porta é como parede
	sw zero, 0(t5) #porta agora é um espaço vazio disfarçado
	sb zero, 9(t0) #personagem não tem mais a chave
	#sh t3, 4(t0)
	#sh t4, 6(t0) #apagar o rastro do personagem na porta
	j MEND
MCC2:	li t1, 5
	beq t0, t1, MEND #if wall return
MCC3:	li a7, 10 #transição de fase
	ecall
MCM:	sw zero, 0(t6) #a posição antiga está vazia
	sw a5, 0(t5) #guarda o id na posição
	li t1, 20
	div t4, t4, t1
	li t1, 3
	mul t4, t4, t1
	mul t3, t3, t1
	mv a1, t3
	mv a2, t4
MEND:	ret
	
#devolve a tecla pressionada no teclado, indicando a ação do personagem
#a0 (0-5): ação do personagem
INPUT:	li t6, 0xFF200000 #t6 = KDMMIO;
	lw t0, 0(t6)
	andi t0, t0, 0x0001
	li a0, 0
	beq t0, zero, TECLA #sem tecla pressionada
	lw t1, 4(t6) #lê a tecla pressionada
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
C4:	li t2, ' '
	bne t1, t2, TECLA
	li a0, 5
TECLA:	ret #a0 = {0: nada, 1: cima, 2: direita,
	    #      3: baixo, 4: esquerda, 5: tiro}

#função de desenho com base em uma imagem 12x12 e sua posição x, y
#a0 = endereço da imagem; a1 = x; a2 = y; a3 = frame;
DRAW:	#t0 = q linhas; t1 = q colunas; t2 = contador de linha; t3 = contador de coluna; t4 = endereço do bitmap display;
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
	mul t6, a2, t5 #endereço = endereço base + x + 320*y
	add t4, t4, t6 #endereço de desenho
	mv t5, a0
D_ROW:	bge t2, t0, EDLOOP
D_COL:	bge t3, t1, N_ROW
	lw t6, 0(t5)
	sw t6, 0(t4)
	addi t4, t4, 4
	addi t5, t5, 4
	addi t3, t3, 4
	j D_COL
N_ROW:	mv t3, zero #contador de colunas volta para zero
	addi t2, t2, 1
	addi t4, t4, 320
	sub t4, t4, t1 #seta t4 para a próxima linha
	j D_ROW
EDLOOP:	ret
