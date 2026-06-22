##########
#NDVI
##########

load_monitors=0
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

use_st_nearest_point=TRUE

####################
here_data_NDVI=paste0(here_data,"NDVI/",current_year,"/")
files <- dir(path = here_data_NDVI, pattern="*.hdf")
files.length <- length(files)


concat_raster=france_grid

pattern_start=paste0("MOD13Q1.A",current_year)#250m resolution
a=sub(pattern_start,"",files)
b=substr(a, 1, 3)# Extract first three characters
#identify unique characters
c=unique(b)

#loop for first set of files to the last
#assign the same values till c[i+1]

x=foreach (i=1:length(c)) %do% {
#instead_foreach <- function(i) {

	files_mosaic <- dir(path = here_data_NDVI, pattern=paste0(pattern_start,c[i]))#[1:3]

    	take_first = function(which_file) {
 		initial_NDVI <- gdal_subdatasets(which_file) %>%
   		dplyr::first() %>%
    		read_stars() 
	}

	whole=list();
	whole=lapply(paste0(here_data_NDVI,files_mosaic),take_first)
	#whole[[1]]=take_first(paste0(here_data_NDVI,files_mosaic[1]))
	#whole[[2]]=take_first(paste0(here_data_NDVI,files_mosaic[2]))
	#whole[[3]]=take_first(paste0(here_data_NDVI,files_mosaic[3]))

	file_read=do.call(st_mosaic,whole) %>% st_warp(france_grid) %>% st_crop(france_sf)

	if (use_st_nearest_point) file_read=complete_raster(file_read)
   
  print(i)
  concat_raster=file_read

  #assign similar values from date of NDVI data to next
  j=as.numeric(c[i])
  upper_threshold=ifelse(i==length(c),days_in_total,as.numeric(c[i+1])-1)
  while (j <= upper_threshold) {
  concat_raster <- c(concat_raster,file_read)
  j=j+1
  }#
  
  concat_raster = concat_raster[-1,,]
  n_time=length(concat_raster)
  concat_raster = st_redimension(concat_raster)
  concat_raster = st_set_dimensions(concat_raster,
                               which="new_dim", #replace that dimension ...
                               names = "time", #...by that one
                               values = as.numeric(c[i]):upper_threshold
  )


}#end of foreach loop
#x <- lapply(1:length(c),instead_foreach)
save(x,file="x_NDVI.RData")