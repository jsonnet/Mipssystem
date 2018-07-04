.text

usefultask:
	# Programm, welches sinnvolle Berechnungen ausf�hren kann,
	# w�hrend die Ausnahmebehandlung sich um die Ein-/Ausgabe k�mmert.
	# Anders als beim Polling ist es mit Interrupts sehr einfach neben der Ein-Ausgabe
	# noch sinnvolle Berechnungen auszuf�hren und keine Rechenzeit auf unn�tiges Warten zu verschwenden.
	# Dies soll unver�ndert bleiben!
	b usefultask

	############################
	# KERNEL UND ERRORHANDLING #
	############################

########## Interne Kernel-Daten. #########
	.kdata
exc_v0:	.word 0
exc_a0:	.word 0
# TODO Zus�tzliche Pl�tze f�r Register die Sie in der Ausnahmebehandlung tempor�r sichern m�chten

# TODO Allozieren Sie hier Ihren 16-Byte gro�en Puffer


######## Bootup-Code ##########

.ktext
# TODO Implementieren Sie die Systeminitialisierung hier. Was m�ssen Sie hierf�r tun?

# TODO Springe zu unserem n�tzlichen Programm
eret


########## Ausnahmebehandlung #########

# Hier d�rfen Sie $k0 und $k1 verwenden
# Andere Register m�ssen zun�chst gesichert werden
.ktext 0x80000180
	# Sichere alle Register, die wir in der Ausnahmebehandl�ung verwenden werden
	move $k1, $at
	sw $v0 exc_v0
	sw $a0 exc_a0

	mfc0 $k0 $13		# Cause register

# Der folgende Fall kann Ihnen als !Beispiel! zur Erkennung einer bestimmten Ausnahme dienen:
# Teste ob unser PC miss-aligned ist, in diesem Fall h�ngt die Maschine
	bne $k0 0x18 okpc	# Bad PC Exception
	mfc0 $a0 $14		# EPC
	andi $a0 $a0 0x3	# Ist EPC Wort-aligned?
	beq $a0 0 okpc
fail:	j fail			# PC ist nicht aligned -> Prozessor h�ngt

# Der PC ist in Ordnung, teste auf weitere Exceptions/Interrupts
okpc:
	andi $a0 $k0 0x7c
	beq $a0 0 interrupt	# 0 bedeutet Interrupt

# Exception code. F�r die Aufgabe 2.3 m�ssen nicht unbedingt exceptions behandelt werden.
	j ret

########### Interrupt-spezifischer code ############

# TODO Implementieren Sie hier Handler f�r Tastatur- und Display-Interrupts
# Sie k�nnen die eigentliche Funktionalit�t in Funktionen auslagern. (�hnlich zu Aufgabe 2.2)
interrupt:
	j ret
ret:
# Stelle verwendete Register wieder her
	lw $v0 exc_v0
	lw $a0 exc_a0
	move $at, $k1
# Kehre zum EPC zur�ck
	eret
