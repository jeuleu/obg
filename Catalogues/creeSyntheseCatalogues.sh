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
fichierCOUL="TousProduits.COUL.csv"
cat */*COUL.csv | sort | uniq > ${fichierCOUL}
ls -la ${fichierCOUL}
wc ${fichierCOUL}

