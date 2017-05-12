MKDIR=mkdir -p
R=Rscript
CHMOD=chmod +x 

default: all

all: dirs download download-censales otros unzip merge reproject recode

dirs: 
	for file in zip zip/distrito zip/mexico zip/seccion unzip unzip/distrito unzip/mexico unzip/seccion ife map-out map-out/distritos map-out/estados map-out/localidades map-out/municipios map-out/rdata-secciones map-out/secciones-inegi ; do \
		$(MKDIR) $$file ; \
	done

download: dirs
	./download.sh

download-censales: dirs
	./download-censales.sh

otros: dirs
	./otros.sh

unzip: dirs download download-censales
	./unzip.sh

merge: dirs download download-censales unzip
	./merge.sh

reproject: dirs download download-censales unzip merge
	./reproject.sh

recode: download download-censales unzip merge
	$(R) recode.R

clean: 
	for dirs in unzip zip ife map-out ; do \
		rm -rf $$dirs ; \
	done
	rm -rf ife.to.inegi.csv

clean-cache: 
	for dirs in unzip zip ife ; do \
		rm -rf $$dirs ; \
	done

