BEGIN{
}

input != FILENAME {
	print " "

	print "Source : " FILENAME
	input = FILENAME
	
	# fichier sortie
	outputEAN13 = FILENAME
	gsub(/txt$/, "EAN13.csv", outputEAN13)
	print "Sortie : " outputEAN13
	
	nomFichier = outputEAN13
	gsub(/ /, "\\ ", nomFichier)
	if (system("test -f " nomFichier) == 0) {
		print "    !! Fichier existant : '" outputEAN13 "'"
		outputEAN13 = "/tmp/null"
	} else {
		print "    EAN13 : '" outputEAN13 "'"
	}

	outputCOUL = FILENAME
	gsub(/txt$/, "COUL.csv", outputCOUL)
	print "    Couleurs : " outputCOUL

	
	print "Code barre;Catalogue;Page;Libelle produit;Modele;Code piece;Code couleur;Couleur it;Couleur en;" > outputEAN13
	print "XXX" > outputEAN13
	print "XXX;ATTENTION au format des colonnes !" > outputEAN13
	print "XXX;Avant toute edition, changer les formats des colonnes suivantes :" > outputEAN13
	print "XXX;Code Barre :;; numerique sans decimales" > outputEAN13
	print "XXX;Code Couleur :;; numerique format \"000\"" > outputEAN13
	print "XXX" > outputEAN13
	
	# reinitialisation
	nomCatalogue = ""
	chercheCol = ""

}


# Page paire et nom catalogue
/^0?[0-9]*\. / {
	gsub(/\./, "", $1)
	page = $1
	
	if (nomCatalogue == "") {
		for (i= 2; i <= NF; i++) {
			nomCatalogue = nomCatalogue " " corrigeCaracteresSpeciaux($i)
		}
		

		print "Catalogue : " nomCatalogue
	}
}


# Libellé du produit
/^descrizione/ {
	libelleProduit = ""
	for (i= 2; i <= NF; i++) {
		libelleProduit = libelleProduit " " $i
	}
}

# Page impaire
/ [0-9]*\. / {
	gsub(/\./, "", $NF)
	page = $NF
}


# Code Produit
$0 ~ "code" {
	codeProduit = $2 ";" $3
}

# Recherche des codes couleur

chercheCol == "en" {
	couleurEN = corrigeCaracteresSpeciaux($0)
	chercheCol = ""
	
	# Toutes infos
	printf("%s;%s;%d;%s;%s;%03d;%s;%s;\n", "CodeBarre", nomCatalogue, page, libelleProduit, codeProduit, codeCouleur, couleurIT, couleurEN) > outputEAN13

	# Couleurs
	printf("%03d;%s;%s;\n", codeCouleur, couleurIT, couleurEN) > outputCOUL
}

chercheCol == "it" {
	couleurIT = corrigeCaracteresSpeciaux($0)
	chercheCol = "en"
}

	
/^col. / {
	codeCouleur = $2
	chercheCol = "it"
}

function corrigeCaracteresSpeciaux(ligne) {
	gsub(/ $/, "", ligne)

	gsub(/\222/, "'", ligne)
	gsub(/\371/, "<u>", ligne)
	gsub(/‘/, "XX", ligne)
	
	return ligne
}
