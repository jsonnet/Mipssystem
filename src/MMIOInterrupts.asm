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

#16-Byte gro�en Puffer
puff: .byte 16

######## Bootup-Code ##########

.ktext
#Systeminitialisierung

#Aktiviere Interrupts global
mfc0	$t0, $12		#hole Infos aus Statusregister 12
ori $t0, $t0, 0x00000001	#So verodern, dass alle vorderen Bits gleich bleiben aber das letzte auf jeden Fall 1 ist
mtc0	$t0, $12		#Schreibe den neuen Wert zurück ins Statusregister

#Aktiviere Keyboard-Interrupts
la $t0, 0xffff0000		#Tastatur Kontrollport laden
ori $t0, 0x00000002		#So verodern, dass das vorletzte Bit 1 wird (Interrupt-Enable-Bit)
sw $t0, 0xffff0000		#Veränderten Wert zurück schreiben


#Setze epc auf usefultask
la $t0, usefultask
mtc0 $t0, $14

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
	#Auf Tastatur-Interrupt prüfen:
	mfc0 $k0, $13						#Cause Register auslesen
	andi $k0, 0x00000400		#so verunden, dass man das 10. Bit checken kann
	beq $k0, 0x00000400, keyboardint

	mfc0 $k0, $13						#Cause Register auslesen
	andi $k0, 0x00000800		#so verunden, dass man das 11. Bit checken kann
	beq $k0, 0x00000800, displayint

	j ret
ret:
# Stelle verwendete Register wieder her
	lw $v0 exc_v0
	lw $a0 exc_a0
	move $at, $k1
# Kehre zum EPC zur�ck
	eret

#TODO: Interrupts implementieren
keyboardint:

	lb $t0, 0xffff0004		#Eingabe abspeichern
	la $t1, puff
	sb $t0, 0($t1)

	#Aktiviere Bildschirm-Interrupts
	la $t0, 0xffff0008		#Bildschirm Kontrollport laden
	ori $t0, 0x00000002		#Verodern, dass das vorletzte Bit 1 wird (Interrupt-Enable-Bit)
	sw $t0, 0xffff0008		#Veränderten Wert zurück schreiben

	j ret		#Keyboard return

displayint:

	la $t1, puff
	lw $t0, 0($t1)
	sb $t0, 0xffff000c

	#TODO: Deaktiviere Bildschirm-Interrupts
	la $t0, 0xffff0008
	andi $t0, 0xfffff7ff
	sw $t0, 0xffff0008

	j ret		#Display return
