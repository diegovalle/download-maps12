########################################################
## Author: Diego Valle-Jones
## Website: www.diegovalle.net
## Date Created: Thu Feb 21 18:37:03 2013
## Email: diegovalle at gmail.com
## Purpose: Recode the municipality codes that the IFE uses to the ones used by the INEGI
## Copyright (c) Diego Valle-Jones. All rights reserved


##library(rgeos)
##install necessary packages if they are not already installed
##http://stackoverflow.com/questions/4090169/elegant-way-to-check-for-missing-packages-and-install-them
list.of.packages <- c("rgdal", "maptools", "stringr", "doBy", "testthat", "data.table", "rgeos")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(data.table)
library(rgdal)
library(maptools)
library(stringr)
library(doBy)
library(testthat)
##gpclibPermit()

##Read a file containing the inegi fips codes
inegi.mun <- read.csv("data/municipios-inegi.csv",
                fileEncoding = "windows-1252", sep = ";")
##capitalization just makes it more dificult to match names, also
##Prepend the state number to deal with duplicate municipality names
inegi.mun$id <- tolower(with(inegi.mun, str_c(CVE_ENT, ", ", NOM_MUN)) )


##read a bunch of files containing the ife fips codes
##downloaded from http://www.ife.org.mx/portal/site/ifev2/Detalle_geografia_electoral_y_cartografia_transparencia/?vgnextoid=04a9d8bd4ac04210VgnVCM1000000c68000aRCRD
dirs <- list.dirs("ife")[2:33]
ife.mun <- data.frame()
##read the files with the ife names for each state
for(d in dirs) {
  temp <- read.csv(file.path(d, list.files(d)[3]), fileEncoding = "windows-1252")
  ife.mun <- rbind(temp, ife.mun)
}
##subset the variables we need
ife.mun <- ife.mun[,c("Entidad","Municipio","Nom_mun")]
##capitalization just makes it more dificult to match names
ife.mun$Nom_mun <- tolower(ife.mun$Nom_mun)
##Prepend the state number to deal with duplicate municipality names
ife.mun$id <- str_c(ife.mun$Entidad, ", ",ife.mun$Nom_mun)

##A data frame with both the inegi and ife codes merged by municipality names
##make sure all the ife data is preserved
good <- merge(inegi.mun, ife.mun, all.y = TRUE, by = "id")

#write.csv(good, "good.csv")
test_that("no nulls in the IFE municipalities", 
{expect_that(nrow(good[which(is.na(good$NOM_ENT)),]), equals(0))})

test_that("same number of municipalities", 
{expect_that(length(unique(good$id.inegi)), equals(length(unique(good$id.ife))))})



#test_that("all ife municipalities were assigned an INEGI code", 
#{expect_that(nrow(good[which(is.na(good$id.inegi)),]), equals(0))})

##Standarize the formats for the ids
good$code <-  str_c(str_replace(format(good$Entidad, width = 2), " ", "0"),
                    str_replace_all(format(good$Distrito, width = 3), " ", "0"),
                    str_replace_all(format(good$Seccion, width = 4), " ", "0"))
good$id.ife <-  str_c(str_replace(format(good$Entidad, width = 2), " ", "0"),
                    str_replace_all(format(good$Municipio, width = 3), " ", "0"))
good$id.inegi <-  str_c(str_replace(format(good$CVE_ENT, width = 2), " ", "0"),
                      str_replace_all(format(good$CVE_MUN, width = 3), " ", "0"))


##only the unique translation table without all the
##information by precinct
ife.to.inegi <- unique(data.frame(id.ife = good$id.ife, 
                  id.inegi = good$id.inegi, 
                  name = good$Nom_mun))
ife.to.inegi$id.inegi <- as.character(ife.to.inegi$id.inegi)
#a <- as.vector(ife.to.inegi$name)
##get rid of the phantom 000 municipality
ife.to.inegi <- subset(ife.to.inegi, id.ife != "09000")


#remove pachuca de soto 13040
#remove mineral 13047
#remove miguel hidalgo 09000
#San Pedro Mixtepec - Distrito 26 - 20317 = 20319
#San Pedro Mixtepec - Distrito 22 - 20316 = 20318
#San Juan Mixtepec Distrito 08 - 20208
#San Juan Mixtepec Distrito 26 - 20209
# ife.to.inegi[ife.to.inegi$name %in% c("mineral de la reforma",
#                                       "pachuca de soto",
#                                       "san juan mixtepec",
#                                       "san pedro mixtepec",
#                                       "miguel hidalgo"
# ),]



ife.to.inegi<- subset(ife.to.inegi, (id.ife != "13040" | name != "pachuca de soto"))

ife.to.inegi <- subset(ife.to.inegi, id.ife != "13047" | name != "mineral de la reforma")

##there are two municipalities named san juan mixtepec in Oaxaca
##I used the online map to visually determine which one was which
ife.to.inegi[which(ife.to.inegi$id.ife == "20209"),]$id.inegi <- "20209"
##there are two municipalities named san pedro mixtepec in Oaxaca
##I used the online map to visually determine which one was which
ife.to.inegi[which(ife.to.inegi$id.ife == "20317"),]$id.inegi <- "20319"
ife.to.inegi[which(ife.to.inegi$id.ife == "20316"),]$id.inegi <- "20318"

ife.to.inegi$id.ife <- as.numeric(as.character(ife.to.inegi$id.ife))
ife.to.inegi$id.inegi <- as.numeric(as.character(ife.to.inegi$id.inegi))
ife.to.inegi$name <- as.character(ife.to.inegi$name)

