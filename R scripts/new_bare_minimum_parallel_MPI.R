close.screen(all=TRUE)
rm(list=ls())
header=1;


#######################
#header
source("header_MPI.R")

#######################

###load packages
library(dplyr)
library(tidyr)
library(sf)
library(stars)
library(gstat)
library(lubridate)
library(doMC)
library(parallel)

#France
#
#42, -5
#52, 10

#our crs=2154
####data directory
here_data="C:/Users/Guillaume/Desktop/Recoverit 2022-04-17 at 22.09.53/_DATA/PhD epidemio/PhD_epidemio/data/"
here_data="C:/Users/Guillaume/Desktop/PhD_epidemio/data/"
here_data="/bettik/barbalag/data/"

MODIS_grid=1
tropomi_data=0
monitor_data=1
run_test_model=0
gtfs=0;
use_osm_data=0
use_geofabrik=1
tmja=0


##################################################################
##################################################################
##################################################################
##################################################################
## GRID, GEOGRAPHICAL ZONE
##################################################################
##################################################################
##################################################################
##################################################################


################################
#load geographical zone (Brittany)
################################

france_sf_nobuff = st_as_sf(maps::map(database = "france", plot = FALSE, fill = TRUE)) %>%
				st_transform(crs=2154) %>%
  				filter(ID!="Corse du Sud") %>%
  				filter(ID!="Haute-Corse") %>%
				st_make_valid()

france_sf=france_sf_nobuff %>%
  st_union() %>%
  st_buffer(dist=10000) %>%
  st_as_sf()

f_diff=st_difference(france_sf,france_sf_nobuff %>% st_union()) %>% st_as_sf() %>% mutate(ID="buffer") %>% rename(geom=x)

france_sf_diff=rbind(france_sf_nobuff,f_diff)

nc_grid=st_make_grid(france_sf, square=FALSE,cellsize = 100000)
france_sf_diff_sq=st_intersection(nc_grid,france_sf) %>% st_as_sf()

			

################################
# MODIS grid
################################
if (MODIS_grid) {
here_data_grid=paste0(here_data,"MODIS/")

files <- dir(path = here_data_grid,
             pattern="*.hdf")
files.length <- length(files)
filename_grid1=paste0(here_data_grid,files[1]);filename_grid2=paste0(here_data_grid,files[2]);filename_grid3=paste0(here_data_grid,files[3])
sd1 = gdal_subdatasets(filename_grid1);sd2 = gdal_subdatasets(filename_grid2);sd3 = gdal_subdatasets(filename_grid3)
r1=read_stars(sd1[[1]]);r2=read_stars(sd2[[1]]);r3=read_stars(sd3[[1]]);

r_all=st_mosaic(r1,r2,r3)
st_bbox(r_all)
r_all2<-st_warp(r_all,crs=2154,cellsize = 1000)
st_bbox(r_all2)
st_crs(r_all2)
st_dimensions(r_all2)
st_bbox(france_sf)

tmp=r_all2
tmp[[1]][!is.na(tmp[[1]])]=0
#plot(tmp, axes=TRUE)
france_grid=tmp[france_sf]
#plot(france_grid)
st_bbox(france_grid)
france_grid_sf=st_as_sf(france_grid,as_points = TRUE)
france_grid_sf_poly=st_as_sf(france_grid,as_points = FALSE)

#france_grid_time=c(france_grid,france_grid,france_grid,france_grid,france_grid,france_grid,france_grid)
france_grid_time=st_as_stars(rep(france_grid,days_in_total))
france_grid_time=st_redimension(france_grid_time)
updated_DMraster = st_set_dimensions(france_grid_time,
                                  which="new_dim", #replace that dimension ...
                                  names = "time", #...by that one
                                  #values = unique(as.Date(no2.dta$date, origin = "1999-12-31"))
                                  values = 1:days_in_total)
names(updated_DMraster)="grid"
updated_DMraster
}


################################
# function to load and concatenate incoming data
################################
##########

