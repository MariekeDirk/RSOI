library(data.table)
library(lubridate)
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
obs_dir<-"/net/pc150400/nobackup/users/dirksen/data/Precipitation_Indonesia/forMarieke_1930/"
meta_dir<-"/net/pc150400/nobackup/users/dirksen/data/Precipitation_Indonesia/station_1930.txt"

RR_obs<-list.files(path=obs_dir,full.names = TRUE)
RR_obs<-mapply(data.table::fread,RR_obs,MoreArgs = list(skip=20,header=FALSE,na.string="-9999"),SIMPLIFY = FALSE)
#RR_obs<-mapply(cbind,RR_obs,"ID"=RR_STAID,SIMPLIFY = FALSE)
RR_obs<-do.call("rbind",RR_obs)
names(RR_obs)<-c("ID","Year","Month","RR")
RR_obs$RR[which(RR_obs$RR<0)]<-NA

IDs<-data.frame(unique(RR_obs$ID));names(IDs)<-"ID"
#station file contains names and staid -->check if all the ID are similar!
stations<-fread(meta_dir)
names(stations)<-c("ID","name","type","lat","lon","value")
stations_1930<-merge(stations,IDs,by="ID")

stations_1930$lat<-gsub(":"," ",stations_1930$lat)
stations_1930$lon<-gsub(":"," ",stations_1930$lon)

stations_1930$lat = measurements::conv_unit(stations_1930$lat, from = 'deg_min_sec', to = 'dec_deg')
stations_1930$lon = measurements::conv_unit(stations_1930$lon, from = 'deg_min_sec', to = 'dec_deg')

length(stations_1930$ID)==length(IDs$ID)

#Prepare save files

#1)observations whole period with x,y coordinate attributes
RR_obs$IT_DATETIME<-format(as.Date(zoo::as.yearmon(paste0(RR_obs$Year,"-",RR_obs$Month)),format="%b %Y"),"%Y.%m")
RR_obs<-subset(RR_obs,select=c(5,1,4))
RR_obs<-tidyr::spread(RR_obs,ID,RR)

stations.x<-subset(stations_1890,select = c(4))
stations.y<-subset(stations_1890,select = c(5))

stations.x<-data.frame(t(stations.x)); colnames(stations.x)<-stations_1930$ID
stations.y<-data.frame(t(stations.y)); colnames(stations.y)<-stations_1930$ID

attr(RR_obs,"x")<-stations.x
attr(RR_obs,"y")<-stations.y

save(RR_obs, file="data/RR_obs.rda")

#spatial station data for viewing and exploring purposes
sp.RR_stations<-stations_1930
sp.RR_stations$lat<-as.numeric(sp.RR_stations$lat)
sp.RR_stations$lon<-as.numeric(sp.RR_stations$lon)
coordinates(sp.RR_stations)<-~lon+lat
crs(sp.RR_stations)<-CRS("+init=epsg:4326")
save(sp.RR_stations,file="data/sp.RR_stations.rda")

#2)observations for the reference period: ....-....
# t.start<-which(RR_obs$IT_DATETIME=="1990.01")
# t.stop<-which(RR_obs$IT_DATETIME=="2017.12")
#
# RR_reference<-RR_obs[t.start:t.stop,]
# RR_reference<-RR_reference[,-4]
# save(RR_reference,file="data/RR_reference.rda")

#3)grid for the reference period: ....-....
#4)empty grid with months to be interpolated
