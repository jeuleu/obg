#!/usr/bin/env sh

echo "Transformation des fichiers PDF en TXT"
for pdfFile in */*.pdf; do
	txtFile=${pdfFile%pdf}txt
	if [[ -e $txtFile ]]; then
		echo "  Non traité car fichier txt existe : '$pdfFile'"
	else
		echo "  >> $pdfFile"
		./cataloguePDF_2_TXT.sh "$pdfFile"
	fi
done

echo " "
echo " "
echo " "
echo "Extraction des codes produits"
awk -f extractionCodesProduits.awk */*.txt

echo " "
echo " "
echo " "

echo "Creation des fichiers de synthèse"
fichierTousProduits="TousProduits.csv"
cat */*EAN13.csv  | grep -v "^XXX" | sort -o ${fichierTousProduits}
ls -la ${fichierTousProduits}
wc ${fichierTousProduits}

echo ""
fichierTrie="TousProduits.triParCodeProduit.csv"
sort -t";" TousProduits.csv -k2 -o ${fichierTrie}
ls -la ${fichierTrie}
wc ${fichierTrie}

echo ""
fichierEAN13="TousProduits.EAN13.csv"
grep "^[38]" TousProduits.csv | sort -t";" -k2 -o ${fichierEAN13}
ls -la ${fichierEAN13}
wc ${fichierEAN13}

echo ""
fichierCOUL="TousProduits.COUL.csv"
cat */*COUL.csv | sort | uniq > ${fichierCOUL}
ls -la ${fichierCOUL}
wc ${fichierCOUL}

