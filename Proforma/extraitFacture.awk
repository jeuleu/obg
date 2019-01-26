BEGIN {
	print "Extraction : " FILENAME

	marqueurTailleLibelle = 20
	
	#verbose = "vrai"
	
	# patterns
	patternTransitionAttenteQuantite = "^ ?[0-9,]* ?$"
	patternLigneCouleur = "^[0-9]{3} ?$"
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
	output_FICHIER_traitee = "FICHIER_traite.csv"
	gsub(/txt$/, "csv", output)

	print " >>> FICHIER_traite=" FICHIER_traite
	nomFichier = output
	gsub(/ /, "\\ ", nomFichier)

	# reinitialisation
	etat = "attenteNbLignes"
	etatFichier = ""
	refFacture = ""
	cumulMontant = 0
}




# Transition : lecture nbLignes
/^[0-9]* ?$/ && etat == "attenteNbLignes" {
	pageNum++
#	print "attenteNbLignes : Nouvelle page " pageNum " - '" $0 "'"
	
	etat = "lectureNbLignes"
	numLigne = 0
}

/^[0-9]* ?$/ && etat == "lectureNbLignes" {
	nbLignes++
	numLigne++
#	print "lectureNbLignes : page " pageNum " - " nbLignes " - '" $0 "'"
	addInfoLigne(numLigne, sprintf("%03d", $0), "lectureNumLigne");
}

# Transition : lecture modele
/^[A-Z]/ && etat == "lectureNbLignes" {
#	print "La page " pageNum " a " nbLignes " lignes"
	
	etat = "lectureModele"
	numLigne = 0
}

/^[A-Z]/ && (etat == "lectureModele") && (numLigne >= nbLignes) {
	etat = "lectureCodePiece"
	numLigne = 0
}

