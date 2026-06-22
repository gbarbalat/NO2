#Pb 1 tu rates des moniteurs en z urbaine avec cette technique. Improve raster!!!
#Pb 2, vector is too big when using time as a dimension --- can fit after having extracted day after day on the overall dataset 
#and predict day after day

#areas where pop > 1500 density. Is a raster
#make it a shapefile
#create grid of 200m
#make it a raster. File is called cities_2022 (should be cities_2020)
#create sf union of this file so that it can be used to crop future rasters. File is called cities_2020_sf_union
#create raster of predictions

rm(list=ls())

library(stars)
library(dplyr)
load_monitors=1
source("header_200m.R")

####################################################################"
#build up raster 200m 
load(paste0("/bettik/barbalag/all_predict_ens1_", current_year,".RData"))
r_=list()

library(parallel)
nc=detectCores()
pred_to_rast=function(i){

file_read = all_predict_ens1 %>% filter(all_time_sub==i) %>%
  select(-c(all_predRanger_sub,all_predXGB_sub,all_predcatboost_sub)) %>% 
  rename(x=all_X_sub,y=all_Y_sub, time=all_time_sub) %>%
  st_as_stars(coords = c("x","y")) %>%
  st_set_crs(2154) %>% st_crop(france_sf) %>% st_warp(france_grid) 
print(i)

if (use_st_nearest_point) file_read=complete_raster(file_read)

}

r_=lapply(1:days_in_total,pred_to_rast)


save(r_,file=paste0(current_year,"_pred_res_200.RData"))


####################################################################"
#extract at monitors (no2.sf then intersected_mon from header) and join with monitor data

extract_at_mon=function(x) {
output=r_[[x]] %>% 
  st_extract(at=intersected_mon %>% filter(time==x) 
             #,time_column="time"
             ) %>% 
  st_join(intersected_mon %>% filter(time==x)) %>%
  filter(time.x==time.y) %>% mutate(time=time.x) %>%
  mutate(resid=predict_ens1-day_mean) %>% select(-all_of(starts_with("time.")))
}
nc=detectCores()
sf_=lapply(1:days_in_total,extract_at_mon)
save(sf_, file=paste0(current_year,"_pred_res_mon_at_mon.RData"))
