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
	print "    Decodage : '" output "'"
	
	outputCOULEUR = FILENAME
	gsub(/txt$/, "COULEUR.csv", outputCOULEUR)
	print "    Couleurs : '" outputCOULEUR "'"

	outputSYNTHESE = FILENAME
	gsub(/txt$/, "SYNTHESE.csv", outputSYNTHESE)
	print "    Synthese : '" outputSYNTHESE "'"

	# reinitialisation
	nomCatalogue = ""
	chercheCol = ""
	codeProduit = ""
	numProduitPage = 0
	lignePage = 0

	razTabCouleur()
}

function getNumPage() {
	for (i = 1; i <= NF; i++) {
		if ($i ~ "^[0-9][0-9]*\.") {
			gsub(/\./, "", $i)
			return (0 + $i)
		}
	}
}

# Page et nom catalogue
/^[0-9][0-9]*\. / || / [0-9][0-9]*\. ?/ {
#print " >> page paire ou impaire '" $0 "'"
	traitementFinDePage()

	page = getNumPage()
	
	if (nomCatalogue == "") {
		for (i= 2; i <= NF; i++) {
			nomCatalogue = nomCatalogue " " corrigeCaracteresSpeciaux($i)
		}
		gsub(/^ */, "", nomCatalogue)

		print "Catalogue : " nomCatalogue
	}
	
	traitementPostFinDePage()
}


# Code Produit
$0 ~ "^^code " {
	# correction d'un cas où produit et piece sont colles
	if (length($2) >= 13) {
		produit = substr($2, 1, 8)
		piece = substr($2, 9, 5)
	} else {
		produit = $2
		piece = $3
	}
	codeProduit = produit "-" piece
}


# Libelle du produit
/^descrizione/ {
	# plusieurs produits dans la page
#print " >> code '" codeProduit "', numProduitPage=" numProduitPage  ", length(tabCodeCouleur)=" length(tabCodeCouleur), ", $0='" $0 "'"> outputSYNTHESE

	if (length(tabCodeCouleur) > 0 && numProduitPage > 0) {
		ecritInfosDansFichiers(codeProduitPrecedent)
	}
	
	codeProduitPrecedent = codeProduit
	numProduitPage++
	
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

	gsub(/\221|\222/, "'", ligne)
	gsub(/\253|\273/, "\"", ligne)
	gsub(/\223|\224/, "\"", ligne)
	gsub(/\240/, " ", ligne)
	gsub(/\350|\351/, "e", ligne)
	gsub(/\362/, "0", ligne)
	gsub(/\371/, "<u>", ligne)
	gsub(/‘/, "XX", ligne)
	
	gsub(/Î/, "I", ligne)
	gsub(/«/, "\"", ligne)
	
	gsub(/É|Ê|Ë/, "E", ligne)
	
	gsub(/\310|\311/, "E", ligne) # É
	gsub(/\316/, "I", ligne) # Î
	
	gsub(/\214/, "OE", ligne)

	return ligne
}

# Debug
{
#	print "Debug : (" NR ") codeProduit ='" codeProduit "', page='" page "', ligne='" $0 "'"
}

function traitementFinDePage() {

#print "traitementFinDePage codeProduit='" codeProduit "', length(tabCodeCouleur)=" length(tabCodeCouleur) > outputSYNTHESE
	
	if (codeProduit == "") {
		ecritInfosDansFichiers(codeProduitPrecedent)
	} else {
		ecritInfosDansFichiers(codeProduit)
	}
}

function traitementPostFinDePage() {
	# cas de plusieurs pages successives sans code produit
	if (codeProduit != "") {
		codeProduitPrecedent = codeProduit
		codeProduit = ""
	}
	numProduitPage = 0
}

function ecritInfosDansFichiers(code) {
#print "  >> ecritInfosDansFichiers codeProduit='" codeProduit "', codeProduitPrecedent='" codeProduitPrecedent ""
	# cas d'une page sans code produit
	if (numProduitPage == 0) {
		numProduitPage = 1
	}

	if (page != 0) {
		i = 0
		for (i in tabCodeCouleur) {
			# Toutes infos
			printf("CodeBarre;%s-%s;p%03d-%d-%02d;%s;%s;%s;%s\n",
				code, tabCodeCouleur[i], page, numProduitPage, tabLignePage[i], tabCouleurIT[i], tabCouleurEN[i], nomCatalogue, libelleProduit) > output

			# Couleurs
			printf("%03d;%s;%s\n", tabCodeCouleur[i], tabCouleurIT[i], tabCouleurEN[i]) > outputCOULEUR
		}

		# Synthese
		if (i > 0) {
			printf("%s   ;page %03d   ;%02d pieces   ;produit n %d\n",
				code, page, i, numProduitPage) > outputSYNTHESE
		}

	} else {
		# cas normal pour le premier appel
		if (nbProblemePage > 0) {
			print "ecritInfosDansFichiers (" NR ") : probleme page n " nbProblemePage " page '" page "', ligne='" $0 "'"
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