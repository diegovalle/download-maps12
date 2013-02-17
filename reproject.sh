#!/bin/bash 
#Reproject the shapefiles so that you can use the maps from
#google earth or ggplot
PROJECTION="+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

function reproject {
  ogr2ogr map-out/$1 unzip/mexico/$2 -t_srs "+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"
}

#reproject /estados/estados.shp ESTADOS.shp
#reproject /municipios/municipios.shp MUNICIPIOS.shp
#reproject /localidades/localidades-urbanas.shp POLIGONOS_URBANOS.shp
#reproject /localidades/localidades-rurales.shp LOCALIDADES_RURALES.shp

