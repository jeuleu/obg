#!/usr/bin/env sh

echo "Traitement des fichiers de catalogues"
awk -f extractionCodesProduits.awk */catalogo*.txt

echo " "
echo " "
echo " "

echo "Creation des fichiers de synthèse"
fichierEAN13="TousProduits.EAN13.csv"
cat */*EAN13.csv | grep -v CodeBarre | grep -v XXX > ${fichierEAN13}
ls -la ${fichierEAN13}
wc ${fichierEAN13}

echo ""
fichierEAN13_inconnus="TousProduits.EAN13.inconnus.csv"
cat */*EAN13.csv | grep CodeBarre > ${fichierEAN13_inconnus}
ls -la ${fichierEAN13_inconnus}
wc ${fichierEAN13_inconnus}

echo ""
fichierCOUL="TousProduits.COUL.csv"
cat */*COUL.csv | sort | uniq > ${fichierCOUL}
ls -la ${fichierCOUL}
wc ${fichierCOUL}

