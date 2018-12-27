BEGIN {
	FS = ";"
}		

{
	gsub(/,/, "\.", $6)
	gsub(/,/, "\.", $7)
	gsub(/,/, "\.", $8)
	print "Lu : QT : " $6 ", PA : " $7 ", Montant : " $8

	# conversion des nombres
	
	
	total1 += $8
	total2 += $6 * $7
}

END {
	print "Totaux lus : total1 = " total1 ", total2 = " total2
}