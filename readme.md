Download Mexican maps
=====================

You'll need to have __wget__ and __gdal__ installed to download the maps and then

 ```
make
 ```

Since it downloads a bunch a whole bunch of maps it may take a while to run

In the map-out directory you'll find

* distritos: Shapefile of the electoral distritos (districts)
* secciones: Shapefile of electoral secciones (precincts)
* estados: Shapefile of the Mexican states
* localidades: Shapefile of the rural localities and the polygons of the urban ones
* municipios: Shapefile of the counties of Mexico
* rdata-secciones: serialized secciones (precincts) as an R object


Since the IFE uses a different coding standard for the municipalities of Mexico I've recoded them so that they match the INEGI codes. These codes are only available for the secciones electorales(precincts) shapefile and they are contained in the variables:

* MUN_INEGI: The inegi municipio codes
* MUN_IFE: The original ife municipio codes that came with the file

The codebook for the electoral shapefiles is in the FD_SECC_IFE.pdf file
