.data
.include "test.data"

.text
	li s0, 0xFF000000 #endereço do frame 0
	la s1, test #endereço da imagem
	lw s3, 0(s1) #linhas da imagem
	lw s2, 4(s1) #colunas da imagem
	addi s1, s1, 8 #primeiro pixel da imagem
	mul s4, s2, s3
	add s4, s4, s1 #último pixel da imagem
	li t0, 0 #iterador
	li s5, 320 #colunas do frame 0
LOOP:	beq s1, s4, END #iterar pelos pixels da imagem
	lw t6, 0(s1) #pega os pixels atuais
	rem t1, t0, s3 #t1 = i%colunas = coluna
	div t2, t0, s3 #t2 = i/colunas = linha
	mul t3, s5, t2 #linha
	add t3, t3, t1 #coluna
	add t3, t3, s0 #endereço para colocar o pixel
	sw t6, 0(t3) #coloca os pixels na posição atual
	addi s1, s1, 4
	addi t0, t0, 4
	j LOOP
	
END:	li a7, 10
	ecall #exit
