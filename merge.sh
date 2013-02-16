#!/bin/bash

if [ -f map-out/distritos/mx_distrito.shp ];
then
   rm map-out/distritos/mx_distrito.*
fi

for file in unzip/distrito/*.shp
do
        echo ${file}
	ogr2ogr -update -append map-out/distritos/mx_distrito.shp ${file}  -nln mx_distrito 
done


if [ -f map-out/distritos/mx_distrito.shp ];
then
   rm unzip/seccion/mx_secciones_ife.shp
fi

for file in unzip/seccion/*.shp
do
        echo ${file}
	ogr2ogr -update -append unzip/seccion/mx_secciones_ife.shp ${file}  -nln mx_secciones_ife
done
