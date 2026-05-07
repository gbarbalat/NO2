source("bare_minimum_parallel_MPI.R")

####################
here_data_OMI=paste0(here_data,"OMI/",current_year,"/")
files <- dir(path = here_data_OMI,pattern="*.he5.SUB.nc4")
files.length <- length(files)
list_omi=list(here_data_pred=here_data_OMI,already_read=FALSE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			 take_part_raster=FALSE,
                         mean_over_time = FALSE,crs_num=4236,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=FALSE,
                         sub = "ColumnAmountNO2Trop",files_final=files,name="omi")#ColumnAmountNO2TropCloudScreened
print("omi_gathered")

list_param=list_omi

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
  
  #
x=foreach (i=1:days_in_total) %do% {
#x=foreach (i=60:62) %do% {

	#CAMS and ERA-5
	a=sub(".nc","",files_final)

	#OMI
	b=sub(".*OMNO2d_","",a)
	c=sub("_v003.*","",b)
	d=sub("m","",c)
	e=yday(as.Date(d,"%Y%m%d"))

	if (is.na(match(i,e))) {
		file_read=france_grid 
		file_read[[1]]=units::as_units(NA,"molecule/cm2")
		return(file_read)
	} else {
		file_read <- read_stars(paste0(here_data_pred,files_final[match(i,e)]),sub = sub,driver = NULL,proxy=FALSE)
		file_read <- st_set_crs(file_read, 4326)
	}
      
    file_read <- st_warp(file_read,dest = france_grid)
    file_read <- file_read[france_sf]
   
  print(i)
  #print(file_read)

#replace negative values by NA values
#file_read[[1]]<units::as_units(0,"molecule/cm2")
file_read[[1]][file_read[[1]]<units::as_units(0,"molecule/cm2")]=NA
#file_read[[1]][file_read[[1]]<0]=NA

file_read

}#end of foreach loop
save(x,file="omi.RData")

#concatenate foreach 
concat_raster=do.call("c",x)
  # = concat_raster[-1,,]
  concat_raster = st_redimension(concat_raster)
  concat_raster = st_set_dimensions(concat_raster,
                              which="new_dim", #replace that dimension ...
                              names = "time", #...by that one
                              values = 1:days_in_total
  )


names(concat_raster)=name
#save(concat_raster,file="omi_concat.RData")
write_stars(concat_raster,paste0("omi_",current_year,".tif"))

#move files 
names <- c(paste0("omi_",current_year,".tif")) 
#dir.create(paste0(here_data_OMI,current_year,"/"))#has been already created!!!

# custom function
my_function <- function(x){
  file.rename( from = file.path(here_, x) ,
               to = file.path(here_data_OMI, x))
}

# apply the function to all files
lapply(names, my_function)
