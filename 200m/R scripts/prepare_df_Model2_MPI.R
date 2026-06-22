close.screen(all=TRUE)
rm(list=ls())

load_monitors=0
source("header_200m.R")

library(raster)
library(sf)
library(stars)
library(dplyr)

start_time=Sys.time()


###########################################
#Main path and libraries
#Load raw data
#clean raw dataslice
###########################################
path_to="/bettik/barbalag/200m_header/"
#path_to="C:/Users/Guillaume/Desktop/PhD Epidemio_PROJECT/"

#concatenate extracted at monitors
load(file=paste0(current_year,"_RES_c_at_mon.RData")); CLC_at_mon_RES_c=do.call(rbind,sf_)
load(file=paste0(current_year,"_IND_c_at_mon.RData")); CLC_at_mon_IND_c=do.call(rbind,sf_)
load(file=paste0(current_year,"_URBGR_c_at_mon.RData")); CLC_at_mon_URBGR_c=do.call(rbind,sf_)
load(file=paste0(current_year,"_BUILT_c_at_mon.RData")); CLC_at_mon_BUILT_c=do.call(rbind,sf_)
load(file=paste0(current_year,"_AGR_c_at_mon.RData")); CLC_at_mon_AGR_c=do.call(rbind,sf_)
load(file=paste0(current_year,"_NAT_c_at_mon.RData")); CLC_at_mon_NAT_c=do.call(rbind,sf_)
#load(file=paste0(current_year,"_pop_at_mon.RData")); pop_at_mon=do.call(rbind,sf_)
#load(file=paste0(current_year,"_dist_to_nrst_ds_at_mon.RData")); dist_to_nearest_ds_at_mon=do.call(rbind,sf_)
#load(file=paste0(current_year,"_LAN_at_mon.RData")); LAN_at_mon=do.call(rbind,sf_)
load(file=paste0(current_year,"_road_nodes_at_mon.RData")); road_nodes_at_mon=do.call(rbind,sf_)
load(file=paste0(current_year,"_roads_A_at_mon.RData")); roads_A=do.call(rbind,sf_)
load(file=paste0(current_year,"_roads_D_at_mon.RData")); roads_D=do.call(rbind,sf_)
load(file=paste0(current_year,"_roads_N_at_mon.RData")); roads_N=do.call(rbind,sf_)
load(file=paste0(current_year,"_roads_T_at_mon.RData")); roads_T=do.call(rbind,sf_)
load(file=paste0(current_year,"_rail_E_at_mon.RData")); rail_E=do.call(rbind,sf_)
load(file=paste0(current_year,"_rail_NE_at_mon.RData")); rail_NE=do.call(rbind,sf_)
load(file=paste0(current_year,"_train_stations_at_mon.RData")); train_stations=do.call(rbind,sf_)
load(file=paste0(current_year,"_NDVI_at_mon.RData")); NDVI=do.call(rbind,sf_)
load(file=paste0(current_year,"_elevation_at_mon.RData")); elevation=do.call(rbind,sf_)


load(file=paste0(current_year,"_pred_res_mon_at_mon.RData")); pred_res_mon_at_mon=do.call(rbind,sf_)

#join sf (time colum is from pre_res file)
df_final_Model2 = pred_res_mon_at_mon %>%
	cbind(CLC_at_mon_RES_c %>% st_drop_geometry()) %>%
	cbind(CLC_at_mon_IND_c %>% st_drop_geometry()) %>%
	cbind(CLC_at_mon_URBGR_c %>% st_drop_geometry()) %>%
	cbind(CLC_at_mon_BUILT_c %>% st_drop_geometry()) %>%
	cbind(CLC_at_mon_AGR_c %>% st_drop_geometry()) %>%
	cbind(CLC_at_mon_NAT_c %>% st_drop_geometry()) %>%
	#cbind(LAN_at_mon %>% st_drop_geometry()) %>%
	#cbind(pop_at_mon %>% st_drop_geometry()) %>%
	#cbind(dist_to_nearest_ds_at_mon %>% st_drop_geometry()) %>%
	cbind(road_nodes_at_mon %>% st_drop_geometry()) %>%
	cbind(roads_A %>% st_drop_geometry()) %>%
	cbind(roads_N %>% st_drop_geometry()) %>%
	cbind(roads_D %>% st_drop_geometry()) %>%
	cbind(roads_T %>% st_drop_geometry()) %>%
	cbind(rail_E %>% st_drop_geometry()) %>%
	cbind(rail_NE %>% st_drop_geometry()) %>%
	cbind(train_stations %>% st_drop_geometry()) %>%
	cbind(elevation %>% st_drop_geometry()) %>%
	cbind(NDVI %>% st_drop_geometry())


#st_coordinates
#st_drop_geometry
coords=st_coordinates(df_final_Model2) 
df_final_Model2 =df_final_Model2 %>% cbind(coords) %>% rename(x=X,y=Y) %>% st_drop_geometry()
(head(df_final_Model2))

save(df_final_Model2,file=paste0("df_final_Model2_",current_year,".RData"))

df_final_Model2$spacevar=paste0(df_final_Model2$x,"-",df_final_Model2$y)
print(nrow(df_final_Model2))
print(length(unique(df_final_Model2$spacevar)))
print("this needs to match the nb of monitors for that year")

end_time=Sys.time()
print(end_time-start_time)