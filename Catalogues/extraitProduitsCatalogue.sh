#!/usr/bin/env sh
echo "Paramètre : $1 "


echo $0
repertoireOrigine=`pwd`

echo "Repoertoire source :  $repertoireOrigine"

DIRNAME="$( dirname "$1" )"
FNAME="${1##*/}"
echo "repe :  $DIRNAME"
echo "fichier :  ${1##*/}"

fichierSorti=${FNAME/txt/csv}
echo "Fichier sorti : $fichierSorti"

echo "On y va !"
cd "$DIRNAME"
pwd


echo
echo 

ls -la "$FNAME"
echo

echo "exécution de l'extraction"
echo "awk -f ../extractionCodesProduits.awk \"$FNAME\" > \"$fichierSorti\""
awk -f ../extractionCodesProduits.awk "$FNAME" > "$fichierSorti"
ls -la "$fichierSorti"

echo "On retourne à la maison"
cd "$repertoireOrigine"
pwd

echo
echo