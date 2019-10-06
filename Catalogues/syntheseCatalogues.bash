#!/usr/bin/bash

source `dirname $0`/../configAutomatisationFacture.bash_rc


function usage() 
{
cat << EOF
usage: $0 options <fichier>.pdf

OPTIONS:
   -a      Affiche les anomalies de décodage.
   -d      Affiche les doublons de code barre.
   -h      Affiche cette aide.

EOF
}


# options
while getopts "adh" option
do
	case $option in
		a)
			echo "Affiche les anomalies de décodage."
			AFFICHE_ANOMALIES=true
			;;

		d)
			echo "Affiche les doublons de code barre."
			AFFICHE_DOUBLONS=true
			;;

		h)
			usage
			exit 0
			;;
    esac
done


function chercheDoublons()
{
	inputFile="$1"
	doublonsFile="$2"
	tmpFile1="doublon1.txt"
	tmpFile2="doublon2.txt"

	if [[ -e "$doublonsFile" ]]; then
		rm "$doublonsFile"
	fi
	
	cut -d ";" -f1-2,4-5,7 "$inputFile" | grep -v "CodeBarre" | sort -o "$tmpFile1"
	sort -u "$tmpFile1" -o "$tmpFile2"
	diff "$tmpFile2" "$tmpFile1" > "$doublonsFile"
	
	rm "$tmpFile1" "$tmpFile2"
	
	if [ ! -z "$AFFICHE_DOUBLONS" ] && [[ -s "$doublonsFile" ]]; then
		echo " "
		echo "ATTENTION : Codes doublons"
		
		cat "$doublonsFile"
		echo " "
	fi
}



function chercheAnomalies()
{
	inputFile="$1"
	anomaliesFile="$2"

	if [[ -e "$anomaliesFile" ]]; then
		rm "$anomaliesFile"
	fi
	
	# les codes barres ne commençant pas par 3 ou 8
	grep "^[^38C]" "$inputFile" >> "$anomaliesFile"
	
	# les sections nom lues
	grep ";;" "$inputFile" >> "$anomaliesFile"
	
	# les codes produits inexistants nom lues
	grep ";-" "$inputFile" >> "$anomaliesFile"

	if [ ! -z "$AFFICHE_ANOMALIES" ] && [[ -s "$anomaliesFile" ]]; then
		echo "Anomalies de décodage"
		
		cat "$anomaliesFile"
		echo " "
	fi
}



echo "Creation des bases de synthèse"
baseProduit=`dirname $0`"/base.PRODUIT.csv"

echo "Base des produits :"
echo "-------------------"

cat `dirname $0`/*/*.PRODUIT.csv  | grep -v "^XXX" | sort -t";" -k2 -o ${baseProduit}
ls -la ${baseProduit}
wc ${baseProduit}

echo
baseEAN13=`dirname $0`"/base.EAN13.csv"
grep "^[38]" ${baseProduit} | sort -t";" -k2 -o ${baseEAN13}
ls -la ${baseEAN13}
wc ${baseEAN13}

echo
baseEAN13uniq=`dirname $0`"/base.EAN13.uniq.csv"
#cut -d";" -f1-2,4-5,7 "${baseEAN13}" | sort -u > "${baseEAN13uniq}"
cut -d";" -f1,2,4 "${baseEAN13}" | sort -u > "${baseEAN13uniq}"
ls -la ${baseEAN13uniq}
wc ${baseEAN13uniq}

echo
echo
echo "Codes Valmag :"
echo "--------------"

baseValmagEAN13=`dirname $0`"/base.ValmagEAN13.csv"
EXPEAN13=`dirname $0`"/../ValmagEAN13/EXPEAN13.csv"
ls -ls ${EXPEAN13}

join -t";" -a1 -1 1 -2 1 <(sort "$baseEAN13uniq") <(grep "^[38]" "${EXPEAN13}" | sort) -e' ' -o 1.1,1.2,2.3,2.4,2.5 > "$baseValmagEAN13"
ls -la ${baseValmagEAN13}
wc ${baseValmagEAN13}

echo
baseValmagEAN13uniq=`dirname $0`"/base.ValmagEAN13.code.uniq.csv"
cut "${baseValmagEAN13}" -c1-28,33- | cut -d";" -f2-3 | sort -u > "${baseValmagEAN13uniq}"
ls -la ${baseValmagEAN13uniq}
wc ${baseValmagEAN13uniq}


echo
echo
echo "Codes couleur :"
echo "--------------"

baseCOULEUR=`dirname $0`"/base.COULEUR.csv"
cat `dirname $0`/*/*COULEUR.csv | sort | uniq > ${baseCOULEUR}
ls -la ${baseCOULEUR}
wc ${baseCOULEUR}

echo
echo
echo "Contrôles :"
echo "-----------"

baseDOUBLONS=`dirname $0`"/base.DOUBLONS.csv"
chercheDoublons "$baseProduit" "$baseDOUBLONS"
ls -la ${baseDOUBLONS}
wc ${baseDOUBLONS}

echo
baseANOMALIES=`dirname $0`"/base.ANOMALIES.csv"
chercheAnomalies "$baseProduit" "$baseANOMALIES"
ls -la ${baseANOMALIES}
wc ${baseANOMALIES}

