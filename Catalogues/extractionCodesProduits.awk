BEGIN{
}

input != FILENAME {
	print " "

	print "Source : " FILENAME
	input = FILENAME
	
	# fichier sortie
	outputEAN13 = FILENAME
	gsub(/txt$/, "EAN13.csv", outputEAN13)
	print "Sortie : " 
	
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

	
	print "XXX Code barre;Code compact;Catalogue;p000-01;Libelle produit;Modele;Code piece;Code couleur;Couleur it;Couleur en;" > outputEAN13
	print "XXX;;;p000-02" > outputEAN13
	print "XXX;;;p000-03;ATTENTION au format des colonnes !" > outputEAN13
	print "XXX;;;p000-04;Avant toute edition, changer les formats des colonnes suivantes :" > outputEAN13
	print "XXX;;;p000-05;Code Barre :;; numerique sans decimales" > outputEAN13
	print "XXX;;;p000-06;Code Couleur :;; numerique format \"000\"" > outputEAN13
	print "XXX;;;p000-07" > outputEAN13
	
	# reinitialisation
	nomCatalogue = ""
	chercheCol = ""
	codeProduit = ""
	codeProduit2 = ""
	lignePage = 0

	razTabCouleur()
}

# Libellé du produit
/^descrizione/ {
	# plusieurs produits dans la page
	if (length(tabCodeCouleur) > 0 && codeProduitPrecedent != "") {
		codeProduitCourant = codeProduit
		codeProduit2Courant = codeProduit2
		
		codeProduit = codeProduitPrecedent
		codeProduit2 = codeProduit2Precedent
		
		traitementFinDePage()
		
		codeProduit = codeProduitCourant
		codeProduit2 = codeProduit2Courant
	}
	
	libelleProduit = ""
	for (i= 2; i <= NF; i++) {
		libelleProduit = libelleProduit " " corrigeCaracteresSpeciaux($i)
	}
}


# Page paire et nom catalogue
/^[0-9][0-9]*\. / {
#print " >> page impaire '" $0 "'"
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
/ [0-9][0-9]*\. ?/ {
#print " >> page impaire '" $0 "'"
	traitementFinDePage()

	gsub(/\./, "", $NF)
	page = 0+$NF
}


# Code Produit
$0 ~ "code" {
	# sauvegarde codeProduit si changement de code dans la même page
	codeProduitPrecedent = codeProduit
	codeProduit2Precedent = codeProduit2
	
	produit = $2
	piece = $3
	
	if (length($2) >= 13) {
		produit = substr($2, 1, 8)
		piece = substr($2, 9, 5)
	} else {
		produit = $2
		piece = $3
	}
	codeProduit = produit ";" piece
	codeProduit2 = produit "-" piece
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
	tabLignePage[indice] = ++lignePage
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

	return ligne
}

# Debug
{
#	print "Debug : (" NR ") codeProduit ='" codeProduit "', page='" page "', ligne='" $0 "'"
}


function traitementFinDePage() {
	if (page != 0) {
		for (i in tabCodeCouleur) {
			# Toutes infos
			printf("%s;%s-%s;%s;p%03d-%02d;%s;%s;%s;%s;%s\n", "CodeBarre", 
				codeProduit2, tabCodeCouleur[i], nomCatalogue, page, tabLignePage[i], libelleProduit, codeProduit, tabCodeCouleur[i], tabCouleurIT[i], tabCouleurEN[i]) > outputEAN13

			# Couleurs
			printf("%03d;%s;%s;\n", tabCodeCouleur[i], tabCouleurIT[i], tabCouleurEN[i]) > outputCOUL
		}
	} else {
		# cas normal pour le premier appel
		if (nbProblemePage > 0) {
			print "traitementFinDePage (" NR ") : probleme page n°" nbProblemePage " page '" page "', ligne='" $0 "'"
		}
		nbProblemePage++
	}
	
	razTabCouleur()
	
	lignePage = 0
	indice = 0
}

function razTabCouleur() {
	for (i in tabCodeCouleur) {
		# suppression des informations
		delete tabCodeCouleur[i]
		delete tabLignePage[i]
		delete tabCouleurIT[i]
		delete tabCouleurEN[i]
	}
}

END {
	traitementFinDePage()
}