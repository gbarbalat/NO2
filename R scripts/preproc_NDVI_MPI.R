##########
#NDVI
##########

source("bare_minimum_parallel_MPI.R")
use_st_nearest_point=TRUE

####################
here_data_NDVI=paste0(here_data,"NDVI/",current_year,"/")
files <- dir(path = here_data_NDVI, pattern="*.hdf")
files.length <- length(files)


#there are 3 files (mosaics) per month
months_in_total=12

concat_raster=france_grid

pattern_start=paste0("MOD13A3.A",current_year)
a=sub(pattern_start,"",files)
b=substr(a, 1, 3)# Extract first three characters
#identify unique characters
c=unique(b)

#loop for first set of files to the last
#assign the same values till c[i+1]

x=foreach (i=1:months_in_total) %dopar% {

	files_mosaic <- dir(path = here_data_NDVI, pattern=paste0(pattern_start,c[i]))#[1:3]

    	take_first = function(which_file) {
 		initial_NDVI <- gdal_subdatasets(which_file) %>%
   		dplyr::first() %>%
    		read_stars() 
	}

	whole=list();whole[[1]]=take_first(paste0(here_data_NDVI,files_mosaic[1]))
	whole[[2]]=take_first(paste0(here_data_NDVI,files_mosaic[2]))
	whole[[3]]=take_first(paste0(here_data_NDVI,files_mosaic[3]))

	#lapply(paste0(here_data_NDVI,files_mosaic),take_first)
	file_read=do.call(st_mosaic,whole)
	file_read <- st_warp(file_read,dest = france_grid)
        file_read <- file_read[france_sf]   

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
  file_read
  
  #assign similar values from date of NDVI data to next
  j=as.numeric(c[i])
  upper_threshold=ifelse(i==12,days_in_total,as.numeric(c[i+1])-1)
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
#save(x,file="NDVI.RData")

#concatenate foreach 
concat_raster=do.call("c",x)

names(concat_raster)="NDVI"
#save(concat_raster,file="NDVI_concat.RData")
write_stars(concat_raster,paste0("NDVI_",current_year,".tif"))

#move files 
names <- c(paste0("NDVI_",current_year,".tif")) 
#dir.create(paste0(here_data,"NDVI/",current_year,"/"))#has been already created!!!

# custom function
my_function <- function(x){
  file.rename( from = file.path(here_, x) ,
               to = file.path(here_data_NDVI, x))
}

# apply the function to all files
lapply(names, my_function)
