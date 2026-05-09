source("bare_minimum_parallel_MPI.R")

all_sub=c( 'u10', 'v10', 't2m', 'd2m','e','ssr','asn', 'sp', 'tp', 'tcc', 'blh')
all_pred=c( 'u10', 'v10', 't2m_mean', 't2m_sd', 'd2m','e','ssr','asn', 'sp', 'tp', 'tcc', 'blh_00', 'blh_12')

here_data_ERA5=paste0(here_data,"ERA5/",current_year ,"/")
files <- dir(path = here_data_ERA5,pattern="*.nc")
list_era5=list(here_data_pred=here_data_ERA5,already_read=FALSE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			 take_part_raster=FALSE,mean_over_time = TRUE,crs_num=4236,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         files_final=files)

#for (idx_era5 in (1:length(all_pred))) {
idx_era5=9

#####################
	tmp=sub("_.*","",all_pred[idx_era5])

	list_era5$sub=tmp
	list_era5$name=all_pred[idx_era5]

	list_param=list_era5

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


x=foreach (i=1:days_in_total) %do% {
	
 concat_raster=france_grid
      
    if (already_read==FALSE & mosaicking==FALSE & too_big==FALSE & monitors==FALSE) {
      
      if (length(files_final)>1) {

	#CAMS and ERA-5
	a=sub(".nc","",files_final)

	#OMI
	b=sub(".*OMNO2d_","",a)
	c=sub("_v003.*","",b)
	d=sub("m","",c)
	e=yday(as.Date(d,"%Y%m%d"))

	if (is.na(match(i,e))) {
		file_read=france_grid 
		file_read[[1]]=NA
	} else {

		# Add on .. data from 2023 have a zip component
		# Define paths
		zip_path <- paste0(here_data_pred,files_final[match(i,e)]) #"C:/Users/Guillaume/20230101.nc"
		dest_dir <- paste0(here_data_pred,"extracted_data/",sub)#"C:/Users/Guillaume/extracted_data"
		# Unzip the file
		utils::unzip(zip_path, exdir = dest_dir)
		# List files to find the real .nc file
		extracted_files <- list.files(dest_dir, full.names = TRUE)
		length(extracted_files)
		# Now read the ACTUAL NetCDF file
		#tmp_zip <- NULL
		for (idx_nfile in 1:length(extracted_files)) {
			if(class(try(read_stars(extracted_files[idx_nfile], sub = sub,driver = NULL,proxy=FALSE)))=="try-error") next
			file_read <- try(read_stars(extracted_files[idx_nfile], sub = sub, driver = NULL,proxy=FALSE))
		}
		file_read <- st_set_crs(file_read, 4326)
		#file_read <- read_stars(paste0(here_data_pred,files_final[match(i,e)]),sub = sub,driver = NULL,proxy=FALSE)
	}
		
      } else {
        file_read <- read_stars(paste0(here_data_pred,files_final),sub = sub,driver = NULL,proxy=FALSE)
      }
      
    }

   if (all_pred[idx_era5]=="blh_00") { #take that value
	file_read=file_read[,,,1, drop=TRUE]
   } else if (all_pred[idx_era5]=="blh_12") { #take that value
	file_read=file_read[,,,13, drop=TRUE]
   } else if (all_pred[idx_era5]=="t2m_sd") { #take sd
           file_read <- st_apply(file_read, c("x", "y"), sd) 
   } else { file_read <- st_apply(file_read, c("x", "y"), mean) }
    
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

}#end of foreach loop
#save(x,file=paste0(all_pred[idx_era5],".RData"))

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
#save(concat_raster,file=paste0(all_pred[idx_era5],"_cat.RData"))

write_stars(concat_raster,paste0(all_pred[idx_era5],"_",current_year,".tif"))

#move files 
names <- c(paste0(all_pred[idx_era5],"_",current_year,".tif")) 
#dir.create(paste0(here_data_ERA5,current_year,"/"))#has been already created!!!

# custom function
my_function <- function(x){
  file.rename( from = file.path(here_, x) ,
               to = file.path(here_data_ERA5, x))
}

# apply the function to all files
lapply(names, my_function)

#}#ERA5 file one by one