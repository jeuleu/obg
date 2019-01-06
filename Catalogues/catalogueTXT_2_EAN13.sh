#!/usr/bin/bash

awkFile=`dirname $0`/extractionCodesProduits.awk
	
# contrôle des parametres	
if [[ ! $1 =~ \.txt$ ]]; then
	echo ""
	echo "Usage: `basename $0` <catalogo_xxx.txt>"
	exit
fi

function fusionneFichierEAN13() {
	join -t";" -1 2 -2 2 <(sort -t";" -k2 "$1") "$2" -a1 -o 2.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10 | sed 's/^;/codeBarre;/' | sort -t";" -k4 > fichierFusionne.csv
	mv fichierFusionne.csv "$1"
}


echo " "
echo "Mise à jour du fichier '$1'"
echo

input=$1
output=${input%txt}EAN13.csv
anciensCodesEAN13=${output%csv}OLD.csv

echo "Input  : '$input'"
echo "Output : '$output'"

# stockage de l'ancien fichier EAN13
if [[ -e $output ]]
then
	echo " "
	echo "Fichier '$output' renommé en '$ancienCatalogue'"

	grep "^8" "$output" | sort -t";" -k2  > "$anciensCodesEAN13" 
fi

echo " "
echo "extraction des données du catalogue"

awk -f "$awkFile" "${input}"

echo " "
echo "Copie de sauvegarde du fichier extrait '$output' (EXTRACT)"
cp "${output}" "${output%csv}EXTRACT.csv"

ls -ls "$input" "$output" "$ancienCatalogue"
echo " "

# fusion avec l'ancien EAN13 si nécessaire
if [[ -e $anciensCodesEAN13 ]]
then
	echo " "
	echo "Fusion avec l'ancien fichier EAN13 '$ancienCatalogue' "

	fusionneFichierEAN13 "$output" "$ancienCatalogue"
	
	echo " "
	echo "On compte..."
	wc "$output" "$ancienCatalogue"
fi
