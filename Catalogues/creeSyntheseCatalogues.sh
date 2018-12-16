#!/usr/bin/env sh

echo "Traitement des fichiers de catalogues"
awk -f extractionCodesProduits.awk */*.txt

echo " "
echo " "
echo " "

echo "Creation des fichiers de synthèse"
fichierEAN13="TousProduits.EAN13.csv"
cat */*EAN13.csv | grep -v CodeBarre | grep -v "Code barre" | grep -v XXX > ${fichierEAN13}
ls -la ${fichierEAN13}
wc ${fichierEAN13}

echo ""
fichierTousProduits="TousProduits.csv"
cat */*EAN13.csv  > ${fichierTousProduits}
ls -la ${fichierTousProduits}
wc ${fichierTousProduits}

echo ""
fichierCOUL="TousProduits.COUL.csv"
cat */*COUL.csv | sort | uniq > ${fichierCOUL}
ls -la ${fichierCOUL}
wc ${fichierCOUL}

