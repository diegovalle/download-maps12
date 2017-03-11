#!/bin/bash
set -e
# Download electoral shapefiles from the INE
# includes colonias
# needs sudo apt-get install p7zip-rar p7zip-all

# State abbreviations
declare -a states=("ags" "bc" "bcs" "camp" "coah" "col" "chis" "chih"
                   "df" "dgo" "gto" "gro" "hgo" "jal" "mex" "mich" "mor" "nay" "nl" "oax"
                   "pue" "qro" "qroo" "slp" "sin" "son" "tab" "tamps" "tlax" "ver" "yuc"
                   "zac");

mkdir -p map-out/otros
counter=0
for i in $(seq 1 32);
do
    # The INEGI uses a leading zero for all one digit numbers
    if [ "$i" -lt 10 ]
    then
        FILENUM="0$i"
    else
        FILENUM="$i"
    fi
    curl -o "ECEG_$FILENUM.zip" "http://gaia.inegi.org.mx/geoelectoral/datos/ECEG_$FILENUM.zip"
    unzip "ECEG_$FILENUM.zip"
    7z x "$FILENUM/fscommand/pry.exe" -o${states[$counter]}_tmp
    #mkdir ${states[$counter]}
    mv ${states[$counter]}_tmp/ECEG2010/cartografiaDigital_IFE map-out/otros/${states[$counter]}
    mv ${states[$counter]}_tmp/ECEG2010/resultados_electorales map-out/otros/${states[$counter]}
    rm -rf ${states[$counter]}_tmp # delete the dir from 7z
    rm -rf "$FILENUM" # delete the dir from unzip
    # rename files
    find map-out/otros/ -type f -name "CCL_E$FILENUM_*" -exec rename "s/CCL_E$FILENUM/${states[$counter]}/" "{}"  \;
    find map-out/otros/ -type f -name "_E$FILENUM_*" -exec rename "s/_E$FILENUM\./${states[$counter]}\./" "{}"  \;
    sleep 1
    counter=$((counter + 1))
done
# convert all filenames and directories to lowercase
# https://unix.stackexchange.com/questions/20222/change-entire-directory-tree-to-lower-case-names
find map-out/otros -depth -exec sh -c '
    t=${0%/*}/$(printf %s "${0##*/}" | tr "[:upper:]" "[:lower:]");
    [ "$t" = "$0" ] || mv -i "$0" "$t"
' {} \;

# The filename of the merged file
FILEOUT="colonias.shp"
# The names of the files to merge, you can change this to
# "*entidad.shp" or "*eje_vial.shp", etc
TYPE="*colonia.shp"
# for i in $(find .  -name "$TYPE")
# do
#     if [ -f "$FILEOUT" ]
#     then
#         echo "adding state $i to $FILEOUT"
#         ogr2ogr -f 'ESRI Shapefile' -update -append $FILEOUT "$i" -nln "$(basename -s .shp $FILEOUT)"
#     else
#         echo "startin merge..."
#         echo "adding state $i to $FILEOUT"
#         ogr2ogr -f 'ESRI Shapefile' $FILEOUT "$i"
#     fi
# done
