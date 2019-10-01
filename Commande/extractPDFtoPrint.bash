# winter 2018 presentation/catalogo winter 18.txt; 2 item(s) -> catalogo\ winter\ 18.pdf
java -jar ../PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage 16 -endPage 16 -outputPrefix PDFextract/extrait1 ../Catalogues/winter\ 2018\ presentation/catalogo\ winter\ 18.pdf
java -jar ../PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage 17 -endPage 17 -outputPrefix PDFextract/extrait2 ../Catalogues/winter\ 2018\ presentation/catalogo\ winter\ 18.pdf

java -jar ../PDFBox/pdfbox-app-2.0.13.jar PDFMerger PDFextract/extrait*.pdf PDFextract/catalogo\ winter\ 18.pdf
rm PDFextract/extrait*.pdf
echo; ls -la PDFextract/catalogo\ winter\ 18.pdf
java -jar ../PDFBox/pdfbox-app-2.0.13.jar PrintPDF PDFextract/catalogo\ winter\ 18.pdf


# Inconnu; 21 item(s) -> Inconnu
java -jar ../PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage 2 -endPage 2 -outputPrefix PDFextract/extrait1 ../Catalogues/Inconnu

java -jar ../PDFBox/pdfbox-app-2.0.13.jar PDFMerger PDFextract/extrait*.pdf PDFextract/Inconnu
rm PDFextract/extrait*.pdf
echo; ls -la PDFextract/Inconnu
java -jar ../PDFBox/pdfbox-app-2.0.13.jar PrintPDF PDFextract/Inconnu


# summer 2019 presentation/catalogo summer_beach 2019.txt; 1 item(s) -> catalogo\ summer_beach\ 2019.pdf
java -jar ../PDFBox/pdfbox-app-2.0.13.jar PDFSplit -startPage 17 -endPage 17 -outputPrefix PDFextract/extrait1 ../Catalogues/summer\ 2019\ presentation/catalogo\ summer_beach\ 2019.pdf

java -jar ../PDFBox/pdfbox-app-2.0.13.jar PDFMerger PDFextract/extrait*.pdf PDFextract/catalogo\ summer_beach\ 2019.pdf
rm PDFextract/extrait*.pdf
echo; ls -la PDFextract/catalogo\ summer_beach\ 2019.pdf
java -jar ../PDFBox/pdfbox-app-2.0.13.jar PrintPDF PDFextract/catalogo\ summer_beach\ 2019.pdf


