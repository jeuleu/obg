#!/usr/bin/bash

source `dirname $0`/../configAutomatisationFacture.bash_rc

pdfBoxFile=$AUTO_HOME/PDFBox/pdfbox-app-2.0.13.jar
extractAwkFile=$AUTO_HOME/Proforma/extraitFacture.awk

function usage() 
{
cat << EOF
usage: $0 options <fichier>.pdf

OPTIONS:
   -p      Force l'extraction du fichier 'txt' à partir du fichier PDF.
   -f      Force la regénération du fichier 'CSV' à partir du fichier txt.
   -h      Affiche cette aide.

EOF
}

# options
while getopts "hfp" option
do
	case $option in
		f)
			echo "Regénération des fichiers CSV"
			FORCE_CSV=true
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
	outputFile="${1%PDF}txt"

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

function traiteTXT_2_CSV()
{
	inputFile="${1%PDF}txt"
	outputFile="${1%PDF}csv"

	echo -n "  traiteTXT_2_CSV : "
  	
	if [ ! -z "$FORCE_CSV" ] || [[ ! -e $outputFile ]]; then
		echo "'$outputFile'"
		awk -f "$extractAwkFile" "$inputFile"

		wc "$outputFile"
		echo " "
	else
		echo ">> déja traité '$outputFile'"
		echo " "
	fi
}

function fusionneAvecBasesProduit()
{
#input="FAT_traitee.csv"
#output="FAT_tmp.csv"
#echo "Traitement de FAT"
#echo "input : " $input
#echo "output : " $output
#sort $input -t";" -k2 -o $output

#join $output ../Catalogues/TousProduits.EAN13.csv -t";" -a1 -12 -22 -e'CodeBarre' -o 1.1,2.1,1.2,1.3,1.4,1.5,1.6,1.7 | sort -t";" > result.csv

#join $output ../Catalogues/TousProduits.triParCodeProduit.csv -t";" -a1 -12 -22 -e'CodeBarre' -o 1.1,2.1,2.3,2.4,1.2,1.3,1.4 | sort -t";" -k3 > resultManquant.csv#	inputFile="${1%pdf}PRODUIT.csv"

	inputFile="${1%PDF}csv"
	ean13File="${1%PDF}EAN13.csv"
	manquantFile="${1%PDF}MANQUANT.csv"
	
	baseEAN13="$AUTO_HOME/Catalogues/base.EAN13.csv"
	basePRODUIT="$AUTO_HOME/Catalogues/base.PRODUIT.csv"

	echo -n "  fusionneAvecBasesProduit : "
	echo "'$inputFile'"
	echo "Base '$baseEAN13'"

	echo " "
	ls -la "$baseEAN13"
	ls -la "$basePRODUIT"
	echo " "
	
	join -t";" -a1 -1 2 -2 2 <(sort -t";" -k2 "$inputFile") <(sort -t";" -k2 "$baseEAN13") -e'CodeBarre' -o 1.1,2.1,1.2,1.3,1.4,1.5,1.6,1.7 | sort -t";" -o "$ean13File"

	join -t";" -a1 -1 3 -2 2 <(grep -v "^ " "$ean13File" | grep ";CodeBarre;" | sort -t";" -k2) <(sort -t";" -k2 "$basePRODUIT") -e'CodeBarre' -o 1.1,2.2,2.6,2.3,1.3,1.4,1.5 | sort -t";" -k3 -o "$manquantFile"

#	join -t";" -1 2 -2 2 <(grep -v "^ " "$ean13File" | grep ";CodeBarre;" | sort -t";" -k2) <(sort -t";" -k2 "$basePRODUIT") -a1 -o 1.1,2.3,2.4,1.3,1.4,1.5 | sort -t";" -o "$manquantFile"
	#join -t";" -1 3 -2 2 <(sort -t";" -k3 "$1") <(cat "$2" | grep -v "^codeBarre;;;" | sort -t";" -k2) -a2 -o 1.1,2.3,2.4,1.3,1.4,1.5 | sort -t";" -k2 > "$3"


	echo " "
	echo "Fichier des codes EAN13"
	ls -la "$ean13File"
	wc "$ean13File" 
	
	echo " "
	echo "Fichier des codes produits manquants"
	ls -la "$manquantFile"
	wc "$manquantFile" 
	
#	cat "$manquantFile"
	
	echo " "
}


# traitement	
for arg in "$@"; do
	if [[ $arg =~ \.PDF$ ]]; then
		echo "Fichier pdf '$arg'"
	
		traitePDF_2_TXT "$arg"
		
		traiteTXT_2_CSV "$arg"
		
		fusionneAvecBasesProduit "$arg"
		echo " "
	fi
done

