#!/bin/bash 
#Unzip the shapefiles
function decompress {
  for i in zip/$1/*.zip
    do      
      unzip $i -d unzip/$1
  done
}

decompress mexico
decompress distrito
decompress seccion

