source("bare_minimum_parallel_MPI.R")

##########################################################
##########################################################
here_data_CAMS=paste0(here_data,"CAMS/",current_year ,"/")
files <- dir(path = here_data_CAMS,pattern="*.nc")

tmp=read_stars(paste0(here_data_CAMS,"CAMS_",current_year,".nc"))
tmp_df = tmp %>% as.data.frame() %>% na.omit()
colnames(tmp_df)=c("x","y","time","CAMS")
tmp_df %>%
  mutate(date=data.table::as.IDate(tmp_df$time)) %>%
  group_by(date,x,y) %>%
  summarise(value=mean(CAMS)) -> tmp_summarised
tmp_summarised_stars=tmp_summarised %>% mutate(time=lubridate::yday(date)) %>% ungroup() %>% dplyr::select(-date) %>%
  st_as_stars(coords=c("x","y","time")) %>%
  st_set_crs(4326) 

file_read <- st_warp(tmp_summarised_stars,dest = france_grid)
concat_raster <- file_read[france_sf]
names(concat_raster)="cams"
write_stars(concat_raster,paste0("cams_",current_year,".tif"))


#move files
file=paste0("cams_",current_year,".tif")
names <- c(file) 

# custom function
my_function <- function(x){
  file.rename( from = file.path(here_, x) ,
               to = file.path(paste0(here_data_CAMS), x) )
}

# apply the function to all files
lapply(names, my_function)

