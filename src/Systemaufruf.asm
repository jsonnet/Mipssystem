	.text
# User-Programm
task:
	la      $a0, msg
	li	$v0, 4
	syscall
	li	$a0, 'D'
	li 	$v0, 11
loop:	syscall
	li	$a0, 'E'
	b	loop

# Daten
	.data
msg: .asciiz "Hello World!"

# Bootup Code
	.ktext
# TODO Implementieren Sie den Bootup Code
# Das finale exception return (eret) soll zum Anfang des User-Programms springen
eret

# Ausnahmebehandlung
# Hier dürfen Sie $k0 und $k1 verwenden
# Andere Register müssen zunächst gesichert werden
.ktext 0x80000180
	# Sichere alle Register, die wir in der Ausnahmebehandlöung verwenden werden
	move $k1, $at
	sw $v0 exc_v0
	sw $a0 exc_a0

	mfc0 $k0 $13		# Cause register

# Der folgende Fall kann Ihnen als !Beispiel! zur Erkennung einer bestimmten Ausnahme dienen:
# Teste ob unser PC miss-aligned ist, in diesem Fall hängt die Maschine
	bne $k0 0x18 okpc	# Bad PC Exception
	mfc0 $a0 $14		# EPC
	andi $a0 $a0 0x3	# Ist EPC Wort-aligned?
	beq $a0 0 okpc
fail:	j fail			# PC ist nicht aligned -> Prozessor hängt

# Der PC ist in Ordnung, teste auf weitere Exceptions/Interrupts
okpc:
	andi $a0 $k0 0x7c
	beq $a0 0 interrupt	# 0 bedeutet Interrupt

# Exception code
# TODO Erkennen und implementieren Sie Systemaufrufe hier.
# Denken Sie daran, dass eine Anpassung des epc erforderlich sein kann.

	j ret

# Interrupt-spezifischer code (Für diese Aufgabe ist hier nichts zu erledigen)
interrupt:
	j ret
ret:
# Stelle verwendete Register wieder her
	lw $v0 exc_v0
	lw $a0 exc_a0
	move $at, $k1
# Kehre zum EPC zurück
	eret

# Interne Kernel-Daten.
	.kdata
exc_v0:	.word 0
exc_a0:	.word 0
# TODO Zusätzliche Plätze für Register die Sie in der Ausnahmebehandlung temporär sichern möchten
