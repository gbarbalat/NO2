rm(list=ls())

setwd("/bettik/barbalag/FINAL PREDS/")

library(mgcv)
library(reshape2)
library(ggplot2)
library(data.table)
library(dplyr)
library(stars)
library(sf)
library(lubridate)
library(zoo)
library(fst)

path_1km="/bettik/barbalag/output_for_plots/"
path_200m="/bettik/barbalag/200m_header/"

#/*
current_year <- 2023
args <- commandArgs(TRUE); current_month <- as.numeric(args[1]) ; #current_month <- 3
leap_years <- c(2000,2004,2008,2012,2016,20202, 2024,2028)

# Define the day-of-year boundaries for standard months (1 to 12)
month_starts <- c(1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335)
month_ends   <- c(31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365)
if (current_year %in% leap_years & current_month==2) {
  month_starts <- c(1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336)
  month_ends   <- c(31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366)
}

ndays <- month_ends[current_month] - month_starts[current_month] + 1
#*/



#for cropping
france_sf_nobuff_2154 = st_as_sf(maps::map(database = "france", plot = FALSE, fill = TRUE)) %>% st_transform(crs=2154) %>%
  filter(ID!="Corse du Sud") %>%
  filter(ID!="Haute-Corse") %>%
  st_make_valid()

load("france_sf_urban.RData"); france_sf_urban=france_sf
france_sf_not_urban=st_difference(france_sf_nobuff_2154,france_sf_urban)

#===============================================================================
# Load 200m map
#===============================================================================
MPI=TRUE

