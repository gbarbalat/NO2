library(stars)
library(dplyr)

here_data="/bettik/barbalag/data/"

header=1#no need to build up grids and area for cropping
#load_monitors=1 or 0 in the seminal script

use_st_nearest_point=TRUE

###############################"
#parameters
current_year=2023 #leap years 2000 2004 2008 2012 2016 2020 2024
days_in_total=365
MPI=FALSE #TRUE or FALSE seminal pred.RData is fragmented by month?

length_sub_test=ifelse(days_in_total==366,7513218,7492690)#how to split the data to avoid out of memory issues
#1day: 246335; 366: nrow(essai)=90158610=>7513218; 365:  89912275=> 7492690

#for CLC
year_CLC="U2018_CLC2018_V2020_20u1"
#U2006_CLC2000_V2020_20u1: 2000 to 2005
#U2012_CLC2006_V2020_20u1: 2006 to 2011
#U2018_CLC2012_V2020_20u1: 2012 to 2017
#U2018_CLC2018_V2020_20u1: 2018 to 2023

#for roads
road_ds_chosen=0

#for Models 2 and 3, buffer size and n_breaks depend on the STvariogram
buffer_size=5
buffer_dist=2000
n_breaks=73#try with more n_breaks


##########
#NOT FOR USE
##########
#for pop
year_at_stake=2020## 2005-2010-2015-2020, year and next four years
pop_ds_chosen=1500

DMSP=FALSE #till 2013
VIIRS=TRUE #from 2014 onwards


############################################
#for cropping and gridding
#use Hough et al 2020 mask to match 200 m grid for NO2 and temperature
france_sf <- read_sf("/bettik/barbalag/200m_header/grd_200m_pys.shp") %>% st_transform(2154)#for cropping
#france_sf <- fst::read.fst("/bettik/barbalag/200m_header/grd_200m.fst") %>% st_as_sf(coords = c("x", "y"), crs = 2154)
france_grid <- st_as_stars(st_bbox(france_sf),dx=200) %>% st_crop(france_sf)
france_grid_sf_poly <- st_as_sf(france_grid)

save(france_sf,file="france_sf.RData")
save(france_grid_sf_poly,file="france_grid_sf_poly.RData")
save(france_grid,file="france_grid.RData")

#load monitors
if (load_monitors==1) {

load(paste0("/bettik/barbalag/monitors_", current_year,".RData"))
#intersected_mon=no2.sf %>% st_intersection(france_sf) %>% rename(time=datey)
intersected_mon=no2.sf %>% rename(time=datey)

#extract at monitor function
extract_at_mon=function(x) {
output=r_[[x]] %>% 
  st_extract(at=intersected_mon %>% filter(time==x)
             #,time_column="time"
             ) %>% na.omit()
}
}


#fill up raster using st_nearest
complete_raster=function(file_read) {

r = is.na(file_read) & !is.na(france_grid)

 	if (sum(r[[1]])>0) {
 		sf.tmp=st_as_sf(file_read,as_points = FALSE)
		grid_tmp=st_join(france_grid_sf_poly,sf.tmp)[,-1]
		grid_tmp_NA=grid_tmp[is.na(grid_tmp),]
		grid_tmp_notNA=grid_tmp[!is.na(st_drop_geometry(grid_tmp)),]

		index <- st_nearest_feature(grid_tmp_NA,grid_tmp_notNA)
		grid_tmp_NA[,]=grid_tmp_notNA[index,]
		
		file_read= st_rasterize(rbind(grid_tmp_NA,grid_tmp_notNA),france_grid)
	} else {return(file_read)}

}


# predictions df to raster function

pred_to_rast=function(i){

file_read = all_predict_ens1 %>% filter(all_time_sub==i) %>%
  select(-c(all_predRanger_sub,all_predXGB_sub,all_predcatboost_sub, all_time_sub)) %>% 
  rename(x=all_X_sub,y=all_Y_sub) %>%
  st_as_stars(coords = c("x","y")) %>%
  st_set_crs(2154) %>% st_crop(france_sf) %>% st_warp(france_grid) 
print(i)

if (use_st_nearest_point) file_read=complete_raster(file_read)

file_read=c(file_read,file_read,along=3)[,,,1,drop=FALSE] %>% st_set_dimensions(which="new_dim",values=i,names="time")


}
