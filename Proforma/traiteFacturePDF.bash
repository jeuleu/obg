#!/usr/bin/bash

source `dirname $0`/../configAutomatisationFacture.bash_rc

pdfBoxFile=$AUTO_HOME/PDFBox/pdfbox-app-2.0.13.jar
extractAwkFile=$AUTO_HOME/Proforma/extraitFacture.awk
ean13GlobalFile="`dirname $0`/EAN13_traite.csv"

echo " EAN '$ean13GlobalFile'"
echo " "

function usage() 
{
cat << EOF
usage: $0 options <fichier>.pdf

OPTIONS:
   -p      Force l'extraction du fichier 'txt' à partir du fichier PDF.
   -f      Force la regénération du fichier 'CSV' à partir du fichier txt.
   -c	   Recalcule la synthèse des catalogues. Nécessaire après une nouvelle saisie de codes barres
   -h      Affiche cette aide.

EOF
}

# options
while getopts "hfpc" option
do
	case $option in
		h)
			usage
			exit 0
			;;
		f)
			echo "Regénération des fichiers CSV"
			FORCE_CSV=true
			;;

		p)
			echo "Bientôt !"
			echo "Regénération des fichiers TXT depuis PDF"
			FORCE_PDF=true
			;;

		c)
			echo "Regénération de la synthèse des catalogues"
			cmdSyntheseCatalogue="$AUTO_HOME/Catalogues/syntheseCatalogues.bash"
			echo "Commande : $cmdSyntheseCatalogue"
			eval "$cmdSyntheseCatalogue"
			
			echo " "
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

function traiteTXT_2_CSV()
{
	inputFile="${1%pdf}txt"
	outputFile="${1%pdf}csv"

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
	inputFile="${1%pdf}csv"
	ean13File="${1%pdf}EAN13.csv"
	manquantFile="${1%pdf}MANQUANT.csv"
	
	baseEAN13="$AUTO_HOME/Catalogues/base.EAN13.csv"
	basePRODUIT="$AUTO_HOME/Catalogues/base.PRODUIT.csv"

	echo -n "  fusionneAvecBasesProduit : "
	echo "'$inputFile'"
	echo "Base '$baseEAN13'"

	echo " "
	ls -la "$baseEAN13"
	ls -la "$basePRODUIT"
	echo " "

	
	# jointure des codes barre
	join -t";" -a1 -1 3 -2 2 <(grep -v "^ " "$inputFile" | sort -t";" -k3) <(sort -t";" -k2 "$baseEAN13") -e'CodeBarre' -o 1.1,1.2,2.1,1.3,1.4,1.5,1.6,1.7,1.8 | sort -t";" -o "$ean13File"

	# recherche des produits manquants
	join -t";" -a1 -1 4 -2 2 <(grep -v "^ " "$ean13File" | grep ";CodeBarre;" | sort -t";" -k3) <(sort -t";" -k2 "$basePRODUIT") -e'-' -o 1.1,1.2,1.4,2.6,2.3,1.5,1.6 | sort -t";" -k4 -o "$manquantFile"

	echo " "
	echo "Fichier des codes EAN13"
	ls -la "$ean13File"
	wc "$ean13File" 
	
	echo " "
	echo "Fichier des codes produits manquants"
	ls -la "$manquantFile"
	wc "$manquantFile" 
	
	# constitution d'un fichier de synthèse 
	echo "ENTETE" >> "$ean13GlobalFile"
	grep "^ " "$inputFile" >> "$ean13GlobalFile"

	echo "EAN13" >> "$ean13GlobalFile"
	cat "$ean13File" >> "$ean13GlobalFile"

	echo "MANQUANT" >> "$ean13GlobalFile"
	cat "$manquantFile" >> "$ean13GlobalFile"
	
	echo "" >> "$ean13GlobalFile"

	#	cat "$manquantFile"
	
	echo " "
}

# nettoyage
if [ -f "$ean13GlobalFile" ]; then
	echo "Suppression '$ean13GlobalFile'"
	rm "$ean13GlobalFile"
else
	echo "Fichier '$ean13GlobalFile' inexistant"
fi

# traitement	
for arg in "$@"; do
	# PDF -> pdf
	if [[ $arg =~ \.PDF$ ]]; then
		echo -n "Renommage du fichier '" $arg "' en "
		mv "$arg" "${arg%PDF}pdf"
		arg="${arg%PDF}pdf"
		echo "'" $arg "'"
		echo " "
	fi

	# traitement d'un fichier PDF
	if [[ $arg =~ \.pdf$ ]]; then
		echo "Fichier pdf '$arg'"
	
		traitePDF_2_TXT "$arg"
		
		traiteTXT_2_CSV "$arg"
		
		fusionneAvecBasesProduit "$arg"
		echo " "
	fi
done

