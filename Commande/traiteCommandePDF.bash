#!/usr/bin/bash

source `dirname $0`/../configAutomatisationFacture.bashrc

pdfBoxFile=$AUTO_HOME/PDFBox/pdfbox-app-2.0.13.jar

traduitFichierCommandeAwkFile=$AUTO_HOME/Commande/traduitFichierCommandePDF.awk
refManquantesAwkFile=$AUTO_HOME/Commande/extraitRefManquantes.awk
ean13GlobalFile="`dirname $0`/EAN13_traite.csv"
synthesisFile="`dirname $0`/recapCommandes-Donnees.csv"

echo " EAN '$ean13GlobalFile'"
echo " "

function usage() 
{
cat << EOF
usage: $0 options <fichier>.pdf

OPTIONS
   -p      Force l'extraction du fichier 'txt' à partir du fichier PDF.
   -f      Force la regénération du fichier 'CSV' à partir du fichier txt.
   -c	   Recalcule la synthèse des catalogues. Nécessaire après une nouvelle saisie de codes barres
   -h      Affiche cette aide.

EOF
}

# options
while getopts "hfpc" option
do
	case $option in
		h)
			usage
			exit 0
			;;
		f)
			echo "Regénération des fichiers CSV"
			FORCE_CSV=true
			;;

		p)
			echo "Bientôt !"
			echo "Regénération des fichiers TXT depuis PDF"
			FORCE_PDF=true
			;;

		c)
			echo "Regénération de la synthèse des catalogues"
			cmdSyntheseCatalogue="$AUTO_HOME/Catalogues/syntheseCatalogues.bash"
			echo "Commande : $cmdSyntheseCatalogue"
			eval "$cmdSyntheseCatalogue"
			
			echo " "
			;;

    esac
done

