#!/usr/bin/env sh

echo "Traitement des fichiers de catalogues"
awk -f extractionCodesProduits.awk */*.txt

echo " "
echo " "
echo " "

echo "Creation des fichiers de synthèse"
fichierTousProduits="TousProduits.csv"
cat */*EAN13.csv  | grep -v XXX | sort > ${fichierTousProduits}
ls -la ${fichierTousProduits}
wc ${fichierTousProduits}

echo ""
fichierTrie="TousProduits.triParCodeProduit.csv"
sort -t";" TousProduits.csv -k2  > ${fichierTrie}
ls -la ${fichierTrie}
wc ${fichierTrie}

echo ""
fichierEAN13="TousProduits.EAN13.csv"
grep "^[38]" TousProduits.csv | sort -t";" -k2  > ${fichierEAN13}
ls -la ${fichierEAN13}
wc ${fichierEAN13}

echo ""
fichierCOUL="TousProduits.COUL.csv"
cat */*COUL.csv | sort | uniq > ${fichierCOUL}
ls -la ${fichierCOUL}
wc ${fichierCOUL}

