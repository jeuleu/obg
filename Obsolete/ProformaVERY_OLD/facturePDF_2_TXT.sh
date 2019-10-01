#!/usr/bin/bash

pdfBoxFile=`dirname $0`/../PDFBox/pdfbox-app-2.0.13.jar

echo "pdfBoxFile $pdfBoxFile"
ls -la "$pdfBoxFile"
echo " "

force=false

# contrôle des parametres	
for arg in "$@"; do
    case "$arg" in
        -f)
			echo "Regénération des fichiers forcée"
			echo " "
            force=true
			;;
#        *)
#            nothing="true"
#            ;;
    esac
done

if [[ ! $1 =~ \.PDF$ ]]; then
	echo ""
	echo "Usage: `basename $0` <fichier.PDF> [-f]"
	echo "Options"
	echo "-f : force génération d'un fichier déjà présent"
	echo " "
	echo "'$1'"
	echo " "
	exit
fi

for file in "$@"; do
	if [[ $file =~ \.PDF$ ]] && [[ $file != "-f" ]]; then
		txtFile=${file%PDF}txt
		
		traiteFichier=$force;
		
		if [[ -e $txtFile ]]; then
			echo "  Fichier existant :"
			echo "  '$txtFile'"
		else
			traiteFichier=true
		fi
		
		if [ $traiteFichier == true ]; then
			echo "Extraction des informations du fichier '$file'"
			java -jar "$pdfBoxFile" ExtractText "$file"
			ls -la "$txtFile"
			echo " "
		fi
	fi
done
