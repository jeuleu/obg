BEGIN{
}


/^0?[0-9]*\. / {
	gsub(/\./, "", $1)
	page = $1
}

/ [0-9]*\. / {
	gsub(/\./, "", $NF)
	page = $NF
}


$0 ~ "code" {
	codeProduit = $2 ";" $3
}

# Recherche des codes couleur

chercheCol == "en" {
	gsub(/ $/, "", $0)
	couleurEN = $0
	chercheCol = ""
	
	print page ";" codeProduit ";" codeCouleur     ";"      couleurIT ";" couleurEN ";"
}

chercheCol == "it" {
	gsub(/ $/, "", $0)
	couleurIT = $0
	chercheCol = "en"
}

	
$0 ~ "col. " {
	codeCouleur = $2
	chercheCol = "it"
}