/^[A-Z]/ && (etat == "lectureModele") {
	if (length($1) < 8) {
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

/^[A-Z]/ && (etat == "lectureCodePiece") && (numLigne >= nbLignes) {
	etat = "lectureCouleur"
	numLigne = 0
#	print "lectureCodePiece : => lectureCouleur '" $0 "' (ligne " NR ")"
}


/^[A-Z]/ && (etat == "lectureCodePiece") {
	numLigne++
	addInfoLigne(numLigne, $1, "lectureCodePiece", "-");
}

$0 ~ patternLigneCouleur && (etat == "lectureCodePiece")  {
	etat = "lectureCouleur"
	numLigne = 0
}


$0 ~ patternLigneCouleur && (etat == "lectureCouleur") && (numLigne >= nbLignes) {
	etat = "attenteUnite"
	numLigne = 0
#	print "lectureCouleur : => attenteUnite '" $0 "' (ligne " NR ")"
}


$0 ~ patternLigneCouleur && (etat == "lectureCouleur") {
	numLigne++
	addInfoLigne(numLigne, $1, "lectureCouleur", "-");
#	print "lectureCouleur : '" $0 "' (ligne " NR ")"
}


/^[0-9]* $/ && (etat == "lectureCodePiece")  {
	etat = "lectureCouleur"
	numLigne = 0
}


/^PZ ?$/ && (etat == "lectureCouleur" || etat == "attenteUnite") {
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

etat == "lectureLibelle" && (numLigne >= nbLignes) {
	etat = "attenteTaille"
	numLigne = 0
}

etat == "lectureLibelle" {
	if (length($0) > marqueurTailleLibelle &&
			$0 !~ /[Cc]at\351gorie/ && 
			$0 !~ /AGED01 AGENTE DIREZIONALE/ &&
			$0 !~ /Qté Prix Remises/ &&
			$0 !~ /R.*capitulatifs douaniers/ && 
			$0 !~ /Catégorie Um poids/ && 
			$0 !~ /^NR  / ) {
		numLigne++
		
print "lectureLibelle '" $0 "' >> '" corrigeCaracteresSpeciaux($0) "'"
		addInfoLigne(numLigne, corrigeCaracteresSpeciaux($0), "lectureLibelle");
	}	
}

/UNICA/ && etat == "attenteTaille" {
	etat = "lectureTaille"
	numLigne = 0
#	print "lectureLibelle => lectureTaille (ligne " NR ")"
}

etat == "lectureTaille" && (numLigne >= nbLignes) {
	etat = "attenteQuantite"
	numLigne = 0
}


etat == "lectureTaille" {
	numLigne++
	addInfoLigne(numLigne, $1, "lectureTaille");
}

$0 ~ patternTransitionAttenteQuantite && etat == "attenteQuantite" {
	print "Transition attenteQuantite '" $0 "'"
	etat = "lectureQuantite"
	numLigne = 0;
}


$0 ~ patternTransitionAttenteQuantite &&	etat == "lectureQuantite" && (numLigne >= nbLignes) {
	etat = "lecturePrixUnitaire"
	numLigne = 0
}		

$0 ~ patternTransitionAttenteQuantite &&	etat == "lectureQuantite" {
#	print "lectureQuantité : numLigne=" numLigne ", '" $0 "'"
	numLigne++
	addInfoLigne(numLigne, 0+$1, "lectureQuantite");
}


/^ ?[0-9]/ && etat == "lecturePrixUnitaire" && (numLigne >= nbLignes) {
	etat = "lectureMontant"
	numLigne = 0
}


/^ ?[0-9]/ && etat == "lecturePrixUnitaire"  {
	numLigne++
	addInfoLigne(numLigne, $1, "lecturePrixUnitaire");
}

etatFichier == "dernierePage" {
#	print "dernierePage '" $0 "', etat = " etat
}


/^ ?[0-9]/ &&	etat == "lectureMontant" {
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

	# interligne
#	ajouteLigne(" ")
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
#	print "DEBUG (0) lecture total facture '" $0 "'"
	totalFacture = $2
	gsub(/\./, "", totalFacture)
#	print "DEBUG lecture total facture '" totalFacture "'"
}

# total produit
/^0,00 [0-9][0-9]*/ {
#	print "DEBUG (0) lecture total produit '" $0 "'"
	totalProduits = $2
	gsub(/\./, "", totalProduits)
#	print "DEBUG lecture total produit '" totalProduits "'"
}


# Debug
{
#	print "Debug : (" NR ") etat '" etat "', page='" pageNum "', numLigne='" numLigne "/" nbLignes ", ligne='" $0 "'"
}



function addInfoLigne(numLigne, info, typeInfo, separateur) {
	if (!separateur) {
		separateur = ";"
	}
	
	if (infoLigne[numLigne] != "") {
		infoLigne[numLigne] = infoLigne[numLigne]  separateur 
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
	
	nbLignes = 0
	numLigne = 0
}

function ecritDansFichier(info) {
	
	if ( verbose ) {
		print info
	}
	
	print info > output
	print info > output_FICHIER_traitee
}


function traitementDeFinDeFichier() {	
	traitementDeFinDePage()

	numInfo++
	
	ecritDansFichier(sprintf(" %02d", numInfo++) ";Produit;Code piece;Couleur;Taille;Libelle;Quantite;Prix unitaire;Montant")
	
	ecritDansFichier(sprintf(" %02d", numInfo++) ";Boutique;;" boutique)
	ecritDansFichier(sprintf(" %02d", numInfo++) ";Ref. facture;;" refFacture)
	ecritDansFichier(sprintf(" %02d", numInfo++) ";Total facture;;" totalFacture)
	ecritDansFichier(sprintf(" %02d", numInfo++) ";Total produits;;" totalProduits)
	ecritDansFichier(sprintf(" %02d", numInfo++) ";Cumul montant;;" cumulMontant ";;Etat courant = '" etat "'")

	# controle
	gsub(/,/, "\.", totalProduits)
	print "Montants lus : '" cumulMontant "', '" totalProduits "'"
	if (totalProduits == cumulMontant) {
		ecritDansFichier(sprintf(" %02d", numInfo++) ";CONTROLE MONTANT OK;;" cumulMontant ";" totalProduits)
	} else {
		ecritDansFichier(sprintf(" %02d", numInfo++) ";ANOMALIE MONTANT;;" cumulMontant ";" totalProduits)
	}
	ecritDansFichier(sprintf(" %02d", numInfo++) ";")
	
	for (i in tabLignes) {
		ecritDansFichier(sprintf("%03d;%s", i, tabLignes[i]))
		delete tabLignes[i]
	}
	
	print "Fichier input : " input
	print "Fichier output : " output, ", " output_FICHIER_traitee
	print " "
}


function corrigeCaracteresSpeciaux(ligne) {
	gsub(/ $/, "", ligne)

	gsub(/\221|\222/, "'", ligne)
	gsub(/\253|\273/, "\"", ligne)
	gsub(/\223|\224/, "\"", ligne)
	gsub(/\240/, " ", ligne)
	gsub(/\350|\351/, "e", ligne)
	gsub(/\362/, "0", ligne)
	gsub(/\371/, "<u>", ligne)
	gsub(/‘/, "XX", ligne)
	
	gsub(/Î/, "I", ligne)
	gsub(/«/, "\"", ligne)
	
	gsub(/É|Ê|Ë/, "E", ligne)
	
	gsub(/\310|\311/, "E", ligne) # É
	gsub(/\316/, "I", ligne) # Î
	
	gsub(/\214/, "OE", ligne)
	
	return ligne
}


# controle du type de fichier
function controleTypeFichier() {

	if (FILENAME !~ /FAT_.*txt$/ && FILENAME !~ /PROF.*txt$/) {
		print "Attention : ce n'est pas le bon fichier : " FILENAME
		print ""
		print "Type de fichier attendu : 'FAT_xxx.txt' ou 'PROFxxx.txt'"
		print ""

		exit 1
	}
}

# A commenter hors debug
{ 
#	print "Ligne " NR " : etat= '" etat "', '" $0 "'"
}

END {
	traitementDeFinDeFichier()
}