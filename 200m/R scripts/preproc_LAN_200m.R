##########
#DMSP or VIIRS
##########
load_monitors=1
source("header_200m.R")

#france grid as a raster
#france sf to crop

if (VIIRS) {

here_data_VIIRS=paste0(here_data,"VIIRS/")

load(paste0(here_data_VIIRS,"VIIRS_200m_",current_year,".RData"))

if (use_st_nearest_point) file_read=complete_raster(file_read)

r_=list()
for (i in (1:days_in_total)) {
  r_[[i]]=file_read  
  names(r_[[i]])="LAN"
  print(i)
}
#raster
save(r_, file=paste0(current_year,"_LAN_200.RData"))

####################################################################"
#extract at monitors function from hdr

sf_=lapply(1:days_in_total,extract_at_mon)
save(sf_, file=paste0(current_year,"_LAN_at_mon.RData"))

}

if (DMSP) {
here_data_DMSP=paste0(here_data,"DMSP/")

file_read <- read_stars(paste0(here_data_DMSP,current_year,
                ".v4c_web.stable_lights.avg_vis.tif")) %>%
	 st_warp(france_grid) %>%
	 st_crop(france_sf)

if (use_st_nearest_point) file_read=complete_raster(file_read)


r_=list()
for (i in (1:days_in_total)) {
  r_[[i]]=file_read
  names(r_[[i]])="LAN"
  print(i)
}
#raster
save(r_, file=paste0(current_year,"_LAN_200.RData"))

####################################################################"
#extract at monitors function from hdr

sf_=lapply(1:days_in_total,extract_at_mon)
save(sf_, file=paste0(current_year,"_LAN_at_mon.RData"))

}

