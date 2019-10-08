library(data.table)
library(tidyr)
library(raster)
library(zoo)

#TN Netherlands from 1906 until 2019 oct
TN_observations<-fread("/net/pc150400/nobackup/users/dirksen/data/AWS/TN_monthly_1906_2019.csv")
TN_observations<-subset(TN_observations,select=c(1,2,3))
TN_observations$DS_CODE<-gsub("_H","",TN_observations$DS_CODE)
TN_observations$IT_DATETIME<-format(as.Date(as.yearmon(TN_observations$IT_DATETIME,format="%Y%m"),format="%b %Y"),"%Y.%m")
TN_observations<-tidyr::spread(TN_observations,DS_CODE,REH3.TNG)

stations<-fread("/net/pc150400/nobackup/users/dirksen/data/AWS/coordinates_stations.csv")
stations$STN<-gsub(":","",stations$STN)
stations.x<-subset(stations,select = c(2))
stations.y<-subset(stations,select = c(3))

stations.x<-data.frame(t(stations.x)); colnames(stations.x)<-stations$STN
stations.y<-data.frame(t(stations.y)); colnames(stations.y)<-stations$STN

attr(TN_observations,"x")<-stations.x
attr(TN_observations,"y")<-stations.y

#1)observations for the reference period
t.start<-which(TN_observations$IT_DATETIME=="1990.01")
t.stop<-which(TN_observations$IT_DATETIME=="2017.12")

TN_reference<-TN_observations[t.start:t.stop,]
TN_reference<-TN_reference[,-4]
save(TN_reference,file="data/TN_reference.rda")

#2)observations for the interpolation
save(TN_observations, file="data/TN_observations.rda")

#Gridded files for RSOI
ok_NL<-stack("/net/pc150400/nobackup/users/dirksen/data/Temperature/climatology/ok.grd")[[2]] #second layer is the median Temperature
ok_NL<-projectRaster(ok_NL,crs = CRS("+init=epsg:4326"))
#3 dimensional array with x,y,time
LON<-coordinates(ok_NL)[,1]
LAT<-coordinates(ok_NL)[,2]
Zcol<-TN_observations$IT_DATETIME
sp_grid_nl<-array()
attr(sp_grid_nl,"x")<-LON
attr(sp_grid_nl,"y")<-LAT
attr(sp_grid_nl,"time")<-Zcol

#1)reference grid 1990-2017
save(ok_NL,file = "data/ok_NL.rda")
#2)empty grid for the interpolation
save(sp_grid_nl, file="data/sp_grid_nl.rda")

##########################################################################################
#Precipitation data Indonesia
work_dir<-"/net/pc150400/nobackup/users/dirksen/data/Precipitation_Indonesia/"
data1890<-"/forMarieke_1890/"
data1910<-"/forMarieke_1910/"
data1930<-"/forMarieke_1930/"
data1950<-"/forMarieke_1950/"
RR_obs<-list.files(path=paste0(work_dir,data1890))
RR_STAID<-gsub("RR_STAID","",RR_obs)
RR_STAID<-gsub(".txt","",RR_STAID)

#station file contains names and staid
stations<-fread(paste0(work_dir,"/forMarieke_1890/station.txt"))