##Some missing municipalites
##Replace San Ignacio Cerro Gordo with Arandas to match the population data?
##Ans: for the time being leave as San Ignacio Cerro Gordo
##San Ignacio Cerro Gordo was part of Arandas before being created
##SICG inegi 14 125 - Arandas inegi 14 008

##Some municipalities are missing from the información geoestadística censal
##but are present in the shapefile
##I used the interactive map to visually match them with the inegi ones:
##Cochoapa el Grande (ife 12079 - inegi 12078)
##Marquelia (ife 12080 - inegi 12077)
##Juchitán (ife 12081 - inegi 12080)
##San Ignacio Cerro Gordo (created in 2006) (ife 14125 - inegi 14125)
ife.to.inegi <- rbind(ife.to.inegi, data.frame(id.ife = c(12079, 12080, 12081, 14125),
           id.inegi = c(12078, 12077, 12080, 14125),
           name = c("Cochoapa", "Marquelia", "Juchitán", "San Ignacio Cerro Gordo")))

test_that("same number of municipalities", 
{expect_that(length(unique(ife.to.inegi$id.inegi)),
             equals(length(unique(ife.to.inegi$id.ife))))})



##write the result to disk
write.csv(ife.to.inegi[,1:2], "ife.to.inegi.csv", row.names = FALSE)


message("\n\n\nReading Secciones Shapefile (may take awhile...)\n\n\n")
seccion <- readOGR(file.path("unzip", "seccion"), "mx_secciones_ife")
##seccion <- load(file.path("map-out", "rdata-secciones"), "secciones.RData")

v <- as.numeric(str_c(str_sub(seccion@data$CLAVEGEO, 1 , 2), str_sub(seccion@data$CLAVEGEO, 6, 8)))
#v <- as.numeric(str_c(seccion@data$ENTIDAD, 
#                      gsub(" ", "0", format(seccion@data$MUNICIPIO, width = 3))))
##a <- data.frame(sort(unique(v)), sort(ife.to.inegi$id.ife))
test_that("the ife codes are equal to the ones in the map",
          {expect_that(all.equal(sort(unique(v)), sort(ife.to.inegi$id.ife)), equals(TRUE))})


v <-recodeVar(v, 
              ife.to.inegi$id.ife, 
              ife.to.inegi$id.inegi, 
              default = NA)

seccion@data$MUN_IFE <- str_sub(seccion@data$CLAVEGEO, 6, 8)
seccion@data$MUNICIPIO <- NULL
seccion@data$MUN_INEGI <- str_sub(v, 3)
##plot(secc)


##test that the recoding went correctly
idx <- sample(1:length(seccion@data$MUN_INEGI), 1000)
for(i in idx)
  test_that("municipality codes match the ife to inegi trancoding",
            {expect_that(seccion@data$MUN_INEGI[i] ==
              as.numeric(str_sub(ife.to.inegi[which(ife.to.inegi$id.ife == 
                                            as.numeric(str_c(seccion@data$ENTIDAD[i], 
                                                             gsub(" ", "0", format(seccion@data$MUN_IFE[i], 
                                                                                   width = 3))))),]$id.inegi, 3)),
                        equals(TRUE))})

test_that("no nulls in the INEGI municipalities", 
          {expect_that(all(is.na(seccion@data$MUN_INEGI)), equals(FALSE))})

writeOGR(seccion, "map-out/secciones-inegi", "secciones", driver="ESRI Shapefile",
         overwrite_layer=TRUE)
save(seccion, file = file.path("map-out","rdata-secciones", "secciones.RData"))
##load(file.path("map-out","rdata-secciones", "secciones.RData"))

# replace0 <- function(str) {str_replace_all(str, " ", "0")}
# createCode <- function(StateCode, MunCode){
#   replace0(str_c(format(StateCode, width = 2),
#                     format(MunCode, width = 3)))
# }
# 
# 
# seccion@data$id <- createCode(seccion@data$ENTIDAD, seccion@data$MUN_INEGI)
# unique(seccion@data$id)
# nrow(ife.to.inegi)
# 
# DT <- data.table(seccion@data)
# DT$id <- createCode(DT$ENTIDAD, DT$MUN_INEGI)
# DT[, list(P_15A17_F=sum(P_15A17_F)), by = list(id)]

##Dissolve the secciones into counties
##NOT DONE
## message("creating shapefile of the ife municipios... may take awhile")
## ife.muns <- NULL
## for(i in seq_along(1:32)) {
  
##   DissolveResult <- unionSpatialPolygons(seccion[seccion@data$ENTIDAD == i,],
##                                          seccion@data$MUN_IFE[seccion@data$ENTIDAD == i],
##                                          threshold = 50000000000000)
##   DissolveResult <- spChFIDs(DissolveResult,
##                              paste(i, sapply(slot(DissolveResult, "polygons"), slot, "ID"),
##                                    sep="_"))

##   if(!is.null(ife.muns))
##     ife.muns <- spRbind(ife.muns, DissolveResult)
##   else
##     ife.muns <- DissolveResult
##   message(str_c("dissolved state ", i, " of 32"))
## }
## plot(ife.muns)

## data <- data.frame(NewID = row.names(ife.muns))
## row.names(data) <- row.names(ife.muns)

## writeOGR(SpatialPolygonsDataFrame(ife.muns, data),
## "map-out/municipios-ife", "municipios-ife", driver="ESRI Shapefile",
##          overwrite_layer=TRUE)
