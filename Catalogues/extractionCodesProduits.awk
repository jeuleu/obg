BEGIN{
}

input != FILENAME {
	input = FILENAME
	
	# fichier sortie
	output = FILENAME
	gsub(/txt$/, "csv", output)

	print "Source : " FILENAME
	print "Sortie : " output
	
	# reinitialisation
	nomCatalogue = ""
	chercheCol = ""
	
	print "Code barre;Catalogue;Page;Libelle produit;Modele;Code piece;Code couleur;Couleur it;Couleur en;" > output
}


# Page paire et nom catalogue
/^0?[0-9]*\. / {
	gsub(/\./, "", $1)
	page = $1
	
	if (nomCatalogue == "") {
		for (i= 2; i <= NF; i++) {
			nomCatalogue = nomCatalogue " " $i
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
	couleurEN = corrigeCouleur($0)
	chercheCol = ""
	
	printf("%s;%s;%d;%s;%s;%03d;%s;%s;\n", "CodeBarre", nomCatalogue, page, libelleProduit, codeProduit, codeCouleur, couleurIT, couleurEN) > output
}

chercheCol == "it" {
	couleurIT = corrigeCouleur($0)
	chercheCol = "en"
}

	
/^col. / {
	codeCouleur = $2
	chercheCol = "it"
}

function corrigeCouleur(ligne) {
	gsub(/ $/, "", ligne)

	gsub(/\222/, "'", ligne)
	gsub(/\371/, "<u>", ligne)
	
	return ligne
}
