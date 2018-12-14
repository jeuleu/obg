BEGIN{
}

chercheCol == "en" {
	gsub(/ $/, "", $0)
	couleurEN = $0
	chercheCol = ""
	
	print codeCouleur     ";"      couleurIT ";" couleurEN ";"
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

