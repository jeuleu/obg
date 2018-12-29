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

	
	print "XXXCode barre;Code compact;Catalogue;Page;Libelle produit;Modele;Code piece;Code couleur;Couleur it;Couleur en;" > outputEAN13
	print "XXX" > outputEAN13
	print "XXX;ATTENTION au format des colonnes !" > outputEAN13
	print "XXX;Avant toute edition, changer les formats des colonnes suivantes :" > outputEAN13
	print "XXX;Code Barre :;; numerique sans decimales" > outputEAN13
	print "XXX;Code Couleur :;; numerique format \"000\"" > outputEAN13
	print "XXX" > outputEAN13
	
	# reinitialisation
	nomCatalogue = ""
	chercheCol = ""
	codeProduit = ""
	codeProduit2 = ""

	razTabCouleur()
}

# Libellé du produit
/^descrizione/ {
	libelleProduit = ""
	for (i= 2; i <= NF; i++) {
		libelleProduit = libelleProduit " " corrigeCaracteresSpeciaux($i)
	}
}


# Page paire et nom catalogue
/^0?[0-9]*\. / {

	traitementFinDePage()

	gsub(/\./, "", $1)
	page = 0+$1
	
	if (nomCatalogue == "") {
		for (i= 2; i <= NF; i++) {
			nomCatalogue = nomCatalogue " " corrigeCaracteresSpeciaux($i)
		}
		

		print "Catalogue : " nomCatalogue
	}
}


# Page impaire
/ [0-9]*\. / {

	traitementFinDePage()

	gsub(/\./, "", $NF)
	page = 0+$NF
}


# Code Produit
$0 ~ "code" {
	codeProduit = $2 ";" $3
	codeProduit2 = $2 "-" $3
}

# Recherche des codes couleur

chercheCol == "en" {
	tabCouleurEN[indice] = corrigeCaracteresSpeciaux($0)
	chercheCol = ""
}

chercheCol == "it" {
	tabCouleurIT[indice] = corrigeCaracteresSpeciaux($0)
	chercheCol = "en"
}

/^col. / {
	indice++
	
	tabCodeCouleur[indice] = sprintf("%03d", $2)
	chercheCol = "it"
}

function corrigeCaracteresSpeciaux(ligne) {
	gsub(/ $/, "", ligne)

	gsub(/\221/, "'", ligne)
	gsub(/\222/, "'", ligne)
	gsub(/\223/, "\"", ligne)
	gsub(/\224/, "\"", ligne)
	gsub(/\240/, " ", ligne)
	gsub(/\350/, "e", ligne)
	gsub(/\351/, "e", ligne)
	gsub(/\362/, "0", ligne)
	gsub(/\371/, "<u>", ligne)
	gsub(/‘/, "XX", ligne)
	
	return ligne
}


function traitementFinDePage() {
	if (page != 0) {
		for (i in tabCodeCouleur) {
			# Toutes infos
			printf("%s;%s-%s;%s;%d;%s;%s;%s;%s;%s\n", "CodeBarre", 
				codeProduit2, tabCodeCouleur[i], nomCatalogue, page, libelleProduit, codeProduit, tabCodeCouleur[i], tabCouleurIT[i], tabCouleurEN[i]) > outputEAN13

			# Couleurs
			printf("%03d;%s;%s;\n", tabCodeCouleur[i], tabCouleurIT[i], tabCouleurEN[i]) > outputCOUL
		}
	} else {
		print "traitementFinDePage : probleme page '" page "'"
	}
	
	razTabCouleur()
	
	indice = 0
}

function razTabCouleur() {
	for (i in tabCodeCouleur) {
		# suppression des informations
		delete tabCodeCouleur[i]
		delete tabCouleurIT[i]
		delete tabCouleurEN[i]
	}
}

END {
	traitementFinDePage()
}