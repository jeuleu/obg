#!/usr/bin/bash

source `dirname $0`/../configAutomatisationFacture.bash_rc


function usage() 
{
cat << EOF
usage: $0 options <fichier>.pdf

OPTIONS:
   -v      Verbeux : affiche les anomalies de décodage.
   -f      Force la regénération des fichiers 'EAN13' et 'COUL' à partir du fichier txt.
   -h      Affiche cette aide.

EOF
}


# options
while getopts "vh" option
do
	case $option in
		v)
			echo "Verbeux : affiche les anomalies de décodage."
			VERBOSE=true
			;;

		h)
			usage
			exit 0
			;;
    esac
done


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

	if [ ! -z "$VERBOSE" ] && [[ -s "$anomaliesFile" ]]; then
		echo "Anomalies de décodage"
		
		cat "$anomaliesFile"
		echo " "
	fi
}



echo "Creation des bases de synthèse"
baseProduit=`dirname $0`"/base.PRODUIT.csv"

echo "Fichier : '$baseProduit'"

cat `dirname $0`/*/*.PRODUIT.csv  | grep -v "^XXX" | sort -t";" -k2 -o ${baseProduit}
ls -la ${baseProduit}
wc ${baseProduit}

echo ""
baseEAN13=`dirname $0`"/base.EAN13.csv"
grep "^[38]" ${baseProduit} | sort -t";" -k2 -o ${baseEAN13}
ls -la ${baseEAN13}
wc ${baseEAN13}

echo ""
baseCOULEUR=`dirname $0`"/base.COULEUR.csv"
cat `dirname $0`/*/*COULEUR.csv | sort | uniq > ${baseCOULEUR}
ls -la ${baseCOULEUR}
wc ${baseCOULEUR}

echo ""
baseANOMALIES=`dirname $0`"/base.ANOMALIES.csv"
chercheAnomalies "$baseProduit" "$baseANOMALIES"
ls -la ${baseANOMALIES}
wc ${baseANOMALIES}

