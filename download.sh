#!/bin/bash 
#Download shape files and electoral data from the INEGI
#The files are available by state
WGET="wget -c -nc -w 5 --random-wait --tries=10 "

##Download the electoral shapefiles
function download_ife {
  for (( i = 1 ; i <= 32 ; i++ ))
    do 
      echo $i
      if [ ! -f zip/$1/$i-$1.zip ];
        then
          $WGET $2$i -O zip/$1/$i-$1.zip
      fi
      if [ ! -s zip/$1/$i-$1.zip ]
      then
        echo "##########################################################################"
	echo "Something went wrong when downloading the file. make clean"
        echo "##########################################################################"
	exit 1
      fi
    done 
}

#Download the state, municipality and locality shapefiles
function download_inegi {
  if [ ! -f zip/mexico/$1 ];
    then
      $WGET $2 -O zip/mexico/$1
      if [ $? -ne 0 ]
        then
          echo "##########################################################################"
	  echo "Sometimes mapserver.inegi.org.mx goes down, make clean and try again after a few hours"
          echo "##########################################################################"
	  exit 1
      fi
    if [ ! -s zip/mexico/$1 ]
      then
        echo "##########################################################################"
	echo "Something went wrong when downloading the file. make clean"
        echo "##########################################################################"
	exit 1
    fi
  fi
}


###Download Shapefiles from the IFE
#http://gaia.inegi.org.mx/NLB/tunnel/IFE2010/Descarga.do?tabla=0&grupo=0&edo=
download_ife distrito "http://gaia.inegi.org.mx/NLB/tunnel/IFE2010/Descarga.do?tabla=0&grupo=0&edo="

download_ife seccion "http://gaia.inegi.org.mx/NLB/tunnel/IFE2010/Descarga.do?tabla=0&grupo=0&edo="

###Download Shapefiles from the INEGI
download_inegi municipios50.zip "http://mapserver.inegi.org.mx/MGN/mgm2010v5_0.zip"

download_inegi estados50.zip "http://mapserver.inegi.org.mx/MGN/mge2010v5_0.zip"

download_inegi localidades-urbanas50.zip "http://mapserver.inegi.org.mx/MGN/mglu2010v5_0.zip"

download_inegi localidades-rurales50.zip "http://mapserver.inegi.org.mx/MGN/mglr2010v5_0.zip"



