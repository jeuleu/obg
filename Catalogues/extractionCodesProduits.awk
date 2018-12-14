BEGIN{
	print "Catalogue;Page;Libelle produit;Modele;Code piece;Code couleur;Code barre;Couleur it;Couleur en;"
}


# Page paire et nom catalogue
/^0?[0-9]*\. / {
	gsub(/\./, "", $1)
	page = $1
	
	if (nomCatalogue == "") {
		for (i= 2; i <= NF; i++) {
			nomCatalogue = nomCatalogue " " $i
		}
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
	gsub(/ $/, "", $0)
	couleurEN = $0
	chercheCol = ""
	
	print nomCatalogue ";" page ";" libelleProduit ";" codeProduit ";" codeCouleur ";" ";" couleurIT ";" couleurEN ";"
}

chercheCol == "it" {
	gsub(/ $/, "", $0)
	couleurIT = $0
	chercheCol = "en"
}

	
	
/^col. / {
	codeCouleur = $2
	chercheCol = "it"
}

