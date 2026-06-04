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

# 1. Re-create your date sequence for the grid
dates_sequence <- seq(as.Date(paste0(current_year, "-01-01")), by = "1 day", length.out = days_in_total)

# 2. Fix the stars grid dimension
data4_Model2 <- data4_Model2 %>%
  st_set_dimensions(which = "time", values = dates_sequence)

# 3. FIX THE MONITOR COORDINATES:
# Convert the integer time (1, 2, 3...) in your points to the matching Date object
monitor_coord <- monitor_coord %>%
  mutate(time = dates_sequence[as.numeric(time)])

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

for (i in 3:40) {#DO NOT take out OMI as you are taking "predictions", DO NOT take CAMS so start from 3
file_is=paste0("updated_DMraster_France_var",i,"_",current_year,".RData")#is a raster 
load(file=paste0(path_to,file_is)) 
#st_crs(data4_Model2)=2154
# Fix the stars grid dimension
updated_DMraster <- updated_DMraster %>%
  st_set_dimensions(which = "time", values = dates_sequence)


tmp = updated_DMraster %>% 
		st_extract(at=monitor_coord, time_column="time") %>% 
 		#st_join(monitor_coord) %>%
		#filter(time.x==time.y) %>%
		#mutate(time=time.y) %>%
		select(-all_of(starts_with("time"))) %>%
		st_drop_geometry() 

df_final_Model2= df_final_Model2 %>% cbind(tmp)

print(i)
}

(head(df_final_Model2))
save(df_final_Model2,file=paste0("df_final_Model2_",current_year,".RData"))

df_final_Model2$spacevar=paste0(df_final_Model2$X,"-",df_final_Model2$Y)
print(nrow(df_final_Model2))
print(length(unique(df_final_Model2$spacevar)))
print("this needs to match the nb of monitors for that year")

end_time=Sys.time()
print(end_time-start_time)
