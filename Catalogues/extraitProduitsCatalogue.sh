#!/usr/bin/env sh
echo "Exmple d'usage : find . -name \"catalo*txt\" -exec ./extraitProduitsCatalogue.sh {} \;"

echo "Paramètre : $1 "


echo $0
repertoireOrigine=`pwd`

DIRNAME="$( dirname "$1" )"
FNAME="${1##*/}"
fichierSorti=${FNAME/txt/csv}

cd "$DIRNAME"

echo " '$FNAME' >> '$fichierSorti'"
ls -la "$FNAME"
awk -f ../extractionCodesProduits.awk "$FNAME" > "$fichierSorti"
ls -la "$fichierSorti"

cd "$repertoireOrigine"

echo