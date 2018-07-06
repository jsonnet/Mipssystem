############################
# DAS PROGRAMM (das läuft) #
############################

	.text
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



############################
# KERNEL UND ERRORHANDLING #
############################

###### Interne Kernel-Daten. #######
	.kdata
save_v0:	.word 0
save_a0:	.word 0
# TODO Zus�tzliche Pl�tze f�r Register die Sie in der Ausnahmebehandlung tempor�r sichern m�chten

#Lukas:
ENABLE_GLOBAL_INTERRUPT: .word 0x00000001

###### Bootup Code #################

	.ktext
# TODO Implementieren Sie den Bootup Code
# Das finale exception return (eret) soll zum Anfang des User-Programms springen

#LUKAS:

	#Aktiviere Interrupts global
	mfc0	$t0, $12		#hole Infos aus Statusregister 12
	#lw $t1, ENABLE_GLOBAL_INTERRUPT
	ori $t0, $t0, 0x00000001	#So verodern, dass alle vorderen Bits gleich bleiben aber das letzte auf jeden Fall 1 ist
	mtc0	$t0, $12		#Schreibe den neuen Wert zurück ins Statusregister

	#Den epc auf das Userprogramm setzten, damit eret springt
	la $t2, task		#Die Adresse von task holen
	mtc0 $t2, $14		#Die Adresse in epc register 14 schreiben

#END LUKAS

eret

###### Ausnahmebehandlung ############

# Hier d�rfen Sie $k0 und $k1 verwenden
# Andere Register m�ssen zun�chst gesichert werden
.ktext 0x80000180
	# Sichere alle Register, die wir in der Ausnahmebehandl�ung verwenden werden
	move $k1, $at
	sw $v0 save_v0
	sw $a0 save_a0

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

# Exception code
# TODO Erkennen und implementieren Sie Systemaufrufe hier.
# Denken Sie daran, dass eine Anpassung des epc erforderlich sein kann.

#Lukas:
#Prüfe auf syscall
bne $k0, 0x20, nosyscall
	#Hier gilt jetzt es ist ein syscall
	bne $v0, 11, noprintChar
		#TODO: Hier Code für printChar => das char liegt in $a0
		#busy Schleife wartet auf Bildschirm bis er ready ist
		busy:
			lw $t0, 0xffff0008
			andi $t1, $t0, 0x00000001 # 00..01 oder 00...00
			bne $t1, 0x00000001, busy		#Ready-Bit von Bildschirm nicht aktiv? dann jump busy
		#Das untere Byte des Datenports mit mit dem Char befüllen
		lb $a0, save_a0
		sb $a0, 0xffff000c

		j nosyscall
noprintChar:
	bne $v0, 4, noprintString
		#TODO: print code für String => $a0 hält string
		#busy Schleife wartet auf Bildschirm bis er ready ist
		li $t2, 0
		lw $a0, save_a0				#lädt Adresse des Strings
		print:
			add $t4, $a0, $t2			#Adresse mit aktuellem Counteroffset erhöht
			lb $t3, 0($t4)						#Inhalt an dieser Adresse laden
			beq $t3, 0x00, endprint					#Auf Nullbyte prüfen und falls nötig aus print-Schleife springen
				#Busy wait auf Bildschirm
				busy2:
					lw $t0, 0xffff0008
					andi $t1, $t0, 0x00000001 # 00..01 oder 00...00
					bne $t1, 0x00000001, busy2		#Ready-Bit von Bildschirm nicht aktiv? dann jump busy
				#Das untere Byte des Datenports mit mit dem string befüllen
				sb $t3, 0xffff000c
				addiu $t2, $t2, 1
			j print
		endprint:
		j nosyscall
noprintString:
	#Ab hier einfach urück springen bzw nichts machen

nosyscall:

#TODO: Lade die register wieder:

#TODO: erhöhe epc um 1 oder 4?
	mfc0 $t0, $14
	addiu $t0, $t0, 4
	mtc0 $t0, $14

#END LUKAS

	j ret

# Interrupt-spezifischer code (F�r diese Aufgabe ist hier nichts zu erledigen)
interrupt:
	j ret
ret:
# Stelle verwendete Register wieder her
	lw $v0 save_v0
	lw $a0 save_a0
	move $at, $k1
# Kehre zum EPC zur�ck
	eret
