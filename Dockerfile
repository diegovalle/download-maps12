FROM rocker/r-base

WORKDIR /download-maps12

RUN echo "deb http://httpredir.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list
RUN apt-get -y update && apt-get install software-properties-common -y
RUN add-apt-repository ppa:arx/release && apt-get update &&\
    apt-get install innoextract -y
RUN apt-get install -y curl gdal-bin libgdal-dev git p7zip-full p7zip-rar rename
RUN git clone https://github.com/diegovalle/download-maps12 .
# Create the directory for downloading the shapefiles
RUN mkdir -p /download-maps12/map-out &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/bin/bash"]