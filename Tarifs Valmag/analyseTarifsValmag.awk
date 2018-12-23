BEGIN {
	FS = ";"
	print "Extraction : " FILENAME

	#verbose = "vrai"
}	


input != FILENAME {
	print " "

	input = FILENAME
	print "Source : " input
		
	# fichier sortie
	output = FILENAME
	gsub(/EDITARSTO_.*_/, "tarifValmag_", output)

	nomFichier = output
	gsub(/ /, "\\ ", nomFichier)
	if (system("test -f " nomFichier) == 0) {
		print "    !! Fichier existant : '" output "'"
		output = "/tmp/null"
	}

	output2 = "tarifValmag.csv"
	
	print "Sortie : "  output ", " output2
	print " "

	print "Produit;Taille;Prix Achat;Prix Vente		" > output
}


/^   / && etat == "lecturePrixVente" {
	for (i in couleur) {
		prixVente[i] = $i

		ecritInfo(produit ";" couleur[i] ";" prixAchat[i] ";" prixVente[i])
	}
	
	etat = "attenteCouleur"
}
	
/^   / && etat == "lecturePrixAchat" {
	for (i in couleur) {
		prixAchat[i] = $i
	}
	
	etat = "lecturePrixVente"
}

/;COL / {	
	# reinitialisation
	for (i in couleur) {
		delete couleur[i]
		delete prixAchat[i]
		delete prixVente[i]
	}

	produit = $1
	gsub(/ /, "", produit)
	
	txtCouleur = ""
	for (i = 5; i <= NF; i++) {
		gsub(/ /, "", $i)
		if (length($i) > 0) {
			couleur[i] = $i
			txtCouleur = txtCouleur ";" couleur[i]
		}
	}
	
	print produit txtCouleur	
	
	etat = "lecturePrixAchat"
}

function ecritInfo(info) {
	print info
	print info > output
	print info > output2
}

END {
	ecritInfo(" ")
	ecritInfo("Source : " input)
	ecritInfo("Sortie : "  output ", " output2)
}