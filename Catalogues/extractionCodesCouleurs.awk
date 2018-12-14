BEGIN{
#		print "Code couleur;Couleur it;Couleur en;"
}

# Recherche des codes couleur

chercheCol == "en" {
	gsub(/ $/, "", $0)
	couleurEN = $0
	chercheCol = ""
	
	print codeCouleur ";" ";" couleurIT ";" couleurEN ";"
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

