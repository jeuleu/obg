BEGIN {
	FS = ";"
	tagNbElements = "nbElements"
	tagListePages = "listePages"
	tagListeReferences = "listeReferences"

	extractPDFtoPrint = "extractPDFtoPrint.bash"
	gsub(/txt$/, "COULEUR.csv", outputCOULEUR)
	print
	print "Script pour extraire les pages de catalogue    : '" extractPDFtoPrint "'"
	print
	
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


		catalogueFilePath = catalogue
		gsub(/.txt$/, ".pdf", catalogueFilePath)
		gsub(/ /, "\\ ", catalogueFilePath)
		
		catalogueOutput = catalogueFilePath
		gsub(/.*catalogo/, "catalogo", catalogueOutput)

		print "#", catalogue ";", InfoCatalogue[catalogue][tagNbElements], "item(s) -> " catalogueOutput> extractPDFtoPrint

		listePages = ""
		listeProduits = ""

		num = 0
		for (page in InfoCatalogue[catalogue][tagListePages]) {
			listePages = sprintf("%s%s%s", listePages, (listePages == "" ? "" : ","), page)
			printf("%d ", InfoCatalogue[catalogue][tagListePages][page])

			num++
			
			print "java -jar ../PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage", (page+2), 
				"-endPage", (page+2), 
				"-outputPrefix PDFextract/extrait" num, 
				"../Catalogues/" catalogueFilePath > extractPDFtoPrint
		}
		
		printf(";%s", InfoCatalogue[catalogue][tagListeReferences])
		printf(";%s\n", listePages)

		print "" > extractPDFtoPrint
		print "java -jar ../PDFBox/pdfbox-app-2.0.13.jar PDFMerger PDFextract/extrait*.pdf PDFextract/" catalogueOutput > extractPDFtoPrint
		print "rm PDFextract/extrait*.pdf" > extractPDFtoPrint
		print "echo; ls -la PDFextract/" catalogueOutput > extractPDFtoPrint

		print "java -jar ../PDFBox/pdfbox-app-2.0.13.jar PrintPDF PDFextract/" catalogueOutput > extractPDFtoPrint

		print "\n" > extractPDFtoPrint
	}
} 