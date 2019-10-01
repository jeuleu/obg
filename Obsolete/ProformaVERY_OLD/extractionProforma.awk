BEGIN {
	print "Extraction : " FILENAME

	marqueurTailleLibelle = 20
	
	#verbose = "vrai"
}


input != FILENAME {
	# fin du fichier précedent si nécessaire
	if (input != "") {
		traitementDeFinDeFichier()
	}

	controleTypeFichier()

	input = FILENAME
	
	# fichier sortie
	output = FILENAME
	output_PROF_traitee = "PROF_traitee.csv"
	gsub(/txt$/, "csv", output)

	nomFichier = output
	gsub(/ /, "\\ ", nomFichier)
	if (system("test -f " nomFichier) == 0) {
		print "    !! Fichier existant : '" output "'"
		output = "/tmp/null"
	}

	# reinitialisation
	etat = "attenteNbLignes"
	etatFichier = ""
	refFacture = ""
	cumulMontant = 0
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
#	print "La page " pageNum " a " nbLignes " lignes"
	
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
#		print "  >> Correction " nbLignes " lignes"
#		print "  >> Dernière page " nbLignes " lignes"
		
		etatFichier = "dernierePage"
	} else {
		numLigne++
		addInfoLigne(numLigne, $0, "lectureModele");
	}
}

/^[A-Z]/ && etat == "lectureCodePiece" {
	if (numLigne >= nbLignes) {
		etat = "lectureCouleur"
		numLigne = 0
#		print "lectureCodePiece : => lectureCouleur '" $0 "' (ligne " NR ")"
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
#		print "lectureCouleur : => attenteUnite '" $0 "' (ligne " NR ")"
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
		print "attenteLibelle : => lectureLibelle '" $0 "' (ligne " NR ")"
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
#	print "lectureTaille '" $0 "'"
	if (numLigne >= nbLignes) {
		etat = "attenteQuantite"
		numLigne = 0
	} else {
		numLigne++
		addInfoLigne(numLigne, $1, "lectureTaille");
	}		
}

/^[0-9,]* / && etat == "attenteQuantite" {
	etat = "lectureQuantite"
	numLigne = 0;
}

/^[0-9]/ &&	etat == "lectureQuantite" {
	if (numLigne >= nbLignes) {
		etat = "lecturePrixUnitaire"
		numLigne = 0
	} else {
		numLigne++
		addInfoLigne(numLigne, 0+$1, "lectureQuantite");
	}		
}


/^[0-9]/ && etat == "lecturePrixUnitaire"  {
	if (etat == "attenteQuantite") {
		etat = "lecturePrixUnitaire"
	}

	if (numLigne >= nbLignes) {
		etat = "lectureMontant"
		numLigne = 0
	} else {
		numLigne++
		addInfoLigne(numLigne, $1, "lecturePrixUnitaire");
	}		
}

# debug
etatFichier == "dernierePage" {
#	print "dernierePage '" $0 "', etat = " etat
}


/^[0-9]/	&&	etat == "lectureMontant" {
	if (numLigne >= nbLignes) {
		finLectureMontant()
	} else {
		numLigne++
		addInfoLigne(numLigne, $1, "lectureMontant");

		# lecture et cumul montant
		montant = $1
		gsub(/,/, "\.", montant)
		cumulMontant += montant
	}
}

# sorti de lectureMontant
etat == "lectureMontant" {
	if (numLigne >= nbLignes) {
		finLectureMontant()
	}
}

function finLectureMontant() {
	if (etatFichier == "dernierePage") {
		etat = "finPage"
	} else {
		etat = "attenteFinPage"
		nbLignesAttente = 1
		
		numLigne = 0
	}
}


etat == "attenteFinPage" {
	if (nbLignesAttente == 0 ) {
#		print "Lecture numéro page : " $0
		
		etat = "finPage"
	}
	
	nbLignesAttente--
	}

etat == "finPage" {
#	print "DEBUG finPage >> avant traitementDeFinDePage"
	traitementDeFinDePage();

	if (etatFichier == "") {
		etat = "attenteNbLignes"
	} else {
		etat = "fichierTraite"
	}
	
	nbLignes = 0
	numLigne = 0

	# interligne
	ajouteLigne(" ")
}


/^[0-9]* O BAG STORE/ {
#	print "BOUTIQUE (forme 1) : " $0 " / '" $5 "'"
	boutique = $5
}

/^O BAG STORE [A-Z]/ {
#	print "BOUTIQUE (forme 2) : " $0 " / '" $4 "'"
	boutique = $4
}

# Ref facture
/^[[:digit:]]{4} [[:digit:]]* [[:digit:]]* [[:digit:]]{2}\/[[:digit:]]{2}\/[[:digit:]]{4}/ {
#	print "Ref facture : '" $0 "'"
	refFacture = $0
}

# total facture
/^EUR [0-9\.,]* / {
	totalFacture = $2
	gsub(/\./, "", totalFacture)
}

# total produit
/^0,00 [0-9][0-9]*/ {
	totalProduits = $2
	gsub(/\./, "", totalProduits)
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

function ajouteLigne(ligne) {
	indexLigne++
	tabLignes[indexLigne] = ligne
}

function traitementDeFinDePage() {
#	print "DEBUG traitementDeFinDePage '" $0 "'"
	for (i = 1; i <= nbLignes; i++) {
		if ( verbose ) {
			print "Page " pageNum " / " i " : " infoLigne[i]
		}
		
		ajouteLigne(infoLigne[i])
		
		# reinitialisation
		delete infoLigne[i]
	}
}

function ecritDansFichier(info) {
	
	if ( verbose ) {
		print info
	}
	
	print info > output
	print info > output_PROF_traitee
}


function traitementDeFinDeFichier() {	
	traitementDeFinDePage()
	
	ecritDansFichier("Produit;Code piece;Couleur;Taille;Libelle;Quantit\351;Prix unitaire;Montant")
	
	ecritDansFichier("Boutique;;" boutique)
	ecritDansFichier("Ref. facture;;" refFacture)
	ecritDansFichier("Total facture;;" totalFacture)
	ecritDansFichier("Total produits;;" totalProduits)
	ecritDansFichier(" ")
	ecritDansFichier("Cumul montant;;" cumulMontant)
	ecritDansFichier("Etat courant = '" etat "'")

	# controle
	gsub(/,/, "\.", totalProduits)

	if (totalProduits == cumulMontant) {
		ecritDansFichier("CONTROLE MONTANT OK;;" cumulMontant ";" totalProduits)
	} else {
		ecritDansFichier("ANOMALIE MONTANT;;" cumulMontant ";" totalProduits)
	}
	ecritDansFichier(" ")
	
	for (i in tabLignes) {
		ecritDansFichier(tabLignes[i])
		delete tabLignes[i]
	}
	
	print "Fichier input : " input
	print "Fichier output : " output, ", " output_PROF_traitee
	print " "
}

# controle du type de fichier
function controleTypeFichier() {

	if (FILENAME !~ /PROF.*txt$/ ) {
		print "Attention : ce n'est pas le bon fichier : " FILENAME
		print ""
		print "Type de fichier attendu : 'PROF.*txt'"
		print ""

		exit 1
	}
}

# A commenter hors debug
{ 
#	print "Ligne " NR " : " $0
}

END {
	traitementDeFinDeFichier()
}