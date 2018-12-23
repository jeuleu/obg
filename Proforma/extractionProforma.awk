BEGIN {
	print "Extraction : " FILENAME

	marqueurTailleLibelle = 20
	
	#verbose = "vrai"
}


input != FILENAME {
	print " "

	print "Source : " FILENAME
	input = FILENAME
	
	# fichier sortie
	output = FILENAME
	gsub(/txt$/, "csv", output)
	print "Sortie : " output
	
	nomFichier = output
	gsub(/ /, "\\ ", nomFichier)
	if (system("test -f " nomFichier) == 0) {
		print "    !! Fichier existant : '" output "'"
		output = "/tmp/null"
	}

	print "Produit;Code piece;Couleur;Taille;Libelle;Quantit\351;Prix unitaire;Montant" > output
	
	# reinitialisation
	etat = "attenteNbLignes"
	refFacture = ""
}




# Transition : lecture nbLignes
/^[0-9]* $/ && etat == "attenteNbLignes" {
	pageNum++
#	print "attenteNbLignes : Nouvelle page " pageNum " - '" $0 "'"
	
	etat = "lectureNbLignes"
}

/^[0-9]* $/ && etat == "lectureNbLignes" {
	nbLignes++
#	print "lectureNbLignes : page " pageNum " - " nbLignes " - '" $0 "'"
}

# Transition : lecture modele
/^[A-Z]/ && etat == "lectureNbLignes" {
	print "La page " pageNum " a " nbLignes " lignes"
	
	etat = "lectureModele"
	numLigne = 0
}

/^[A-Z]/ && etat == "lectureModele" {
	if (numLigne >= nbLignes) {
		etat = "lectureCodePiece"
		numLigne = 0
	} else if (length($1) < 8) {
		etat = "lectureCodePiece"
		numLigne = 0

		# c'est la derniere page avec une ligne pour les frais de port
		nbLignes--
		print "  >> Correction " nbLignes " lignes"
	} else {
		numLigne++
		addInfoLigne(numLigne, $0, "lectureModele");
	}
}

/^[A-Z]/ && etat == "lectureCodePiece" {
	if (numLigne >= nbLignes) {
		etat = "lectureCouleur"
		numLigne = 0
		print "lectureCodePiece : => lectureCouleur '" $0 "' (ligne " NR ")"
	} else {
		numLigne++
		addInfoLigne(numLigne, $1, "lectureCodePiece");
	}		
}

/^[0-9]* $/ && etat == "lectureCodePiece"  {
	etat = "lectureCouleur"
	numLigne = 0
}

/^[0-9]{3} $/ && etat == "lectureCouleur" {
	if (numLigne >= nbLignes) {
		etat = "attenteUnite"
		numLigne = 0
		print "lectureCouleur : => attenteUnite '" $0 "' (ligne " NR ")"
	} else {
		numLigne++
		addInfoLigne(numLigne, $1, "lectureCouleur");
	}		
}

/^[0-9]* $/ && etat == "lectureCodePiece"  {
	etat = "lectureCouleur"
	numLigne = 0
}

/^PZ $/ && (etat == "lectureCouleur" || etat == "attenteUnite") {
	etat = "attenteLibelle"
#	print "attenteUnite : => attenteLibelle '" $0 "' (ligne " NR ")"
}


etat == "attenteLibelle" {
	if (length($0) > marqueurTailleLibelle) {
		etat = "lectureLibelle"
		numLigne = 0
#		print "attenteLibelle : => lectureLibelle '" $0 "' (ligne " NR ")"
	} else {
#		print "attenteLibelle : long : " length($0) " - '" $0 "'"
	}
}

etat == "lectureLibelle" {
	if (numLigne >= nbLignes) {
		etat = "attenteTaille"
		numLigne = 0
	} else {
		if ($0 !~ /[Cc]at\351gorie/ && 	length($0) > marqueurTailleLibelle) {
			numLigne++
			addInfoLigne(numLigne, $0, "lectureLibelle");
		}	
	}		
}

/UNICA/ && etat == "attenteTaille" {
	etat = "lectureTaille"
	numLigne = 0
#	print "lectureLibelle => lectureTaille (ligne " NR ")"
}