# usage
if [[ $# == 0 ]]; then
	usage
fi

function traitePDF_2_TXT()
{
	outputFile="${1%pdf}txt"

	echo -n "  traitePDF_2_TXT   : "
	if [ ! -z "$FORCE_PDF" ] || [[ ! -e $outputFile ]]; then
		echo "'$outputFile'"
		"$JAVA_HOME/bin/java" -jar "$pdfBoxFile" ExtractText "$arg"

		wc "$outputFile"
		echo " "
	else
		echo ">> déja traité '$outputFile'"
		echo " "
	fi
}

function traiteTXT_2_CSV()
{
	inputFile="${1%pdf}txt"
	outputFile="${1%pdf}csv"

	echo -n "  traiteTXT_2_CSV : "
  	
	if [ ! -z "$FORCE_CSV" ] || [[ ! -e "$outputFile" ]]; then
		echo "'$outputFile'"
		awk -f "$traduitFichierCommandeAwkFile" "$inputFile"

		wc "$outputFile"
		echo " "
	else
		echo ">> déja traité '$outputFile'"
		echo " "
	fi
}

function fusionneAvecBasesProduit()
{
	inputFile="${1%pdf}csv"
	couleurFile="${1%pdf}1-COULEUR.csv"
	ean13File="${1%pdf}2-EAN13.csv"
	manquantFile="${1%pdf}3-MANQUANT.csv"
	aImprimerFile="${1%pdf}4-A_IMPRIMER.csv"
	
	baseObagEAN13="$AUTO_HOME/Catalogues/base.EAN13.uniq.csv"
	baseValmagEAN13="$AUTO_HOME/Catalogues/base.ValmagEAN13.csv"
	basePRODUIT="$AUTO_HOME/Catalogues/base.PRODUIT.csv"

	echo -n "  fusionneAvecBasesProduit : "
	echo "'$inputFile'"
	echo "Base '$hbaseValmagEAN13'"

	echo " "
	ls -la "$baseValmagEAN13"
	ls -la "$basePRODUIT"
	echo " "

	# jointure des couleurs
	join -t";" -a1 -1 3 -2 2 <(grep -v "^ " "$inputFile" | sort -t";" -k3) <(sort -t";" -k2 "$baseObagEAN13") -e'CodeBarre' -o 1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,2.3,1.9,1.10,1.11,1.12,1.13,1.14	| sort -t";" -o "$couleurFile"	
	afficheBilanFichierEtSupprimeSiVide "$couleurFile" "Couleurs"

	# jointure des codes barre
	join -t";" -a1 -1 3 -2 2 <(sort -t";" -k3 "$couleurFile") <(sort -t";" -k2 "$baseValmagEAN13") -e'CodeBarre' -o 1.1,1.2,2.1,1.3,1.4,1.5,1.6,1.7,1.8,2.3,2.4,2.5,1.9,1.10,1.11,1.12,1.13,1.14,1.15 | sort -t";" -o "$ean13File"
	afficheBilanFichierEtSupprimeSiVide "$ean13File" "Codes EAN13"

	# recherche des produits manquants
	join -t";" -a1 -1 4 -2 2 <(grep -v "^ " "$ean13File" | grep ";CodeBarre;" | sort -t";" -k3) <(sort -t";" -k2 "$basePRODUIT") -e'-' -o 1.1,1.2,1.4,2.6,2.3,1.5,1.6 | sort -t";" -k4 -o "$manquantFile"
	afficheBilanFichierEtSupprimeSiVide "$manquantFile" "Produits manquants"

	# recherche des catalogues pour les références manquantes 
	if [ -s "$manquantFile" ]; then
		awk -v pdfBoxFile="${pdfBoxFile}" -f "${refManquantesAwkFile}" "$manquantFile" | sort > "$aImprimerFile"
		afficheBilanFichierEtSupprimeSiVide "$aImprimerFile" "Catalogues à imprimer"
	fi

	if [ -s "$aImprimerFile" ]; then
		echo " "
		echo "Vision page :"
		sort "$aImprimerFile" | cut -d";" -f1,2,4

		echo " "	
		echo "Vision produits :"
		sort "$aImprimerFile" | cut -d";" -f3,1
	fi
	
	# constitution d'un fichier de synthèse 
	grep "^ " "$inputFile" >> "$ean13GlobalFile"

	cat "$ean13File" >> "$ean13GlobalFile"
	afficheBilanFichierEtSupprimeSiVide "$ean13GlobalFile" "Fichier EAN13 global"
	
	# fichier de synthese
	creeFichierDeSyntheseEAN
	
	echo " "
}

function afficheBilanFichierEtSupprimeSiVide() 
{
	fichier="$1"
	commentaire="$2"
	
	echo " "
	if [ ! -s "$fichier" ]; then
		echo "  $commentaire : pas de données !"
		if [ -f "$fichier" ]; then
			rm "$fichier"
		fi
	else 
		echo "  $commentaire :"
		ls -la "$fichier"
		wc "$fichier" 
	fi
		
	echo " "
}

function creeFichierDeSyntheseEAN()
{
	echo "Index;Ligne Commande;EAN13;Ref. O bag;Libelle O bag;Taille O bag;Quantite;PU ;Prix;Ref. Valmag;Couleur Valmag;Taille Valmag;Couleur O bag;Nom fichier;Type fichier;Date fichier;Total Facture;Total Produit;Reference Document" > "$synthesisFile"

	grep -v "^ " "$ean13GlobalFile" >> "$synthesisFile"

	echo "Fichier de synthese des commandes"
	ls -la "$synthesisFile"
	wc "$synthesisFile" 
}


# nettoyage
if [ -f "$ean13GlobalFile" ]; then
	echo "Suppression '$ean13GlobalFile'"
	rm "$ean13GlobalFile"
else
	echo "Fichier '$ean13GlobalFile' inexistant"
fi

# traitement	
for arg in "$@"; do
	# PDF -> pdf
	if [[ $arg =~ \.PDF$ ]]; then
		echo -n "Renommage du fichier '" $arg "' en "
		mv "$arg" "${arg%PDF}pdf"
		arg="${arg%PDF}pdf"
		echo "'" $arg "'"
		echo " "
	fi

	# traitement d'un fichier PDF
	if [[ $arg =~ \.pdf$ ]]; then
		echo "Fichier pdf '$arg'"
	
		traitePDF_2_TXT "$arg"
		
		traiteTXT_2_CSV "$arg"
		
		fusionneAvecBasesProduit "$arg"
		echo " "
	fi
done

