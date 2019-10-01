BEGIN {
	FS = ";"
	tagNbElements = "nbElements"
	tagListePages = "listePages"
	tagListeReferences = "listeReferences"
	
	# commande de traitement des fichiers PDF
	pdfBoxFileCmd = "java -jar " pdfBoxFile
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

function creeBatchExtractionPDF() {
	PDFtoPrint_extract = "PDFtoPrint_extract.bash"

	for (catalogue in InfoCatalogue) {
		#if ( catalogue != "Inconnu") {

			catalogueFilePath = catalogue
			gsub(/.txt$/, ".pdf", catalogueFilePath)
			gsub(/ /, "\\ ", catalogueFilePath)
			
			catalogueOutput = catalogueFilePath
			gsub(/.*catalogo/, "catalogo", catalogueOutput)

			print "#", catalogue ";", InfoCatalogue[catalogue][tagNbElements], "item(s) -> " catalogueOutput> PDFtoPrint_extract

			# extraction des pages désirées
			num = 0
			for (page in InfoCatalogue[catalogue][tagListePages]) {
				num++
				
				print pdfBoxFileCmd " PDFSplit -startPage", (page+2), 
					"-endPage", (page+2), 
					"-outputPrefix PDFextract/extrait" num, 
					"../Catalogues/" catalogueFilePath > PDFtoPrint_extract
			}

			# fusion des pages extraites dans un nouveau fichier unique
			if ( num > 1) {
				print pdfBoxFileCmd " PDFMerger PDFextract/extrait*.pdf PDFextract/" catalogueOutput > PDFtoPrint_extract
				print "rm PDFextract/extrait*.pdf" > PDFtoPrint_extract
			} else {
				print "mv PDFextract/extrait-1.pdf PDFextract/" catalogueOutput > PDFtoPrint_extract
			}
			print "echo; ls -la PDFextract/" catalogueOutput > PDFtoPrint_extract

			# impression du catalogue
			print "\n" pdfBoxFileCmd " PrintPDF PDFextract/" catalogueOutput > PDFtoPrint_extract

			# ouverture du fichier PRODUIT correspondant
			excelFileToOpen = catalogueFilePath
			gsub(/.pdf/, ".PRODUIT.csv", excelFileToOpen);
			print "\nstart excel ../Catalogues/" excelFileToOpen > PDFtoPrint_extract

			print "\n" > PDFtoPrint_extract
		#}
	}
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
	
	# préparation de l'impression des catalogues
	creeBatchExtractionPDF()
} 