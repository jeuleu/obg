#!/usr/bin/bash

source `dirname $0`/../configAutomatisationFacture.bash_rc

pdfBoxFile=$AUTO_HOME/PDFBox/pdfbox-app-2.0.13.jar
extractAwkFile=$AUTO_HOME/Catalogues/extraitCodesProduits.awk

function usage() 
{
cat << EOF
usage: $0 options <fichier>.pdf

OPTIONS:
   -p      Force l'extraction du fichier 'txt' à partir du fichier PDF.
   -f      Force la regénération des fichiers 'EAN13' et 'COUL' à partir du fichier txt.
   -h      Affiche cette aide.

EOF
}

# options
while getopts "hfp" option
do
	case $option in
		f)
			echo "Regénération des fichiers EAN13"
			FORCE_EAN13=true
			;;

		p)
			echo "Bientôt !"
			echo "Regénération des fichiers TXT depuis PDF"
			FORCE_PDF=true
			;;

		h)
			usage
			exit 0
			;;
    esac
done

# usage
if [[ $# == 0 ]]; then
	usage
fi

function traitePDF_2_TXT()
{
	outputFile="${1%pdf}txt"

	echo -n "  traitePDF_2_TXT   : "
	if [ ! -z "$FORCE_PDF" ] || [[ ! -e $outputFile ]]; then
		echo "'$outputFile'"
		java -jar "$pdfBoxFile" ExtractText "$arg"

		wc "$outputFile"
		echo " "
	else
		echo ">> déja traité '$outputFile'"
		echo " "
	fi
}

function sauveAnciensEAN13()
{
	inputFile="${1%pdf}PRODUIT.csv"
	ean13File="${1%pdf}EAN13.csv"
	
	if [[ -e $inputFile ]]; then
		echo -n "  sauveAnciensEAN13 : "
		echo "'$ean13File'"

		grep "^[38]" "$inputFile" > "$ean13File"

		wc "$ean13File"
		echo " "
	fi
}

function traiteTXT_2_EAN13()
{
	inputFile="${1%pdf}txt"
	outputFile="${1%pdf}PRODUIT.csv"

	echo -n "  traiteTXT_2_EAN13 : "
  	
	if [ ! -z "$FORCE_EAN13" ] || [[ ! -e $outputFile ]]; then
		echo "'$outputFile'"
		awk -f "$extractAwkFile" "$inputFile"

		wc "$outputFile" "${inputFile1%txt}COULEUR.csv"
		echo " "
	else
		echo ">> déja traité '$outputFile'"
		echo " "
	fi
}

function fusionneAvecAnciensEAN13()
{
	inputFile="${1%pdf}PRODUIT.csv"
	ean13File="${1%pdf}EAN13.csv"

	echo -n "  fusionneAvecAnciensEAN13 : "
	echo "'$ean13File'"

	join -t";" -1 2 -2 2 <(sort -t";" -k2 "$inputFile") <(sort -t";" -k2 "$ean13File") -a1 -o 2.1,1.2,1.3,1.4,1.5,1.6,1.7 | sed 's/^;/CodeBarre;/' | sort -t";" -k3 > fichierFusionne.csv

	mv fichierFusionne.csv "$inputFile"

	wc "$inputFile" 
	grep "^[38]" "$inputFile" | wc
	
	echo " "
}


# traitement	
for arg in "$@"; do
	if [[ $arg =~ \.pdf$ ]]; then
		echo "Fichier pdf '$arg'"
	
		traitePDF_2_TXT "$arg"
		
		sauveAnciensEAN13 "$arg"
		
		traiteTXT_2_EAN13 "$arg"
		
		fusionneAvecAnciensEAN13 "$arg"

		echo " "
	fi
done

