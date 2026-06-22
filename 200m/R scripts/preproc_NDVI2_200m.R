##########
#NDVI
##########
load_monitors=1
source("header_200m.R")
#france_grid raster
#france_sf to crop

library(dplyr)
library(tidyr)
library(sf)
library(stars)
library(gstat)
library(lubridate)
library(doMC)
library(parallel)
library(foreach)
registerDoMC(cores=32)


use_st_nearest_point=TRUE

####################
here_data_NDVI=paste0(here_data,"NDVI/",current_year,"/")

load("x_NDVI.RData")

r_=list()
idx_r=1
for (i in 1:length(x)) {
	print(i)
	for (idx_x in 1:length(st_get_dimension_values(x[[i]],'time'))) {
	r_[[idx_r]]=x[[i]][,,,idx_x, drop=TRUE]
	names(r_[[idx_r]])="NDVI"
	idx_r=idx_r+1
	}
}
rm(x)
save(r_,file=paste0(current_year,"_NDVI_200.RData"))

####################################################################"
#extract at monitors function from hdr
library(parallel)
library(doMC)
nc=detectCores()

#sf_=mclapply(1:days_in_total,extract_at_mon,mc.cores=nc)
sf_=lapply(1:days_in_total,extract_at_mon)

save(sf_, file=paste0(current_year,"_NDVI_at_mon.RData"))