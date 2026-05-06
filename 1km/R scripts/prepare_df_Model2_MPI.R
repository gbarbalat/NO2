close.screen(all=TRUE)
rm(list=ls())

source("header_MPI.R")

library(raster)
library(sf)
library(stars)
library(dplyr)

start_time=Sys.time()


###########################################
#Main path and libraries
#Load raw data
#clean raw dataslice
###########################################
path_to="/bettik/barbalag/"
#path_to="C:/Users/Guillaume/Desktop/PhD Epidemio_PROJECT/"


file_monitor=paste0("monitors_",current_year,".RData")#is a sf in the new method
load(file=paste0(path_to,file_monitor)) 
monitor_coord=no2.sf %>% mutate(time=datey) %>% select(-datey)


file_is=paste0("data4_Model2_",current_year,".RData")#is a raster of omi prediction
load(file=paste0(path_to,file_is)) 
st_crs(data4_Model2)=2154
df_final_Model2 = data4_Model2 %>% 
		st_extract(at=monitor_coord, time_column="time") %>% 
 		st_join(monitor_coord) %>%
		filter(time.x==time.y) %>%
		mutate(time=time.y) %>%
		select(-all_of(starts_with("time.")))  #%>% select(-c("x","y"))
coords=st_coordinates(df_final_Model2)
df_final_Model2 =df_final_Model2 %>% cbind(coords) %>% st_drop_geometry()
(head(df_final_Model2))
#save(df_final_Model2,file=paste0("df_final_Model2_var",2,"_",current_year,".RData"))

for (i in 3:40) {#take out OMI and CAMS
file_is=paste0("updated_DMraster_France_var",i,"_",current_year,".RData")#is a raster 
load(file=paste0(path_to,file_is)) 
#st_crs(data4_Model2)=2154

tmp = updated_DMraster %>% 
		st_extract(at=monitor_coord, time_column="time") %>% 
 		#st_join(monitor_coord) %>%
		#filter(time.x==time.y) %>%
		#mutate(time=time.y) %>%
		select(-all_of(starts_with("time"))) %>%
		st_drop_geometry() 

df_final_Model2= df_final_Model2 %>% cbind(tmp)
}

(head(df_final_Model2))
save(df_final_Model2,file=paste0("df_final_Model2_",current_year,".RData"))

df_final_Model2$spacevar=paste0(df_final_Model2$X,"-",df_final_Model2$Y)
print(nrow(df_final_Model2))
print(length(unique(df_final_Model2$spacevar)))
print("this needs to match the nb of monitors for that year")

end_time=Sys.time()
print(end_time-start_time)