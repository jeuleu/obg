
# Extraction des codes couleur
find . -name "catalo*txt" -exec awk -f extractionCodesCouleurs.awk {} \; | sort | uniq > ListeCouleurs.csv

# Extraction des catalogues
find . -name "catalo*txt" -exec ./extraitProduitsCatalogue.sh {} \;


# A FAIRE
Parametre "codesCouleurs" du script extraitProduitsCatalogue pour ne produire que les codes couleurs 


