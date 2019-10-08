#!/usr/bin/bash

source `dirname $0`/../configAutomatisationFacture.bashrc


awkFile=`dirname $0`/extractionFacture.awk
tousProduits=`dirname $0`/../Catalogues/TousProduits.csv
tousProduitsEAN13=`dirname $0`/../Catalogues/TousProduits.EAN13.csv
	
# pour permettre les tris	
export LC_ALL='C'

# contrôle des parametres	
if [[ ! $1 =~ \.txt$ ]]; then
	echo ""
	echo "Usage: `basename $0` <xxx.txt>"
	exit
fi

function fusionneFichierEAN13() {
	echo "appel de fusionneFichierEAN13 fic1='$1' fic2='$2'. Résultat '$3'"
	echo " "
	
	join -t";" -1 2 -2 2 <(sort -t";" -k2 "$1") "$2" -a1 -o 1.1,2.1,1.2,1.3,1.4,1.5,1.6,1.7 | sed 's/^;/codeBarre;/' | sort -t";" -k1 > "$3"
}

function fusionneFichierCatalogue() {
	echo "appel de fusionneFichierCatalogue fic1='$1' fic2='$2'. Résultat '$3'"
	echo " "
	
#	join -t";" -1 3 -2 2 <(sort -t";" -k2 "$1") "$2" -a1 -o 1.1,2.3,2.4,1,1.3,1.4,1.5,1.6,1.7,1.8 | sort -t";" -k4 > "$3"
	join -t";" -1 3 -2 2 <(sort -t";" -k3 "$1") <(cat "$2" | grep -v "^codeBarre;;;" | sort -t";" -k2) -a1 -o 1.1,2.3,2.4,1.3,1.4,1.5 | sort -t";" -k2 > "$3"
}


echo " "
echo "Mise à jour du fichier '$1'"
echo

input=$1
output=${input%txt}csv

echo "Input  : '$input'"
echo "Output : '$output'"

echo " "
echo "Extraction des données de la facture"

awk -f "$awkFile" "${input}"

# fusion avec l'ancien EAN13 si nécessaire
fusionneFichierEAN13 "$output" "$tousProduitsEAN13" fichierFusionne.csv

grep "^[0-9]*;;" fichierFusionne.csv > fichierManquantTmp.csv

ls -la "$tousProduits"

fusionneFichierCatalogue fichierManquantTmp.csv "$tousProduits" fichierManquant.csv
	
echo " "
echo "On compte..."
wc "$output" fichierFusionne.csv fichierManquant.csv
