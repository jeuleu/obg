BEGIN{
}

input != FILENAME {
	print " "

	print "Source : " FILENAME
	input = FILENAME
	nomCatalogue = FILENAME
	
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
	chercheCol = ""
	codeProduit = ""
	numProduitPage = 0
	lignePage = 0

	razTabCouleurEtTaille()
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

# taille de bracelet
$0 ~ "^GENER " || $0 ~ "^gener " || $0 ~ "^SHOES " {
	for (i = 2; i <= NF; i += 2) {
		tabTaille[$i]++
	}
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
	gsub(/‘/, "'", ligne)
	
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


function ecritUnProduitAvecSonCodeComplet(codeComplet, indiceCodeCouleur) {
	printf("CodeBarre;%s;p%03d-%d-%02d;%s;%s;%s;%s\n",
		codeComplet, page, numProduitPage, tabLignePage[indiceCodeCouleur], tabCouleurIT[indiceCodeCouleur], tabCouleurEN[indiceCodeCouleur], nomCatalogue, libelleProduit) > output
}


function ecritLesTaillesDunProduit(code, indiceCodeCouleur) {
	for (taille in tabTaille) {
		if (taille ~ /GENER/ || taille ~ /gener/) {
print "Erreur : taille '" taille "' non generée"
		} else {
			codeComplet = code "-" tabCodeCouleur[indiceCodeCouleur] "-" taille
			ecritUnProduitAvecSonCodeComplet(codeComplet, indiceCodeCouleur)
		}
		
		nbLignesEcrites++
	}

	# Cas ou il n'y a pas de taille
	if (nbLignesEcrites == 0 ) {
		codeComplet = code "-" tabCodeCouleur[indiceCodeCouleur]
		ecritUnProduitAvecSonCodeComplet(codeComplet, indiceCodeCouleur)
	}
}

function ecritInfosDansFichiers(code) {
#print "  >> ecritInfosDansFichiers codeProduit='" codeProduit "', codeProduitPrecedent='" codeProduitPrecedent ""
	# cas d'une page sans code produit
	if (numProduitPage == 0) {
		numProduitPage = 1
	}

	if (page != 0) {
		indiceCodeCouleur = 0
		for (indiceCodeCouleur in tabCodeCouleur) {
			nbLignesEcrites = 0
			
			# Toutes infos
			ecritLesTaillesDunProduit(code, indiceCodeCouleur)

			# Couleurs
			printf("%03d;%s;%s\n", tabCodeCouleur[indiceCodeCouleur], tabCouleurIT[indiceCodeCouleur], tabCouleurEN[indiceCodeCouleur]) > outputCOULEUR
		}

		# Synthese
		if (indiceCodeCouleur > 0) {
			printf("%s   ;page %03d   ;%02d pieces   ;produit n %d\n",
				code, page, indiceCodeCouleur, numProduitPage) > outputSYNTHESE
		}

	} else {
		# cas normal pour le premier appel
		if (nbProblemePage > 0) {
			print "ecritInfosDansFichiers (" NR ") : probleme page n " nbProblemePage " page '" page "', ligne='" $0 "'"
		}
		nbProblemePage++
	}
	
	razTabCouleurEtTaille()
	
	lignePage = 0
	indice = 0
}

function razTabCouleurEtTaille() {
	for (codeCouleur in tabCodeCouleur) {
		# suppression des informations
		delete tabCodeCouleur[codeCouleur]
		delete tabLignePage[codeCouleur]
		delete tabCouleurIT[codeCouleur]
		delete tabCouleurEN[codeCouleur]
	}
	
	#print "RAZ : il y a " length(tabTaille) " taille(s)"
	for (taille in tabTaille) {
		delete tabTaille[taille]
	}
}

END {
	traitementFinDePage()
}