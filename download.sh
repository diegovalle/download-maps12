#!/bin/bash 
#Download shape files and electoral data from the INEGI
#The files are available by state
WGET="wget -c -nc -w 5 --random-wait --tries=10 "

##Download the electoral shapefiles
function download_ife {
  for (( i = 1 ; i <= 32 ; i++ ))
    do 
      print $i
      if [ ! -f zip/$1/$i-$1.zip ];
        then
          $WGET $2$i -O zip/$1/$i-$1.zip
      fi
    done 
}

#Download the state, municipality and locality shapefiles
function download_inegi {
  if [ ! -f zip/mexico/$1 ];
    then
      $WGET $2 -O zip/mexico/$1
  fi
}


###Download Shapefiles from IFE
download_ife distrito "http://gaia.inegi.org.mx/NLB/tunnel/IFE2010/Descarga.do?tabla=2&grupo=1,2,3,4,5,6,7,8,9,10,11,12&edo="

download_ife seccion "http://gaia.inegi.org.mx/NLB/tunnel/IFE2010/Descarga.do?tabla=2&grupo=1,2,3,4,5,6,7,8,9,10,11,12&edo="

###Download Shapefiles from the INEGI
echo "Sometimes mapserver.inegi.org.mx goes down, if so try again after a few hours"

download_inegi municipios50.zip "http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=MUNICIPIOS50"

download_inegi estados50.zip "http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=ESTADOS50"

download_inegi localidades-urbanas50.zip "http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=LOCURBANAS50"

download_inegi localidades-rurales50.zip "http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=LOCRURALES50"

