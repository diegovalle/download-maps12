Download Mexican maps
=====================

You'll need to have __wget__, __gdal__, and __R__ installed to run the program. Just run

 ```
make
 ```

Since the scripts download a whole bunch of maps it may take a while to finish

In the map-out directory you'll find

* distritos: Shapefile of the electoral distritos (districts)
* secciones: Shapefile of electoral secciones (precincts)
* estados: Shapefile of the Mexican states
* localidades: Shapefile of the rural localities and the polygons of the urban ones
* municipios: Shapefile of the counties of Mexico
* rdata-secciones: serialized secciones (precincts) as an R object


Since the IFE uses a different coding standard for the municipalities of Mexico I've recoded them so that they match the INEGI codes. 

 ```
México, Ecatepec according to the INEGI is 15 033 while according to the IFE it's 15 034
Jalisco, Guadalajara according to the INEGI is 14 039 while according to the IFE it's 14 041
```

These codes are only available for the secciones electorales(precincts) shapefile and they are contained in the variables:

* MUN_INEGI: The inegi municipio codes
* MUN_IFE: The original ife municipio codes that came with the file

The codebook for the the census data that comes with the shapefiles is in the FD_SECC_IFE.pdf file and the ife and inegi codes are in the ife.to.inegi.csv file
