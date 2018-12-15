BEGIN{
}

input != FILENAME {
	print " "

	print "Source : " FILENAME
	input = FILENAME
	
	# fichier sortie
	output = FILENAME
	gsub(/txt$/, "csv", output)
	print "Sortie : " output

	outputCouleur = FILENAME
	gsub(/txt$/, "couleur.txt", outputCouleur)
	print "Couleurs : " outputCouleur

	print "Code barre;Catalogue;Page;Libelle produit;Modele;Code piece;Code couleur;Couleur it;Couleur en;" > output
	
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
			nomCatalogue = nomCatalogue " " $i
		}
		
		nomCatalogue = corrigeCaracteresSpeciaux(nomCatalogue)

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
	
	printf("%s;%s;%d;%s;%s;%03d;%s;%s;\n", "CodeBarre", nomCatalogue, page, libelleProduit, codeProduit, codeCouleur, couleurIT, couleurEN) > output
	printf("%03d;%s;%s;\n", codeCouleur, couleurIT, couleurEN) > outputCouleur
	printf("%03d;%s;%s;\n", codeCouleur, couleurIT, couleurEN) > "ToutesCouleurs.txt"
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
