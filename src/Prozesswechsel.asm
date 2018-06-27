	.text
# User Programm 1: Gib Zahlen aus
task1:	li	$a0, '0'
	li 	$v0, 11
	li 	$t0, 10	
loop1:	syscall
	addiu   $a0, $a0, 1
	divu    $t1, $a0, ':'
	multu   $t1, $t0
	mflo    $t1
	subu    $a0, $a0, $t1
	b	loop1

# User Programm 2: Gib B aus
task2:	li	$a0, 'B'
	li	$v0, 11
loop2:  syscall
	b	loop2

# Bootup Code
	.ktext
# TODO Implementieren Sie den Bootup Code
# Initialisieren Sie hierfür alle benötigten Datenstrukturen
# Das finale exception return (eret) soll zum Anfang von Programm 1 springen
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
# TODO Erkennen und Implementieren Sie Systemaufrufe hier. Hier können Sie Teile aus Aufgabe 2.1 wiederverwenden
# Denken Sie daran, dass eine Anpassung des epc erforderlich sein kann.

	j ret

# Interrupt-spezifischer code

interrupt:
# TODO Für Timer-Interrupt, rufen Sie timint auf

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

	.ktext
# Hilfsfunktionen
timint:
# TODO Bearbeiten Sie den Timer-Interrupt hier und rufen Sie diese Funktion aus der Ausnahmebehandlung auf
	j	ret

# Prozesskontrollblöcke
# An Platz 0: Der Programmzähler
# An Platz 1: Zustand des Prozesses. Hierbei bedeutet 0 -> idle, 1 -> running.
# An Platz 2-..: Zustand der Register
	.kdata
pcb_task1:
.word task1
.word 0
# TODO Allozieren Sie Platz für den Zustand aller Register hier
pcb_task2:
.word task2
.word 0
# TODO Allozieren Sie Platz für den Zustand aller Register hier
