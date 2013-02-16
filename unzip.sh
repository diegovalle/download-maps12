#!/bin/bash 
for i in zip/mexico/*.zip
do      
  unzip $i -d unzip/mexico 
done

for i in zip/distrito/*.zip
do      
  unzip $i -d unzip/distrito 
done

for i in zip/seccion/*.zip
do      
  unzip $i -d unzip/seccion
done
