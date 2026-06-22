###### 
#Elevation
###### 
load_monitors=1
source("header_200m.R")
#france sf to crop
#france_grid to warp
use_st_nearest_point=TRUE
#pop

here_data_elevation=paste0(here_data,"elevation/")

file_read=read_stars("/bettik/barbalag/data/elevation/eu_dem_v11_france_buf5km.tif") %>% st_warp(france_grid) %>% st_crop(france_sf)

if (use_st_nearest_point) file_read=complete_raster(file_read)

r_=list()
for (i in (1:days_in_total)) {#days_in_total
  r_[[i]]=file_read
  names(r_[[i]])="elevation"
  print(i)
}
#raster
save(r_, file=paste0(current_year,"_elevation_200.RData"))

####################################################################"
#extract at monitors function from hdr

sf_=lapply(1:days_in_total,extract_at_mon)
save(sf_, file=paste0(current_year,"_elevation_at_mon.RData"))