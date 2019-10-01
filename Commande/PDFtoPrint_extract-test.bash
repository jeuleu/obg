#!/usr/bin/bash

pdfBoxFileCmd="java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar"


function extractPDFPage()
{
	pdfFile=$1
	pages=$2
	outputPrefix=$3
	
	echo "extractPDFPage $pages"
}

function winter2018presentation_catalogowinter18() {
	java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage 16 -endPage 16 -outputPrefix PDFextract/extrait1 ../Catalogues/winter\ 2018\ presentation/catalogo\ winter\ 18.pdf
	java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage 17 -endPage 17 -outputPrefix PDFextract/extrait2 ../Catalogues/winter\ 2018\ presentation/catalogo\ winter\ 18.pdf
	java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PDFMerger PDFextract/extrait*.pdf PDFextract/catalogo\ winter\ 18.pdf
	rm PDFextract/extrait*.pdf
	echo; ls -la PDFextract/catalogo\ winter\ 18.pdf

echo "Winter"

#	java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PrintPDF PDFextract/catalogo\ winter\ 18.pdf

#	start excel ../Catalogues/winter\ 2018\ presentation/catalogo\ winter\ 18.PRODUIT.csv
}


#function Inconnu() {
#echo "winter"
	# Inconnu; 11 item(s) -> Inconnu
#	java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage 2 -endPage 2 -outputPrefix PDFextract/extrait1 ../Catalogues/Inconnu
#	mv PDFextract/extrait-1.pdf PDFextract/Inconnu
#	echo; ls -la PDFextract/Inconnu

#	java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PrintPDF PDFextract/Inconnu

#	start excel ../Catalogues/Inconnu
#}

echo "Test d'exécution"
#winter2018presentation_catalogowinter18
echo "Fin du test"


pdfFile="winter\ 2018\ presentation/catalogo\ winter\ 18.pdf"
pages="14,15"
outputPrefix="PDFextract/extrait"

extractPDFPage "${pdfFile}" "${pages}" "${outputPrefix}"

