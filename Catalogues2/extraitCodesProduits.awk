BEGIN{
}

input != FILENAME {
	print " "

	print "Source : " FILENAME
	input = FILENAME
	
	# fichiers de sortie
	print "Sortie : " 
	output = FILENAME
	gsub(/txt$/, "PRODUIT.csv", output)	
	print "    Décodage : '" output "'"
	
	outputCOULEUR = FILENAME
	gsub(/txt$/, "COULEUR.csv", outputCOULEUR)
	print "    Couleurs : '" outputCOULEUR "'"

	outputSYNTHESE = FILENAME
	gsub(/txt$/, "SYNTHESE.csv", outputSYNTHESE)
	print "    Synthèse : '" outputSYNTHESE "'"

	# reinitialisation
	nomCatalogue = ""
	chercheCol = ""
	codeProduit = ""
	produitPage = 0
	lignePage = 0

	razTabCouleur()
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
		gsub(/^ */, "", nomCatalogue)

		print "Catalogue : " nomCatalogue
	}
	
	# Test
	codeProduitPrecedent = codeProduit
	codeProduit = ""
}


# Page impaire
/ [0-9][0-9]*\. ?/ {
#print " >> page impaire '" $0 "'"
	traitementFinDePage()

	gsub(/\./, "", $NF)
	page = 0+$NF
	
	# Test
	codeProduitPrecedent = codeProduit
	codeProduit = ""
}


# Code Produit
$0 ~ "code" {
	# correction d'un cas où produit et piece sont collés
	if (length($2) >= 13) {
		produit = substr($2, 1, 8)
		piece = substr($2, 9, 5)
	} else {
		produit = $2
		piece = $3
	}
	produitPage++
	codeProduit = produit "-" piece
}


# Libellé du produit
/^descrizione/ {
	# plusieurs produits dans la page
print "traitement nouveau produit page " page " : codeProduit='" codeProduit "', codeProduitPrecedent='" codeProduitPrecedent "' "
	if (length(tabCodeCouleur) > 0) {

		codeProduitTmp = codeProduit
		codeProduit = codeProduitPrecedent
		
		traitementFinDePage()
		
		codeProduit = codeProduitTmp
	}
	
	codeProduitPrecedent = codeProduit
	
	libelleProduit = ""
	for (i= 2; i <= NF; i++) {
		libelleProduit = libelleProduit " " corrigeCaracteresSpeciaux($i)
	}
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
	# cas d'une page sans code produit
	if (codeProduit == "") {
		codeProduit = codeProduitPrecedent
	}
	
	if (page != 0) {
		for (i in tabCodeCouleur) {
			# Toutes infos
			printf("CodeBarre;%s-%s;p%03d-%d-%02d;%s;%s;%s;%s\n",
				codeProduit, tabCodeCouleur[i], page, produitPage, tabLignePage[i], tabCouleurIT[i], tabCouleurEN[i], nomCatalogue, libelleProduit) > output

			# Couleurs
			printf("%03d;%s;%s\n", tabCodeCouleur[i], tabCouleurIT[i], tabCouleurEN[i]) > outputCOULEUR
		}

		# Synthèse
		printf("%s;p%03d;%02d items\n",
			codeProduit, page, i) > outputSYNTHESE

	} else {
		# cas normal pour le premier appel
		if (nbProblemePage > 0) {
			print "traitementFinDePage (" NR ") : probleme page n°" nbProblemePage " page '" page "', ligne='" $0 "'"
		}
		nbProblemePage++
	}
	
	razTabCouleur()
	
	produitPage = 0
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