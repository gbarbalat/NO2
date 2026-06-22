load_monitors=1
source("header_200m.R")
use_st_nearest_point=TRUE

start_time=Sys.time()

use_st_nearest_point=TRUE

param_CLC=c("RES_c","IND_c","URBGR_c","BUILT_c","AGR_c","NAT_c")
#param_CLC=c("URBGR_c")

RES=c(1,2)#Corine class = (1 + 2; RES), 
IND=3#industry or commercial (3; IND)
URBGR=10#urban green (10; URBGR)
BUILT=1:9#total built up (1-9; BUILT)
AGR=12:22#agriculture (12 - 22; AGR)
NAT=23:41#semi-natural and forest (23 - 41; NAT)

####################
here_data_CLC=paste0(here_data,"CLC/")
files <- dir(path = here_data_CLC, pattern=paste0(year_CLC,".*tif"))
files.length <- length(files)

tmp=read_stars(paste0(here_data_CLC,files), proxy=TRUE)
tmp=st_set_crs(tmp,3035)#crs is 3035
bbox=st_bbox(c(xmin = 3200000, xmax = 4300000 , ymax = 3300000, ymin = 2100000), 
                 crs = st_crs(3035))
tmp2_1=st_crop(tmp,bbox)#st_transform(france_sf_4,3035))


#####
for (idx_CLC in (1:length(param_CLC))) {

val_CLC=get(sub("*_c","",param_CLC[idx_CLC]))

##########
##########
clc_tmp=tmp2_1[st_transform(france_sf,crs=st_crs(3035))] %>% #france_sf
	st_as_sf(as_points=FALSE) %>% st_transform(crs=st_crs(2154))
colnames(clc_tmp)[1]="code"

TOT_c=lengths(st_intersects(france_grid_sf_poly, clc_tmp ))#france_grid_sf_poly
num_c=lengths(st_intersects(france_grid_sf_poly,clc_tmp %>% filter(code %in% val_CLC)))#france_grid_sf_poly
val_CLC_c=num_c/TOT_c

####################
file_read=cbind(france_grid_sf_poly[,-1],val_CLC_c) %>% 
		st_rasterize(france_grid)#

####################

r_=list()
for (i in (1:days_in_total)) {
  r_[[i]]=file_read 
  names(r_[[i]])=param_CLC[idx_CLC]
  print(i)
}
#raster
save(r_, file=paste0(current_year,"_",param_CLC[idx_CLC],"_200.RData"))

####################################################################"
#extract at monitors function from hdr

sf_=lapply(1:days_in_total,extract_at_mon)
save(sf_, file=paste0(current_year,"_",param_CLC[idx_CLC],"_at_mon.RData"))


}#end of CLC var loop

end_time=Sys.time()
print(end_time-start_time)