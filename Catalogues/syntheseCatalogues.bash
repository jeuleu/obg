#!/usr/bin/bash

source `dirname $0`/../configAutomatisationFacture.bash_rc

echo "Creation des bases de synthèse"
baseProduit="base.PRODUIT.csv"
cat */*.PRODUIT.csv  | grep -v "^XXX" | sort -t";" -k2 -o ${baseProduit}
ls -la ${baseProduit}
wc ${baseProduit}

echo ""
baseEAN13="base.EAN13.csv"
grep "^[38]" ${baseProduit} | sort -t";" -k2 -o ${baseEAN13}
ls -la ${baseEAN13}
wc ${baseEAN13}

echo ""
baseCOULEUR="base.COULEUR.csv"
cat */*COULEUR.csv | sort | uniq > ${baseCOULEUR}
ls -la ${baseCOULEUR}
wc ${baseCOULEUR}

