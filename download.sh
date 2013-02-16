#!/bin/bash 

WGET="wget -c -nc -w 5 --random-wait --tries=10 "
#Download shape files and electoral data from the INEGI
#The files are available by state

#Distrito files 
for (( i = 1 ; i <= 32 ; i++ )) 
do 
  if [ -f zip/distrito/$i-distrito.zip ];
  then
    $WGET "http://gaia.inegi.org.mx/NLB/tunnel/IFE2010/Descarga.do?tabla=2&grupo=1,2,3,4,5,6,7,8,9,10,11,12&edo="$i -O zip/distrito/$i-distrito.zip
  fi
done 

#Seccion electoral files
for (( i = 1 ; i <= 32 ; i++ )) 
do 
if [ ! -f zip/seccion/$i-seccion.zip ];
  then
    $WGET "http://gaia.inegi.org.mx/NLB/tunnel/IFE2010/Descarga.do?tabla=2&grupo=1,2,3,4,5,6,7,8,9,10,11,12&edo="$i -O zip/seccion/$i-seccion.zip
  fi
done 

echo "Sometimes mapserver.inegi.org.mx goes down, if so try again after a few hours"
if [ ! -f zip/mexico/municipios50.zip ];
  then
    $WGET "http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=MUNICIPIOS50" -O zip/mexico/municipios50.zip
fi

if [ ! -f zip/mexico/estados50.zip ];
  then
    $WGET "http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=ESTADOS50" -O zip/mexico/estados50.zip
  fi

if [ ! -f zip/mexico/localidades-urbanas50.zip ];
  then
    $WGET http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=LOCURBANAS50 -O zip/mexico/localidades-urbanas50.zip
  fi

if [ ! -f zip/mexico/localidades-rurales50.zip ];
  then
    $WGET http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=LOCRURALES50 -O zip/mexico/localidades-rurales50.zip
  fi
