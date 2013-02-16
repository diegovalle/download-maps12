#!/bin/bash 
for i in zip/mexico/*.zip
do      
  unzip $i -d unzip/mexico 
done
