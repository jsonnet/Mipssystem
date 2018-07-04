.text

# Bootup-Code
# Da wir hier nur Ein-Ausgabe mit Polling realisieren und keine Berechnungen durchf�hren, kann Ihr gesamter Code hier stehen.


.ktext
start:

	#Checke das Ready-Bit der Tastatur
		lw $t0, 0xffff0000
		andi $t1, $t0, 1
		bne $t1, 1, start 		#Wenn nicht ready springe zu start
	#Eingabe abspeichern
		lb $t0, 0xffff0004		#Eingabe abspeichern

#Die Eingabe auch ausgeben
	busy:
		lw $t2, 0xffff0008
		andi $t3, $t2, 1
		bne $t3, 1, busy

	#Das letzte Byte des Bildschirms beschreiben zur Ausgabe
	#lw $t4, 0xffff000c
	sb		$t0, 0xffff000c

b start