#/*
# all_predict_ens1_l=list()
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_1.RData")); all_predict_ens1_l[[1]]=all_predict_ens1; min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_2.RData")); all_predict_ens1_l[[2]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_3.RData")); all_predict_ens1_l[[3]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_4.RData")); all_predict_ens1_l[[4]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_5.RData")); all_predict_ens1_l[[5]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_6.RData")); all_predict_ens1_l[[6]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_7.RData")); all_predict_ens1_l[[7]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_8.RData")); all_predict_ens1_l[[8]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_9.RData")); all_predict_ens1_l[[9]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_10.RData")); all_predict_ens1_l[[10]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_11.RData")); all_predict_ens1_l[[11]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
# load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_12.RData")); all_predict_ens1_l[[12]]=all_predict_ens1;min(all_predict_ens1$all_time_sub); max(all_predict_ens1$all_time_sub)
load(paste0("/bettik/barbalag/200m_header/",current_year,"/all_predict_ens1_",current_year,"_", current_month, ".RData")); 
print(min(all_predict_ens1$all_time_sub));
print(max(all_predict_ens1$all_time_sub));
month_starts <- min(all_predict_ens1$all_time_sub)
month_ends <- max(all_predict_ens1$all_time_sub)
ndays <- month_ends - month_starts + 1
#all_predict_ens1_200m <- rbindlist(all_predict_ens1_l);
all_predict_ens1_200m <- all_predict_ens1;
#*/

all_predict_ens1_200m <- all_predict_ens1_200m %>% 
  rename(x=all_x_sub,y=all_y_sub, time=all_time_sub, predictions=predict_ens1) %>%
  select(-c(all_predRanger_sub,all_predXGB_sub,all_predcatboost_sub)) %>% 
  st_as_sf(coords=c("x","y")) %>% st_set_crs(st_crs(2154)) 

print(paste0(current_month,":nrow is of ",nrow(all_predict_ens1_200m)))
if (any(is.na(all_predict_ens1_200m[, 1:3]))) {
  print(paste0(current_month,":NA in all_predict_ens1_200m."))
}


#===============================================================================
# Load 1km map
#===============================================================================
#/*
load(paste0(path_1km,"all_predict_ens1_", current_year,".RData"));#nrow(all_predict_ens1); 
#load(paste0(path_1km,"all_predict_ens1_month", current_month, "_", current_year,".RData"));
#*/

all_predict_ens1_1km =all_predict_ens1 %>% 
  rename(x=all_X_sub,y=all_Y_sub, time=all_time_sub, predictions=predict_ens1) %>%
  #/*
  # Filter 'time' dynamically based on the 'month' variable row-by-row
  #filter(time >= month_starts[current_month] & time <= month_ends[current_month]) %>%
  filter(time >= month_starts & time <= month_ends) %>%
  
  #*/
  select(-c(all_predRanger_sub,all_predXGB_sub,all_predcatboost_sub)) # %>% st_as_sf(coords=c("x","y")) %>% st_set_crs(st_crs(2154))

print(paste0(current_month,":nrow is of ",nrow(all_predict_ens1_1km)))
if (any(is.na(all_predict_ens1_1km[, 1:3]))) {
  print(paste0(current_month,":NA in all_predict_ens1_1km."))
}



#===============================================================================
# START OF Function per day
#===============================================================================
get_sorted_200m_1day <- function(current_time) {

print(paste0(current_month,":",current_time))

#===============================================================================
# DAY BY DAY Final 1km predictions (in urban and not urban areas)
#===============================================================================
all_predict_ens1_1km_all_df <- all_predict_ens1_1km %>% filter(time==current_time)	
all_predict_ens1_1km_all_df[all_predict_ens1_1km_all_df<0] <- 0

print(paste0(current_month,":nrow is of ",nrow(all_predict_ens1_1km_all_df)))
if (any(is.na(all_predict_ens1_1km_all_df[, 1:3]))) {
  print(paste0(current_month,":",current_time,":NA in all_predict_ens1_1km_all_df ."))
}

#===============================================================================
# DAY BY DAY Final 200m predictions in urban area = 1km + residuals @200m
#===============================================================================
#raster 200m of residuals
r200_resid <- all_predict_ens1_200m %>% filter(time==current_time) %>% select(-time)  %>% st_rasterize(dx=200) # 

#raster 1km cropped to urban areas
r1km <- all_predict_ens1_1km %>% filter(time==current_time)  %>% select(-time) %>%
  	st_as_stars(coords=c("x","y")) %>% st_set_crs(st_crs(2154)) 
#raster 1 km downscaled to 200 m 
r200_1km <- st_warp(r1km, r200_resid) #%>% st_crop(france_sf_urban) 

#add 200m to 1 km predictions in urban areas
r200_tot <- r200_resid+r200_1km

#make df
all_predict_ens1_200m_urban_df <- r200_tot %>% as.data.frame %>% na.omit %>% mutate(time=current_time)
all_predict_ens1_200m_urban_df[all_predict_ens1_200m_urban_df<0] <- 0


print(paste0(current_month,":",current_time,":nrow:",nrow(all_predict_ens1_200m_urban_df)))
if (any(is.na(all_predict_ens1_200m_urban_df[, 1:3]))) {
  print(paste0(current_month,":",current_time,":NA in in all_predict_ens1_200m_urban_df ."))
}


return(list(all_predict_ens1_1km_all_df=all_predict_ens1_1km_all_df,all_predict_ens1_200m_urban_df=all_predict_ens1_200m_urban_df))

}#end of get_sorted_200m_1day function
#===============================================================================
# END OF Function per day
#===============================================================================
#/*
# result <- lapply(1:max(all_predict_ens1_200m$time),get_sorted_200m_1day)
result <- lapply(month_starts:month_ends,get_sorted_200m_1day)

#*/

combined_1km <- rbindlist(lapply(result, function(x) x$all_predict_ens1_1km_all_df))
combined_200m <- rbindlist(lapply(result, function(x) x$all_predict_ens1_200m_urban_df))

write.fst(combined_1km, paste0(current_year,"_1km_" , current_month, ".fst"))
write.fst(combined_200m, paste0(current_year,"_200m_", current_month, ".fst"))
