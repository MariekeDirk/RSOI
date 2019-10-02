library(data.table)
library(tidyr)
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

save(TN_observations, file="data/TN_observations.rda")