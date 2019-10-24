library(data.table)
library(lubridate)
library(tidyr)
library(raster)
library(zoo)
calc_months_nl==FALSE
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
#daily files

if(calc_months_nl==TRUE){
files_loc<-"/net/pc150400/nobackup/users/dirksen/data/Temperature/Aux_results/ok_model/prediction"
ok_NL<-lapply(list.files(files_loc,full.names=TRUE,pattern = ".grd"),stack)
ok_NL<-stack(ok_NL)

ok_NL_dates<-list.files(files_loc,pattern = ".grd")
ok_NL_dates<-gsub("temperature_kriging_pca_harmonie","",ok_NL_dates)
ok_NL_dates<-gsub(".grd","",ok_NL_dates)
ok_NL_dates<-format(as.Date(ok_NL_dates),"%Y.%m")
I<-as.factor(ok_NL_dates)

ok_NL<-stackApply(ok_NL,I,fun="mean",na.rm=TRUE)
names(ok_NL)<-levels(I)
ok_NL<-dropLayer(ok_NL,337)
ok_NL<-projectRaster(ok_NL,crs = CRS("+init=epsg:4326"))
}
ok_NL<-stack("D:/Temperature/ok_monthly.grd")
#3 dimensional array with x,y,time
LON<-coordinates(ok_NL)[,1]
LAT<-coordinates(ok_NL)[,2]
Zcol<-TN_observations$IT_DATETIME
sp_grid_nl<-array()
attr(sp_grid_nl,"x")<-LON
attr(sp_grid_nl,"y")<-LAT
attr(sp_grid_nl,"time")<-Zcol

#1)reference grid 1990-2017 4D [value,time,lat,lo]
save(ok_NL,file = "data/ok_NL.rda")
#2)empty grid for the interpolation 3D [time,lat,lon]
save(sp_grid_nl, file="data/sp_grid_nl.rda")

##########################################################################################
#Precipitation data Indonesia
obs_dir<-"/net/pc150400/nobackup/users/dirksen/data/Precipitation_Indonesia/forMarieke_1890/"
meta_dir<-"/net/pc150400/nobackup/users/dirksen/data/Precipitation_Indonesia/station_1890.txt"

obs_ref_dir<-"/net/pc150400/nobackup/users/dirksen/data/Precipitation_Indonesia/forMarieke_calibration_1980/"
meta_ref_dir<-"/net/pc150400/nobackup/users/dirksen/data/Precipitation_Indonesia/station_1980.txt"

prepare_indonesia<-function(obs_dir,meta_dir){
RR_obs<-list.files(path=obs_dir,full.names = TRUE)
RR_obs<-mapply(data.table::fread,RR_obs,MoreArgs = list(skip=20,header=FALSE,na.string="-9999"),SIMPLIFY = FALSE)
#RR_obs<-mapply(cbind,RR_obs,"ID"=RR_STAID,SIMPLIFY = FALSE)
RR_obs<-do.call("rbind",RR_obs)
names(RR_obs)<-c("ID","Year","Month","RR")
RR_obs$RR[which(RR_obs$RR<0)]<-NA


#get stations for a single year
# RR_obs<-RR_obs[complete.cases(RR_obs),]
# RR_obs<-RR_obs[which(RR_obs$Year==1890),]
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

stations.x<-subset(stations_1930,select = c(4))
stations.y<-subset(stations_1930,select = c(5))

stations.x<-data.frame((stations.x)); rownames(stations.x)<-stations_1930$ID #not transposed so the rownames are the column names of the other table, with the same order
stations.y<-data.frame((stations.y)); rownames(stations.y)<-stations_1930$ID

attr(RR_obs,"x")<-stations.x
attr(RR_obs,"y")<-stations.y
return(RR_obs)
}

RR_obs<-prepare_indonesia(obs_dir,meta_dir)
RR_ref<-prepare_indonesia(obs_ref_dir,meta_ref_dir)
save(RR_obs, file="data/RR_obs.rda")
save(RR_ref,file="data/RR_ref.rda")

#spatial station data for viewing and exploring purposes
sp.RR_stations<-stations_1930
sp.RR_stations$lat<-as.numeric(sp.RR_stations$lat)
sp.RR_stations$lon<-as.numeric(sp.RR_stations$lon)
coordinates(sp.RR_stations)<-~lon+lat
crs(sp.RR_stations)<-CRS("+init=epsg:4326")
save(sp.RR_stations,file="data/sp.RR_stations_1890.rda")

#Gridded data
# RR_ref_grid<-stack("/net/pc150400/nobackup/users/dirksen/data/Precipitation_Indonesia/rr_Indonesia.nc")
# RR_ref_grid[values(RR_ref_grid>4000)]<-NA

RR_ref_grid<-stack("D:/Precipitation_Indonesia/RR_ref_grid.grd")

#subset for JAVA
countries<-readOGR(dsn="D:/natural_earth/ne_10m_admin_1_states_provinces",layer = "ne_10m_admin_1_states_provinces")
Indonesia <- countries[countries$admin=="Indonesia",]
Java <- Indonesia[Indonesia$name=="Banten" |
                    Indonesia$name=="Jawa Barat" |
                    Indonesia$name=="Jakarta Raya" |
                    Indonesia$name=="Jawa Tengah" |
                    Indonesia$name=="Yogyakarta" |
                    Indonesia$name=="Jawa Timur" |
                    Indonesia$name=="Lampung",]
crs(Java)<-CRS("+init=epsg:4326")
Java<-gBuffer(Java,width = 1)
RR_ref_grid<-mask(RR_ref_grid,Java)

save(RR_ref_grid,file="data/RR_ref_grid.rda")

LON<-coordinates(RR_ref_grid)[,1]
LAT<-coordinates(RR_ref_grid)[,2]
Zcol<-RR_obs$IT_DATETIME
sp_grid_ind<-array()
attr(sp_grid_ind,"x")<-LON
attr(sp_grid_ind,"y")<-LAT
attr(sp_grid_ind,"time")<-Zcol
save(sp_grid_ind,file="data/sp_grid_ind.rda")