etat == "lectureTaille" {
	if (numLigne >= nbLignes) {
		etat = "attenteQuantite"
		numLigne = 0
	} else {
		numLigne++
		addInfoLigne(numLigne, $1, "lectureTaille");
	}		
}

/^[0-9]* / && etat == "attenteQuantite" {
	etat = "lectureQuantite"
	numLigne = 0;
}

/^[0-9]/	&&	etat == "lectureQuantite" {
	if (numLigne >= nbLignes) {
		etat = "lecturePrixUnitaire"
		numLigne = 0
	} else {
		numLigne++
		addInfoLigne(numLigne, $1, "lectureQuantite");
	}		
}


/^[0-9]/	&&	etat == "lecturePrixUnitaire" {
	if (numLigne >= nbLignes) {
		etat = "lecturePrixTotal"
		numLigne = 0
	} else {
		numLigne++
		addInfoLigne(numLigne, $1, "lecturePrixUnitaire");
	}		
}

/^[0-9]/	&&	etat == "lecturePrixTotal" {
	if (numLigne >= nbLignes) {
		etat = "attenteFinPage"
		nbLignesAttente = 1
		
		numLigne = 0
	} else {
		numLigne++
		addInfoLigne(numLigne, $1, "lecturePrixTotal");
	}		
}

etat == "attenteFinPage" {
	if (nbLignesAttente == 0 ) {
		print "Lecture numéro page : " $0
		
		etat = "finPage"
	}
	
	nbLignesAttente--
	}

etat == "finPage" {
	afficheInfosLigne();

	etat = "attenteNbLignes"
	
	nbLignes = 0
	numLigne = 0

	# interligne
	print " " > output
	
	print "FIN DE PAGE : " $0
}


/31[0-9]{3} [A-Z]* FR/ {
	print "BOUTIQUE : " $0 " / '" $2 "'"
	boutique = $2
}

# attente ref facture
/^Banque/ && !refFacture {
	etatMemorise = etat

	etat = "attenteRefFacture"
	nbLignesAttente = 1
}

etat == "attenteRefFacture" {
	#print "attenteRefFacture : " $0
	if (nbLignesAttente == 0 ) {
		refFacture = $0
		
		etat = etatMemorise
	}
	
	nbLignesAttente--
}

# attente total produits
/1G VEND.N.I.ART./ {
	etat = "attenteTotalProduits"
	nbLignesAttente = 2
	
	totalFacture = $5;
	gsub(/\./, "", totalFacture)
}

etat == "attenteTotalProduits" {
	print "attenteTotalProduits : (nbLignesAttente : " nbLignesAttente ") " $0
	if (nbLignesAttente == 0 ) {
		totalProduits = $1
		gsub(/\./, "", totalProduits)
		
		afficheInfosFinFichier()
		
		etat = "finAnalyseFichier"
	}
	
	nbLignesAttente--

}

{ 
#	print "Ligne " NR " : " $0
}

function addInfoLigne(numLigne, info, typeInfo) {
	if (infoLigne[numLigne] != "") {
		infoLigne[numLigne] = infoLigne[numLigne] ";" 
	}
	
	# supprimer le dernier blanc
	gsub(/ $/, "", info)

	infoLigne[numLigne] = infoLigne[numLigne] info
	
	if (verbose) {
		print "addInfo " typeInfo " : " infoLigne[numLigne]
	}
}

function afficheInfosLigne() {
	for (i = 1; i <= nbLignes; i++) {
		if ( verbose ) {
			print "Page " pageNum " / " i " : " infoLigne[i]
		}
		print infoLigne[i] > output
		
		# reinitialisation
		delete infoLigne[i]
	}
}


function afficheInfosFinFichier() {
	print "On a : " pageNum " pages...."
	
	afficheInfosLigne()
	
	print " "
	print " " > output

	print "Boutique : " boutique
	print "Boutique;;" boutique > output

	print "Ref. facture : " refFacture
	print "Ref. facture;;" refFacture > output

	print "Total facture : " totalFacture
	print "Total facture;;" totalFacture > output

	print "Total produits : " totalProduits
	print "Total produits;;" totalProduits > output

	print " "
	
	print "Fichier input : " input
	print "Fichier output : " output
	
	
}