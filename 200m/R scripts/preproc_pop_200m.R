###### 
#Population and density data, prelude
###### 
load_monitors=1
source("header_200m.R")
#france sf to crop
#france_grid to warp
use_st_nearest_point=TRUE
#pop

here_data_Pop=paste0(here_data,"Pop/")

load(paste0(here_data_Pop,"pop_200m_",year_at_stake,".RData")) 

if (use_st_nearest_point) file_read=complete_raster(file_read)

r_=list()
for (i in (1:days_in_total)) {
  r_[[i]]=file_read
  names(r_[[i]])="pop"
  print(i)
}
#raster
save(r_, file=paste0(current_year,"_pop_200.RData"))

####################################################################"
#extract at monitors function from hdr

sf_=lapply(1:days_in_total,extract_at_mon)
save(sf_, file=paste0(current_year,"_pop_at_mon.RData"))