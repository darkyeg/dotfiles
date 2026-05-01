# PDF tooling — Arabic + English regulator documents.
{ pkgs, lib, ... }:
let
  tesseractWithArabic = pkgs.tesseract.override {
    enableLanguages = [ "eng" "ara" ];
  };

  pdftoolsPython = pkgs.python3.withPackages (ps: with ps; [
    pdfminer-six
    pdfplumber
    pypdf
    pikepdf
    pdf2image
    pillow
    requests
    beautifulsoup4
  ]);
in
{
  home.packages = with pkgs; [
    poppler-utils
    mupdf
    qpdf
    tesseractWithArabic
    ocrmypdf
    (lib.hiPrio pdftoolsPython)
    pandoc
    librsvg
    imagemagick
  ];
}
