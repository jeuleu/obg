#!/usr/bin/bash

source `dirname $0`/../../configAutomatisationFacture.bashrc


function usage() 
{
cat << EOF
usage: $0 options <fichier>.pdf

OPTIONS:
   -h      Affiche cette aide.

EOF
}


# options
while getopts "dh" option
do
	case $option in
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


function chercheDoublonsCouleur()
{
	inputFile="$1"
	doublonsFile="$2"
	tmpFile1="tmpFile1.txt"
	tmpFile2="tmpFile2.txt"
	if [[ -e "$doublonsFile" ]]; then
		rm "$doublonsFile"
	fi
	
	cut -d ";" -f1,3 "$inputFile" | grep -v "CodeBarre" | sort | cut -d ";" -f1 > "$tmpFile1"
	sort -u "$tmpFile1" > "$tmpFile2"
	ll tmpFile*
	wc tmpFile*
	
#	cut -d ";" -f1,3 "$inputFile" | grep -v "CodeBarre" | sort | cut -d ";" -f1 > "$tmpFile1"
#	cut -d ";" -f1 "$tmpFile1" > "$tmpFile3"
	
#	cut -d ";" -f1,4 "$inputFile" | grep -v "CodeBarre" | sort -u  | cut -d ";" -f1 > "$tmpFile2"
#	cut -d ";" -f1 "$tmpFile2" > "$tmpFile4"

	diff "$tmpFile1" "$tmpFile2" > "$doublonsFile"
	
#	rm "$tmpFile1" "$tmpFile2"
	
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
baseProduit=`dirname $0`"/../base.PRODUIT.csv"


echo
echo
echo "Contrôles :"
echo "-----------"

baseDOUBLONS=`dirname $0`"/base.DOUBLONS.csv"
chercheDoublonsCouleur "$baseProduit" baseDoublonsCouleurs.csv
ls -la ${baseDOUBLONS}
wc ${baseDOUBLONS}

echo
baseANOMALIES=`dirname $0`"/base.ANOMALIES.csv"
chercheAnomalies "$baseProduit" "$baseANOMALIES"
ls -la ${baseANOMALIES}
wc ${baseANOMALIES}