concat_raster = function(list_param) {
  
here_data_pred=list_param$here_data_pred
already_read=list_param$already_read
file_read=list_param$file_read
file_sf=list_param$file_sf
mosaicking=list_param$mosaicking
files_mosaic=list_param$files_mosaic
which_att=list_param$which_att
too_big=list_param$too_big
take_part_raster=list_param$take_part_raster
mean_over_time=list_param$mean_over_time
crs_num=list_param$crs_num
monitors=list_param$monitors
days_in_total=list_param$days_in_total
use_IDW=list_param$use_IDW
use_st_nearest_point=list_param$use_st_nearest_point
sub=list_param$sub
files_final=list_param$files_final
name=list_param$name

 concat_raster=france_grid
  
  if (too_big) {

    tmp=read_stars(paste0(here_data_pred,files_final), proxy=TRUE)
    tmp=st_set_crs(tmp,crs_num)#crs is 3035
    bbox=st_bbox(c(xmin = 3200000, xmax = 4300000 , ymax = 3300000, ymin = 2100000), crs = st_crs(crs_num))
    tmp2_1=st_crop(tmp,bbox)#st_transform(france_sf_4,3035))
    file_read=st_as_stars(tmp2_1, downsample = 9)
    file_read <- st_warp(file_read,dest = france_grid)
    file_read <- file_read[france_sf]

  }
  
  if (mosaicking) {
	take_first = function(which_file) {
 		initial_NDVI <- gdal_subdatasets(which_file) %>%
   		dplyr::first() %>%
    		read_stars() 
	}

	whole=lapply(paste0(here_data_pred,files_mosaic),take_first)
	file_read=do.call(st_mosaic,whole)
	file_read <- st_warp(file_read,dest = france_grid)
        file_read <- file_read[france_sf]

  }
  
 if (already_read) {
    #mean time value for each pixel
    file_read <- read_stars(paste0(here_data_pred,files_final),sub = sub,driver = NULL,proxy=FALSE)
    #file_read <- file_read[,,,1:days_in_total] 
    file_read <- st_warp(file_read,dest = france_grid)
    concat_raster <- file_read[france_sf]
    
    concat_raster = st_set_dimensions(file_read,
                                      which="band", #replace that dimension ...
                                      names = "time", #...by that one
                                      values = 1:days_in_total)
    names(concat_raster)=name

    return(concat_raster)
  }

 if (too_big==FALSE & mosaicking==FALSE) {
    file_read <- read_stars(paste0(here_data_pred,files_final),sub = sub,driver = NULL,proxy=FALSE)
    file_read <- st_warp(file_read,dest = france_grid)
    file_read <- file_read[france_sf]
  }
  

  for (i in  1:days_in_total){   

   if (use_st_nearest_point) {

	r = is.na(file_read) & !is.na(france_grid)

 	if (sum(r[[1]])>0) {
 	sf.tmp=st_as_sf(file_read,as_points = TRUE)
	grid_tmp=st_join(france_grid_sf,sf.tmp)[,-1]
	grid_tmp_NA=grid_tmp[is.na(grid_tmp),]
	grid_tmp_notNA=grid_tmp[!is.na(st_drop_geometry(grid_tmp)),]

	index <- st_nearest_feature(grid_tmp_NA,grid_tmp_notNA)
	grid_tmp_NA[,]=grid_tmp_notNA[index,1]

	file_read= rbind(grid_tmp_NA,grid_tmp_notNA)
	file_read=st_rasterize(file_read,france_grid)#dx = 1000, dy = 1000)
        file_read=st_as_stars(file_read)
	file_read=st_warp(file_read,france_grid)
	}

   } 
    
  print(i)

  concat_raster <- c(concat_raster,file_read)

  }#for loop
  
  concat_raster = concat_raster[-1,,]
  n_time=length(concat_raster)
  concat_raster = st_redimension(concat_raster)
  concat_raster = st_set_dimensions(concat_raster,
                               which="new_dim", #replace that dimension ...
                               names = "time", #...by that one
                               #values = unique(as.Date(no2.dta$date, origin = "1999-12-31"))
                               values = 1:days_in_total
  )

names(concat_raster)=name
return(concat_raster)

}#end of concat_raster function



 print("done with bare minimum parallel")