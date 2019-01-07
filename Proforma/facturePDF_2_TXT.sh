#!/usr/bin/bash

pdfBoxFile=`dirname $0`/../PDFBox/pdfbox-app-2.0.13.jar

echo "pdfBoxFile $pdfBoxFile"
ls -la "$pdfBoxFile"
echo " "

# contrôle des parametres	
if [[ ! $1 =~ \.PDF$ ]]; then
	echo ""
	echo "Usage: `basename $0` <fichier.PDF>"
	echo "'$1'"
	exit
fi


for file in "$@"; do
	echo "Fichier '$file'"
	
	if [[ $file =~ \.PDF$ ]]; then
		txtFile=${file%PDF}txt
		
		if [[ -e $txtFile ]]; then
			echo "  fichier non traité (fichier txt existe) : '$txtFile'"
		else
			echo "Extraction des informations du fichier '$file'"
			java -jar "$pdfBoxFile" ExtractText "$file"
			ls -la "$txtFile"
			echo " "
		fi
	else
		echo "  Fichier ignoré (pas PDF) : $file"

	fi
done
