library(data.table)
library(plyr)
library(reshape2)
library(rgdal)
library(ggplot2)
library(maptools)
library(stringr)
library(grid)
library(Hmisc)
library(doBy)
library(testthat)

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
ife.mun <- ife.mun[,c("Entidad","Distrito", "Seccion","Municipio","Nom_mun")]
##capitalization just makes it more dificult to match names
ife.mun$Nom_mun <- tolower(ife.mun$Nom_mun)
##Prepend the state number to deal with duplicate municipality names
ife.mun$id <- str_c(ife.mun$Entidad, ", ",ife.mun$Nom_mun)

##A data frame with both the inegi and ife codes merged by municipality names
##make sure all the ife data is preserved
good <- merge(inegi.mun, ife.mun, all.y = TRUE, by = "id")

#write.csv(good, "good.csv")
good[which(is.na(good$NOM_ENT)),]

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
ife.to.inegi[ife.to.inegi$name %in% c("mineral de la reforma",
                                      "pachuca de soto",
                                      "san juan mixtepec",
                                      "san pedro mixtepec",
                                      "miguel hidalgo"
),]



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
##leave as the San Ignacio Cerro Gordo
ife.to.inegi <- rbind(ife.to.inegi, data.frame(id.ife = c(12079, 12080, 12081, 14125),
           id.inegi = c(12079, 12080, 12081, 14125),
           name = c("José Joaquin de Herrera", "Juchitán", "Iliatenco", "Arandas")))

##write the result to disk
write.csv(ife.to.inegi[,1:2], "ife.to.inegi.csv", row.names = FALSE)



seccion <- readOGR(file.path("unzip", "seccion"), "mx_secciones_ife")


v <- as.numeric(str_c(seccion@data$ENTIDAD, 
                      gsub(" ", "0", format(seccion@data$MUNICIPIO, width = 3))))
##a <- data.frame(sort(unique(v)), sort(ife.to.inegi$id.ife))
test_that("the ife codes are equal to the ones in the map",
          {expect_that(all.equal(sort(unique(v)), c(sort(ife.to.inegi$id.ife))), equals(TRUE))})


v <-recodeVar(v, 
              ife.to.inegi$id.ife, 
              ife.to.inegi$id.inegi, 
              default = NA)

seccion@data$MUN_IFE <- seccion@data$MUNICIPIO
seccion@data$MUNICIPIO <- NULL
seccion@data$MUN_INEGI <- as.numeric(str_sub(v, 3))
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
save(seccion, file = file.path("map-out","rdata-secciones", "secciones.Rdata"))



