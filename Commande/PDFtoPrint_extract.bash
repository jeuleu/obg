# winter 2018 presentation/catalogo winter 18.txt; 1 item(s) -> catalogo\ winter\ 18.pdf
java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage 21 -endPage 21 -outputPrefix PDFextract/extrait1 ../Catalogues/winter\ 2018\ presentation/catalogo\ winter\ 18.pdf
mv PDFextract/extrait-1.pdf PDFextract/catalogo\ winter\ 18.pdf
echo; ls -la PDFextract/catalogo\ winter\ 18.pdf

java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PrintPDF PDFextract/catalogo\ winter\ 18.pdf

start excel ../Catalogues/winter\ 2018\ presentation/catalogo\ winter\ 18.PRODUIT.csv


# Inconnu; 4 item(s) -> Inconnu
java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage 2 -endPage 2 -outputPrefix PDFextract/extrait1 ../Catalogues/Inconnu
mv PDFextract/extrait-1.pdf PDFextract/Inconnu
echo; ls -la PDFextract/Inconnu

java -jar /c/Users/m312742/Documents/Perso/obg/PDFBox/pdfbox-app-2.0.13.jar PrintPDF PDFextract/Inconnu

start excel ../Catalogues/Inconnu


