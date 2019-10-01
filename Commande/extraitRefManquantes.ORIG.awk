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
	
	InfoCatalogue[catalogue][tagNbElements]++
	InfoCatalogue[catalogue][tagListePages][page]++
	InfoCatalogue[catalogue][tagListeReferences] = InfoCatalogue[catalogue][tagListeReferences] " " reference
}

END {
	for (catalogue in InfoCatalogue) {
		printf("%s;%d item%s=", catalogue, InfoCatalogue[catalogue][tagNbElements], (InfoCatalogue[catalogue][tagNbElements] > 1 ? "s" : ""))
		
		listePages = ""
		listeProduits = ""

		for (page in InfoCatalogue[catalogue][tagListePages]) {
			listePages = sprintf("%s%s%s", listePages, (listePages == "" ? "" : ","), page)
			printf("%d ", InfoCatalogue[catalogue][tagListePages][page])
		}
		printf(";%s", InfoCatalogue[catalogue][tagListeReferences])
		printf(";%s\n", listePages)
	}
} 