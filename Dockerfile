FROM rocker/r-base

WORKDIR /download-maps12

RUN echo "deb http://httpredir.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list
RUN apt-get -y update && apt-get install gnupg software-properties-common -y
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FC6FA5EB4357B38A
RUN add-apt-repository ppa:arx/release && apt-get update &&\
    apt-get install innoextract -y
RUN apt-get install -y curl gdal-bin libgdal-dev git p7zip-full p7zip-rar rename
RUN git clone https://github.com/diegovalle/download-maps12 .
RUN Rscript --slave --no-save --no-restore-history -e "list.of.packages <- c('rgdal', 'rgeos', 'maptools', 'stringr', 'doBy', 'testthat', 'data.table');new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,'Package'])];if(length(new.packages)) install.packages(new.packages)"
# Create the directory for downloading the shapefiles
RUN mkdir -p /download-maps12/map-out &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/bin/bash"]
