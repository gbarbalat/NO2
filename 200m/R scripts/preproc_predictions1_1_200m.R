rm(list=ls())

library(stars)
library(dplyr)

load_monitors=0
source("header_200m.R")

####################################################################"
#build up raster 200m 
load(paste0("/bettik/barbalag/all_predict_ens1_", current_year,".RData"))
r_=list()

library(parallel)
nc=detectCores()

r_=lapply(1:61,pred_to_rast)



save(r_,file=paste0(current_year,"_pred_res1.RData"))