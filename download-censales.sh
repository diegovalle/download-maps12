#!/bin/bash
#Download the estadisticas censales from the ife
#This files are necessary to merge with the inegi codes using
#the names of the municipalities

WGET="wget -c -nc -w 5 --random-wait --tries=10 "

declare -a files=("01Aguascalientes" "02BajaCalifornia" "03BajaCaliforniaSur" 
"04Campeche" "05Coahuila" "06Colima" "07Chiapas" 
"08Chihuahua" "09DistritoFederal" "10Durango" 
"11Guanajuato" "12Guerrero" "13Hidalgo" "14Jalisco" 
"15Mexico" "16Michoacan" "17Morelos" "18Nayarit" 
"19NuevoLeon" "20Oaxaca" "21Puebla" "22Queretaro" 
"23QuintanaRoo" "24SanLuisPotosi" "25Sinaloa" 
"26Sonora" "27Tabasco" "28Tamaulipas" "29Tlaxcala" 
"30Veracruz" "31Yucatan" "32Zacatecas")

for file in "${files[@]}"
do
        echo ${file}
          if [ ! -f ife/${file}.zip ];
            then
	      $WGET http://www.ife.org.mx/docs/IFE-v2/DERFE/DERFE-DistritosElectorales/DERFE-ProductosGeoElecDesc-docs/${file}.zip -O ife/${file}.zip
            fi
done

###Unzip the files
for i in ife/*.zip
do      
  unzip -o $i -d ife 
done
