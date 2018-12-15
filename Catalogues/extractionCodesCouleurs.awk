BEGIN{
#		print "Code couleur;Couleur it;Couleur en;"
}

# Recherche des codes couleur

chercheCol == "en" {
	couleurEN = corrigeCouleur($0)
	chercheCol = ""
	
	print codeCouleur ";" couleurIT ";" couleurEN ";"
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
