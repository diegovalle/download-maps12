#!/bin/bash 
#Unzip the shapefiles
set -euo pipefail

function decompress {
  for i in zip/$1/*.zip
    do      
      unzip -o $i -d unzip/$1
  done
}

decompress mexico

decompress distrito
rm -rf unzip/distrito/secciones*
decompress seccion
rm -rf unzip/seccion/distritos*
