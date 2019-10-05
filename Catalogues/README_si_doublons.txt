En cas de doublons au traitement d'une PROFORMA

Analyse :
---------
Il s'agit certainement de doublons de nommages de couleurs.
Vérifier en cherchant le code dans les fichiers de base :

  cd ../Catalogues
  grep HLESCE01-ECS00-055 base.EAN13.csv
  grep HLESCE01-ECS00-055 base.EAN13.uniq.csv

Il doit y avoir des doublons.

Correctif :
-----------
1- Choisir le nom de couleur qui nous convient, et corriger les fichiers .txt extraits des .pdf correspondants.

  vi summer\ 2019\ presentation/catalogo\ summer_beach\ 2019.txt

2- Regéréner l'analyse du catalogue correspondant, puis regénérer une synthèse

  ./traiteCataloguePdf.bash -f summer\ 2019\ presentation/catalogo\ summer_beach\ 2019.pdf
  ./syntheseCatalogues.bash
  
3- Constater l'amélioration dans les fichiers base.EAN13

4- Relancer l'analyse de la proforma
  cd ../Commandes
  ./traiteCommandePDF.bash -f 2019-09-Fall19/FAT_2019_50_0001933.pdf
