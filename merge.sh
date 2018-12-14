#!/bin/bash
#Since you have to download the electoral maps by state this
#file merges them into a single file
set -euo pipefail

function merge {
  #Delete the merged shapefile if it exists
  echo merging $3 shapefiles
  if [ -f $1.shp ];
  then
     rm $1.*
  fi

  #Merge the files from Mexico's 32 states into one big shapefile
  for file in unzip/$3/*.shp
  do
    #echo ${file}
    ogr2ogr -update -append $1.shp ${file}  -nln $2 
  done
}

merge "map-out/distritos/mx_distrito" mx_distrito distrito
#Since we want to add the INEGI municipality codes we merge it to a temporary file
merge "unzip/seccion/mx_secciones_ife" mx_secciones_ife seccion


