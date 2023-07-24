.data
.include "sound.data"

.text
	#teste de efeitos sonoros
	#forma: a0: nota, a1: duração em ms, a2: instrumento, a3: volume (todos indo de 0 a 127 exceto duração)
	la s0, instrument
	lw a2, 0(s0)
	la s0, volume
	lw a3, 0(s0)
	la s0, sound
	lw t0, 0(s0)
	slli t0, t0, 3
	addi s0, s0, 4
	add s1, s0, t0
SLOOP:	beq s0, s1, SFIM
	lw a0, 0(s0)
	lw a1, 4(s0)
	li a7, 31
	ecall
	addi s0, s0, 8
	j SLOOP
SFIM:	li a7, 10
	ecall
