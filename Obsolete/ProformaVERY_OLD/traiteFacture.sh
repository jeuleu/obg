#!/usr/bin/env sh

input="FAT_traitee.csv"
output="FAT_tmp.csv"
echo "Traitement de FAT"
echo "input : " $input
echo "output : " $output
sort $input -t";" -k2 -o $output

join $output ../Catalogues/TousProduits.EAN13.csv -t";" -a1 -12 -22 -e'CodeBarre' -o 1.1,2.1,1.2,1.3,1.4,1.5,1.6,1.7 | sort -t";" > result.csv

join $output ../Catalogues/TousProduits.triParCodeProduit.csv -t";" -a1 -12 -22 -e'CodeBarre' -o 1.1,2.1,2.3,2.4,1.2,1.3,1.4 | sort -t";" -k3 > resultManquant.csv