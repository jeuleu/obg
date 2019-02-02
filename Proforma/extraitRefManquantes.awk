BEGIN {
	FS = ";"
	tagNbElements = "nbElements"
	tagListePages = "listePages"
	tagListeReferences = "listeReferences"
}

FILENAME !~ /MANQUANT.csv$/ {
	print " " 
	print "ERREUR : fichier attendu MANQUANT.csv"
	
	exit
}

# catalogue inconnu
$4 ~ "-" {
	catalogue = "Inconnu"
	page = "page inconnue"
}

# catalogue connu
$4 !~ "-" {
	catalogue = $4
	page = 0 + substr($5, 2, 3)
}

{
	reference = $3
	
	informations[catalogue][tagNbElements]++
	informations[catalogue][tagListePages][page]++
	informations[catalogue][tagListeReferences] = informations[catalogue][tagListeReferences] " " reference
}

END {
	print FILENAME
	for (catalogue in informations) {
		printf("%s;%d item%s=", catalogue, informations[catalogue][tagNbElements], (informations[catalogue][tagNbElements] > 1 ? "s" : ""))
		
		listePages = ""
		listeProduits = ""

		for (page in informations[catalogue][tagListePages]) {
			listePages = sprintf("%s%s%s", listePages, (listePages == "" ? "" : ","), page)
			printf("%d ", informations[catalogue][tagListePages][page])
		}
		printf(";%s", informations[catalogue][tagListeReferences])
		printf(";%s\n", listePages)
	}

} 