BEGIN {
	FS = ";"
	print "Extraction : " FILENAME

	#verbose = "vrai"
}	


input != FILENAME {

	# controle du type de fichier
	if (FILENAME !~ /EXPTARIF/) {
		print "Attention : ce n'est pas le bon fichier : " FILENAME
		print ""
		print "Type de fichier attendu : 'EXPTARIF'"
		print ""
		print "Valmag / Fichiers de base / ..."

		exitAnalyse = 1
		exit 1
	}

	input = FILENAME
	print "Source : " input
	
	# fichier sortie
	output = FILENAME
	gsub(/EDITARSTO_.*_/, "tarifValmag_", output)
	output2 = "tarifValmag.csv"
	outputTarifNul = "tarifValmagNul.csv"

	nomFichier = output
	gsub(/ /, "\\ ", nomFichier)
	if (system("test -f " nomFichier) == 0) {
		print "    !! Fichier existant : '" output "'"
		output = "/tmp/null"
	}

	
	print "Sortie : "  output ", " output2
	print " "

	ecritInfo("Modele;Couleur;Taille;Prix Achat;Prix Vente;Saison;Code complet")
}

$1 ~ /[A-Z]/ {
    modele = $1
    gsub(/ /, "", modele)
    
    couleur = $2
    gsub(/ /, "", couleur)

    
    saison = $3
    gsub(/ /, "", saison)
    
    i=1
    indice = 3*i + 2
    gsub(/ /, "", $indice)

	while ($indice != "") {
        taille = $indice
        gsub(/ /, "", taille)
        prixAchat = $(indice+1)
        prixVente = $(indice+2)
        
		if (prixAchat != "0") {
            
            ecritInfo(modele ";" couleur ";" taille ";" prixAchat ";" prixVente ";" saison ";" modele "|" couleur "|" taille)
    
        } else {
            print " >> Pas de prix : " modele ";" couleur ";" taille ";" prixAchat ";" prixVente
            print " >> Pas de prix : " modele ";" couleur ";" taille ";" prixAchat ";" prixVente > outputTarifNul
        }
        
        # boucle
        i++
        indice = 3*i + 2
        gsub(/ /, "", $indice)
    }
    
}


	
function ecritInfo(info) {
	print info
	print info > output
	print info > output2
}

END {
	if (!exitAnalyse) {
		ecritInfo(" ")
		ecritInfo("Source;" input)
		ecritInfo("Sortie;"  output ", " output2)
	}
}