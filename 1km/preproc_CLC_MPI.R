source("bare_minimum_parallel_MPI.R")
use_st_nearest_point=TRUE

param_CLC=c("RES_c","IND_c","URBGR_c","BUILT_c","AGR_c","NAT_c")

RES=c(1,2)#Corine class = (1 + 2; RES), 
IND=3#industry or commercial (3; IND)
URBGR=10#urban green (10; URBGR)
BUILT=1:9#total built up (1-9; BUILT)
AGR=12:22#agriculture (12 - 22; AGR)
NAT=23:41#semi-natural and forest (23 - 41; NAT)

####################
#HERE CHANGE
here_data_CLC=paste0(here_data,"CLC/")
#here_data_CLC="C://Users/Guillaume/Desktop/PhD_epidemio/data/CLC/"
files <- dir(path = here_data_CLC, pattern="_V2020_20u1.tif")
files.length <- length(files)

tmp=read_stars(paste0(here_data_CLC,files), proxy=TRUE)
tmp=st_set_crs(tmp,3035)#crs is 3035
bbox=st_bbox(c(xmin = 3200000, xmax = 4300000 , ymax = 3300000, ymin = 2100000), 
             crs = st_crs(3035))
tmp2_1=st_crop(tmp,bbox)#st_transform(france_sf_4,3035))

for (idx_CLC in (1:length(param_CLC))) {
  
  val_CLC=get(sub("*_c","",param_CLC[idx_CLC]))
  
  #HERE CHANGE
  clc_tmp=tmp2_1[st_transform(france_sf,crs=st_crs(3035))] %>%
  #france_grid_sf_poly_tmp=france_grid_sf_poly[,-1] %>%
  #  st_crop(dplyr::slice(france_sf_diff_sq,60))
  #clc_tmp=tmp2_1[st_transform(france_grid_sf_poly_tmp,crs=st_crs(3035))] %>%
    st_as_sf(as_points=FALSE) %>% st_transform(crs=st_crs(2154))
  colnames(clc_tmp)[1]="code"

  TOT_c=lengths(st_intersects(france_grid_sf_poly_tmp, clc_tmp ))
  num_c=lengths(st_intersects(france_grid_sf_poly_tmp,clc_tmp %>% filter(code %in% val_CLC)))
  val_CLC_c=num_c/TOT_c
  file_read=cbind(france_grid_sf_poly_tmp[,-1],val_CLC_c) %>% st_rasterize()
  
  
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
  
  
  x=list()
  for (i in (1:days_in_total)) {
    x[[i]]=file_read       
    print(i)
  }
  
  #concatenate over time
  concat_raster=do.call(c,x)
  
  concat_raster = st_redimension(concat_raster)
  concat_raster = st_set_dimensions(concat_raster,
                                    which="new_dim", #replace that dimension ...
                                    names = "time", #...by that one
                                    values = 1:days_in_total
  )
  
  print(concat_raster)
  names(concat_raster)=param_CLC[idx_CLC]
  #save(concat_raster,file=paste0("CLC_concat",param_CLC,".RData"))
  
  write_stars(concat_raster,paste0(param_CLC[idx_CLC],"_",current_year,".tif"))
  
  #move files 
  names <- c(paste0(param_CLC[idx_CLC],"_",current_year,".tif")) 
  here_data_CLC_year=paste0(here_data_CLC,current_year,"/")
  dir.create(here_data_CLC_year)
  
  # custom function
  my_function <- function(x){
    file.rename( from = file.path(here_, x) ,
                 to = file.path(here_data_CLC_year, x))
  }
  
  # apply the function to all files
  lapply(names, my_function)
  
  
}#end of CLC var loop