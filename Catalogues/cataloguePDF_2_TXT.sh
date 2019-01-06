#!/usr/bin/bash

pdfBoxFile=`dirname $0`/../PDFBox/pdfbox-app-2.0.13.jar

echo "pdfBoxFile $pdfBoxFile"
ls -la "$pdfBoxFile"

# contrôle des parametres	
if [[ ! $1 =~ \.pdf$ ]]; then
	echo ""
	echo "Usage: `basename $0` <fichier.pdf>"
	exit
fi

function extraitTexteDuPDF() {
	echo "  Extraction : $1"
	echo "  pour produire : ${1%pdf}txt"
	
}
input=$1
output=${input%pdf}txt
echo "Input  : '$input'"
echo "Output : '$output'"

echo " "
echo "Extraction des informations du fichier pdf"
java -jar "$pdfBoxFile" ExtractText "$1"

ls -la "$input"
ls -la "$output"
