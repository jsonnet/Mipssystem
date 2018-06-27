.text

usefultask:
	# Programm, welches sinnvolle Berechnungen ausführen kann,
	# während die Ausnahmebehandlung sich um die Ein-/Ausgabe kümmert.
	# Anders als beim Polling ist es mit Interrupts sehr einfach neben der Ein-Ausgabe
	# noch sinnvolle Berechnungen auszuführen und keine Rechenzeit auf unnötiges Warten zu verschwenden.
	# Dies soll unverändert bleiben!
	b usefultask

# Bootup-Code
.ktext
# TODO Implementieren Sie die Systeminitialisierung hier. Was müssen Sie hierfür tun?

# TODO Springe zu unserem nützlichen Programm
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

# Exception code. Für die Aufgabe 2.3 müssen nicht unbedingt exceptions behandelt werden.
	j ret

# Interrupt-spezifischer code
# TODO Implementieren Sie hier Handler für Tastatur- und Display-Interrupts
# Sie können die eigentliche Funktionalität in Funktionen auslagern. (Ähnlich zu Aufgabe 2.2)
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

# TODO Allozieren Sie hier Ihren 16-Byte großen Puffer
