#!/usr/bin/bash

source `dirname $0`/../configAutomatisationFacture.bashrc

pdfBoxFile=$AUTO_HOME/PDFBox/pdfbox-app-2.0.13.jar
extractAwkFile=$AUTO_HOME/Catalogues/extraitCodesProduits.awk

function usage() 
{
cat << EOF
usage: $0 options <fichier>.pdf

OPTIONS:
   -p      Force l'extraction du fichier 'txt' à partir du fichier PDF.
   -f      Force la regénération des fichiers 'PRODUIT' et 'COUL' à partir du fichier txt.
   -n      N'ecrase pas l'ancienne version du fichier 'EAN13'
   -h      Affiche cette aide.

EOF
}

# options
while getopts "hfpn" option
do
	case $option in
		p)
			echo "Regénération des fichiers TXT depuis PDF"
			FORCE_PDF=true
			;;

		f)
			echo "Regénération des fichiers EAN13"
			FORCE_EAN13=true
			;;

		n)
			echo "Ne pas ecraser pas l'ancienne version du fichier EAN13"
			DO_NOT_SAVE_EAN13=true
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
	
	if [ -z "$DO_NOT_SAVE_EAN13" ] && [[ ! -e $inputFile ]]; then
		echo -n "  sauveAnciensEAN13 : "
		echo "'$ean13File'"

		grep "^[38]" "$inputFile" | sort -t";" -k2 -o "$ean13File"

		wc "$ean13File"
		echo " "
	fi
}

function traiteTXT_2_PRODUIT()
{
	inputFile="${1%pdf}txt"
	outputFile="${1%pdf}PRODUIT.csv"

	echo -n "  traiteTXT_2_PRODUIT : "
  	
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

	join -t";" -1 2 -2 2 <(sort -t";" -k2 "$inputFile") <(sort -t";" -k2 "$ean13File") -a1 -o 2.1,1.2,1.3,1.4,1.5,1.6,1.7 | sed 's/^;/CodeBarre;/' | sort -u | sort -t";" -k3 > fichierFusionne.csv

	mv fichierFusionne.csv "$inputFile"

	wc "$inputFile" 
	grep "^[38]" "$inputFile" | wc
	
	echo " "
}

function chercheDoublons()
{
	inputFile="${1%pdf}PRODUIT.csv"
	doublonsFile="${1%pdf}DOUBLONS.csv"
	tmpFile1="doublon1.txt"
	tmpFile2="doublon2.txt"

	if [[ -e "$doublonsFile" ]]; then
		rm "$doublonsFile"
	fi
	
	cut -d ";" -f1 "$inputFile" | grep -v "CodeBarre" | sort -o "$tmpFile1"
	sort -u "$tmpFile1" -o "$tmpFile2"
	diff "$tmpFile2" "$tmpFile1" > "$doublonsFile"
	
	rm "$tmpFile1" "$tmpFile2"
	
	if [[ -s "$doublonsFile" ]]; then
		echo " "
		echo "ATTENTION : Codes doublons"
		
		cat "$doublonsFile"
		echo " "
	fi
}


function chercheAnomalies()
{
	inputFile="${1%pdf}PRODUIT.csv"
	anomaliesFile="${1%pdf}ANOMALIES.csv"

	if [[ -e "$anomaliesFile" ]]; then
		rm "$anomaliesFile"
	fi
	
	# les codes barres ne commençant pas par 3 ou 8
	grep "^[^38C]" "$inputFile" >> "$anomaliesFile"
	
	# les sections nom lues
	grep ";;" "$inputFile" >> "$anomaliesFile"
	
	# les codes produits inexistants nom lues
	grep ";-" "$inputFile" >> "$anomaliesFile"

	if [[ -s "$anomaliesFile" ]]; then
		echo "Anomalies de décodage"
		
		cat "$anomaliesFile"
		echo " "
	fi
}


# traitement	
for arg in "$@"; do
	if [[ $arg =~ \.pdf$ ]]; then
		echo "Fichier pdf '$arg'"
	
		traitePDF_2_TXT "$arg"
		
		sauveAnciensEAN13 "$arg"
		
		traiteTXT_2_PRODUIT "$arg"
		
		fusionneAvecAnciensEAN13 "$arg"
		
		chercheDoublons "$arg"
		chercheAnomalies "$arg"

		echo " "
	fi
done

