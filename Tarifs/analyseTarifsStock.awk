BEGIN {
	FS = ";"
	print "Extraction : " FILENAME

	#verbose = "vrai"
}	


input != FILENAME {

	# controle du type de fichier
	if (FILENAME !~ /EDITARSTO/) {
		print "Attention : ce n'est pas le bon fichier : " FILENAME
		print ""
		print "Type de fichier attendu : 'EDITARSTO'"
		print ""
		print "Valmag / Fichiers de base / ..."

		exitAnalyse = 1
		exit 1
	}

	input = FILENAME
	print "Source : " input
	
	# fichier sortie
	output = FILENAME
	gsub(/EDITARSTO_.*_/, "tarifStock_", output)
	output2 = "tarifStock.csv"

	nomFichier = output
	gsub(/ /, "\\ ", nomFichier)
	if (system("test -f " nomFichier) == 0) {
		print "    !! Fichier existant : '" output "'"
		output = "/tmp/null"
	}

	
	print "Sortie : "  output ", " output2
	print " "

	ecritInfo("Produit;Taille;Couleur;Prix Achat;Prix Vente;Code Complet;Saison")
}


/;COL / {	
	# reinitialisation
	for (i in taille) {
		delete taille[i]
		delete prixAchat[i]
		delete prixVente[i]
	}

	produit = $1
	gsub(/ /, "", produit)
	
	txtTaille = ""
	for (i = 5; i <= NF; i++) {
		gsub(/ /, "", $i)
		if (length($i) > 0) {
			taille[i] = $i
			txtTaille = txtTaille ";" taille[i]
		}
	}
}

/;PA;/ {
	for (i in taille) {
		prixAchat[i] = $i
	}
	saison = $2
	gsub(/ /, "", saison)
	couleur = $3
	gsub(/ /, "", couleur)
}

/;PV;/ {
	# dernières lignes : la saison n'est pas renseignée
	if (saison) {
		for (i in taille) {
			prixVente[i] = $i
			ecritInfo(produit ";" taille[i] ";" couleur ";" prixAchat[i] ";" prixVente[i] ";" produit "|" couleur "|" taille[i] ";" saison)
		}
	}
}
	
function ecritInfo(info) {
	print info
	print info > output
	print info > output2
}

END {
	if (!exitAnalyse) {
		ecritInfo(" ")
		ecritInfo("Source;" input)
		ecritInfo("Sortie;"  output ", " output2)
	}
}