load_monitors=1
source("header_200m.R")
#france_grid_sf_poly to intersect and france_grid

feature1="road_nodes"
feature2="train_stations";#feature2="train_stations_F";#feature3="train_stations_T";feature4="train_stations_TF";
feature3="roads_A";feature4="roads_D";feature5="roads_N";feature6="roads_T";
feature7="rail_E";feature8="rail_NE"

feature=c(feature5)

###load packages
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

#France
#
#42, -5
#52, 10

#our crs=2154
####data directory
here_="/bettik/barbalag/"
here_data="C:/Users/Guillaume/Desktop/PhD_epidemio/data/"
here_data="/bettik/barbalag/data/"

here_data_IGN=paste0(here_data,"IGN/", current_year,"/")
###################################################################################"
###############################################################################""
foreach (idx_feat=1:length(feature)) %do% {

load(file=paste0(here_data_IGN,feature[idx_feat],"_",current_year,".RData"))#this is x!!!!

if (feature[idx_feat] %in% feature[1:2]) 
	{vector_type="points"} else {vector_type="lines"}

  print(idx_feat)  

  ##########
  IGN_which <- st_transform(x, crs=2154)
      
  ##########
      #france_grid_reg=st_crop(france_grid,slice(france_sf_diff_sq,where_OI))
      #france_grid_reg_sf=st_as_sf(france_grid_reg,as_points = FALSE,merge = FALSE)[,-1]

      #within the cells of france_grid_reg_sf, where in Y is there a road?
      #tab=st_intersects(france_grid_reg_sf,IGN_which)
      france_grid_sf_poly_tmp=france_grid_sf_poly[,-1]
      tab=st_intersects(france_grid_sf_poly_tmp,IGN_which)
      
    if (vector_type=="lines") {

    # ##########
    # #sum of length per cell
    # ##########
      getDensity_length = function(each_cell_grid, each_cell_tab) {
        (wInt = st_intersection(each_cell_grid, each_cell_tab))
        wInt$intersected_length = as.numeric(st_length(wInt))
        density = sum(wInt$intersected_length, na.rm=TRUE)#/st_area(each_cell_grid)
      }
      density=lapply(1:nrow(tab), function(k) getDensity_length(france_grid_sf_poly_tmp[k,],IGN_which[tab[[k]]]))

    } else {  
    # ##########
    # #count per cell
    # ##########
      #road_count=st_sf(n = lengths(tab), geometry = st_geometry(france_grid_reg_sf))
      getDensity_count= function(each_cell_grid, each_cell_tab) {
        (wInt = st_intersection(each_cell_grid, each_cell_tab))
        density = sum(nrow(wInt), na.rm=TRUE)#/st_area(each_cell_grid)
      }
      density=lapply(1:nrow(tab), function(k) getDensity_count(each_cell_grid=france_grid_sf_poly_tmp[k,],
								each_cell_tab=IGN_which[tab[[k]]]))

    }
      
      density = do.call(c, density)
      france_grid_sf_poly_tmp$density = density
        
save(france_grid_sf_poly_tmp, file="france_grid_sf_IGNx.RData")

#####
#concatenate and save as tif file
#####
#france_grid_reg_sf_all=do.call(rbind,france_grid_reg_sf)
#print(france_grid_reg_sf_all)

file_read=st_rasterize(france_grid_sf_poly_tmp, france_grid)
print(file_read)


r_=list()
for (i in (1:days_in_total)) {
  r_[[i]]=file_read 
  names(r_[[i]])=feature[idx_feat]
  print(i)
}
#raster
save(r_, file=paste0(current_year,"_",feature[idx_feat],"_200.RData"))

####################################################################"
#extract at monitors function from hdr
sf_=lapply(1:days_in_total,extract_at_mon)
save(sf_, file=paste0(current_year,"_",feature[idx_feat],"_at_mon.RData"))


}#end of IGN feature reading for loop

