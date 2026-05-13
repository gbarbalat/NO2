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
#args <- commandArgs(TRUE); current_year <- as.numeric(args[1]) 
current_year <- 2000
leap_years <- c(2000,2004,2008,2012,2016,2020)
ndays <- ifelse(current_year %in% leap_years,366,365)
print(paste0(current_year,":",ndays))


#===============================================================================
# Load 1km map
#===============================================================================
load(paste0(path_1km,"all_predict_ens1_", current_year,".RData"));#nrow(all_predict_ens1); #summary(all_predict_ens1[,1:3])
all_predict_ens1_1km =all_predict_ens1 %>% 
  rename(x=all_X_sub,y=all_Y_sub, time=all_time_sub, predictions=predict_ens1) %>%
  select(-c(all_predRanger_sub,all_predXGB_sub,all_predcatboost_sub)) # %>% st_as_sf(coords=c("x","y")) %>% st_set_crs(st_crs(2154))
if (nrow(all_predict_ens1_1km) != 591869 * ndays) {
  print(paste0(current_year,":The number of rows in all_predict_ens1_1km is not what it should be."))
}
if (any(is.na(all_predict_ens1_1km[, 1:3]))) {
  print(paste0(current_year,":NA in all_predict_ens1_1km."))
}

#===============================================================================
# START OF Function per day
#===============================================================================
get_sorted_1km_1day <- function(current_time) {

print(paste0(current_year,":",current_time))

#===============================================================================
# DAY BY DAY Final 1km predictions (in urban and not urban areas)
#===============================================================================
all_predict_ens1_1km_all_df <- all_predict_ens1_1km %>% filter(time==current_time)	
all_predict_ens1_1km_all_df[all_predict_ens1_1km_all_df<0] <- 0
if (nrow(all_predict_ens1_1km_all_df) != 540261) {
  print(paste0(current_year,":",current_time,":The number of rows in all_predict_ens1_1km_all_df is not 540261."))
  print(paste0(current_year,":nrow is of ",nrow(all_predict_ens1_1km_all_df)))
}
if (any(is.na(all_predict_ens1_1km_all_df[, 1:3]))) {
  print(paste0(current_year,":",current_time,":NA in all_predict_ens1_1km_all_df ."))
}


return(all_predict_ens1_1km_all_df)

}#end of get_sorted_1km_1day function
#===============================================================================
# END OF Function per day
#===============================================================================

result <- lapply(1:max(all_predict_ens1_1km$time),get_sorted_1km_1day)
combined_1km <- rbindlist(result)
write.fst(combined_1km, paste0(current_year,"_1km.fst"))