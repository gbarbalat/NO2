source("new_bare_minimum_parallel_MPI.R")

start_time=Sys.time()
##########
#omi
##########
here_data_OMI=paste0(here_data,"OMI/", current_year ,"/")
files <- dir(path = here_data_OMI,pattern="*.tif")
files.length <- length(files)
list_omi=list(here_data_pred=here_data_OMI,already_read=TRUE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			 take_part_raster=FALSE,
                         mean_over_time = FALSE,crs_num=4236,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=FALSE,
                         sub = "ColumnAmountNO2Trop",files_final=files,name="omi")
print("omi_gathered")

##########
#CAMS
##########
here_data_CAMS=paste0(here_data,"CAMS/",current_year ,"/")
files <- dir(path = here_data_CAMS,pattern="*.tif")
list_cams=list(here_data_pred=here_data_CAMS,already_read=TRUE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			 take_part_raster=FALSE,
                         mean_over_time = FALSE,crs_num=4236,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         sub = TRUE,files_final=files,name="cams")
print("cams_gathered")

##########
#INERIS
##########
#here_data_INERIS=paste0(here_data,"INERIS/2004/")
#files <- dir(path = here_data_INERIS,pattern="*2004.NO2.daymean.2gis.nc")
#list_ineris=list(here_data_pred=here_data_INERIS,already_read=FALSE, file_read=NULL,file_sf=NULL,
#                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
#			 take_part_raster=TRUE,
#                         mean_over_time = TRUE,crs_num=4236,monitors=FALSE,
#                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
#                         sub = TRUE,files_final=files,name="ineris")
#print("ineris_gathered")


##########
#ERA5
##########
here_data_ERA5=paste0(here_data,"ERA5/",current_year ,"/")
files <- dir(path = here_data_ERA5,pattern="*.tif")
list_era5=list(here_data_pred=here_data_ERA5,already_read=TRUE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			 take_part_raster=FALSE,mean_over_time = FALSE,crs_num=4236,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         files_final=files)
all_sub=c( 'u10', 'v10', 't2m', 'asn', 'sp', 'tp', 'tcc', 'blh')
all_sub=c( 'u10', 'v10', 't2m_mean', 't2m_sd', 'd2m','e','ssr','asn', 'sp', 'tp', 'tcc', 'blh_00', 'blh_12')

for (i in 1:length(all_sub)) {
list_era5$sub=all_sub[i]
list_era5$name=all_sub[i]
list_era5$files_final=paste0(all_sub[i],"_",current_year,".tif")
assign(paste0("list_era5_",all_sub[i]),list_era5)
}
print("era5_gathered")


##########
#elevation
##########
here_data_Elev=paste0(here_data,"elevation/")
files <- dir(path = here_data_Elev,pattern="*.tif")
files <- "eu_dem_v11_france_buf5km.tif"
list_elev=list(here_data_pred=here_data_Elev,already_read=FALSE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=TRUE,
			 take_part_raster=FALSE,
                         mean_over_time = FALSE,crs_num=3035,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         sub = TRUE,files_final=files,name="elevation")
print("elevation_gathered")

##########
#NDVI
##########
here_data_NDVI=paste0(here_data,"NDVI/",current_year,"/")
files <- dir(path = here_data_NDVI, pattern="*.tif")
files.length <- length(files)
list_NDVI=list(here_data_pred=here_data_NDVI,already_read=TRUE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			 take_part_raster=FALSE,
                         mean_over_time = FALSE,crs_num=NULL,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         sub = TRUE,files_final=files,name="NDVI")
print("ndvi_gathered")


##########
#CLC
##########
here_data_CLC=paste0(here_data,"CLC/",current_year,"/")#
files <- dir(path = here_data_CLC, pattern="*.tif")
#18
list_CLC= list(here_data_pred=here_data_CLC,already_read=TRUE, file_read=NULL,file_sf=NULL,
                          mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			  take_part_raster=FALSE,
			 take_part_raster=FALSE,mean_over_time = FALSE,crs_num=4236,monitors=FALSE,
                          days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
			 files_final=files)
all_sub=c( 'RES_c', 'IND_c', 'URBGR_c', 'BUILT_c', 'AGR_c', 'NAT_c')
for (i in 1:length(all_sub)) {
list_CLC$sub=all_sub[i]
list_CLC$name=all_sub[i]
list_CLC$files_final=paste0(all_sub[i],"_",current_year,".tif")
assign(paste0("list_CLC_",all_sub[i]),list_CLC)
}

print("clc_gathered")

##########
#DMSP
##########
if (DMSP) {
here_data_DMSP=paste0(here_data,"DMSP/")
files <- dir(path = here_data_DMSP, pattern=paste0(".tif"))

#same pb as for population; not needed actually!!! 
#DMSP_stars=read_stars(paste0(here_data_DMSP,files))
#DMSP_stars = DMSP_stars[st_transform(france_sf,st_crs(DMSP_stars))]
#DMSP_stars = st_as_stars(DMSP_stars)
list_LAN= list(here_data_pred=here_data_DMSP,too_big=FALSE,file_sf=NULL,
                          already_read=FALSE,file_read=NULL,take_part_raster=FALSE,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,
                         mean_over_time = FALSE,files_final=files,crs_num=NULL,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         sub = TRUE,name="DMSP")
print("dmsp_gathered: light at night")
}

##########
#VIIRS
##########
if (VIIRS) {

here_data_VIIRS=paste0(here_data,"VIIRS/",current_year,"/")
files <- dir(path = here_data_VIIRS, pattern=paste0("VIIRS_",current_year,".tif"))

list_LAN= list(here_data_pred=here_data_VIIRS,too_big=FALSE,file_sf=NULL,
                          already_read=FALSE,file_read=NULL,take_part_raster=FALSE,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,
                         mean_over_time = FALSE,files_final=files,crs_num=NULL,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         sub = TRUE,name="VIIRS")
print("viirs_gathered: light at night")
}

##########
#pop
##########
here_data_Pop=paste0(here_data,"Pop/",current_year,"/")#

## Assigning next four years to earlier population
file=paste0("pop",current_year,".tif")

list_pop_ds=list(here_data_pred=here_data_Pop,too_big=FALSE,file_sf=NULL,
			  already_read=FALSE,file_read=NULL,take_part_raster=FALSE,
                          mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,
                          mean_over_time = FALSE,files_final=file,
			  crs_num=NULL,monitors=FALSE,
                          days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                          sub = TRUE, name="pop_ds")
print("pop_gathered")

##########
# Distance to density > ds (1500 per km2)
########## 
here_data_Pop=paste0(here_data,"Pop/",current_year,"/")#

file=paste0("dist_to_nearest_ds",current_year,".tif")

list_pop_dist_to_nearest=list(here_data_pred=here_data_Pop, already_read=FALSE, 
              file_read=NULL, take_part_raster=FALSE,
              file_sf=NULL,too_big=FALSE,
              mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,
              mean_over_time=FALSE, files_final=file,crs_num=NULL, 
              days_in_total=days_in_total, monitors=FALSE,use_IDW=FALSE,use_st_nearest_point=TRUE,
              sub=TRUE,name="pop_dist_to_near")
print("pop_dist_gathered")

##################################
# MOnitor data
##################################
#here_data_monitor=paste0(here_data,"monitor_data/")
#files_final=paste0("monitors_",current_year,".tif")

#list_no2_monitors= list(here_data_pred=here_data_monitor, already_read=TRUE, file_read=NULL,take_part_raster=FALSE,
#                                file_sf=NULL,mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,
#                                mean_over_time=FALSE, files_final=files_final,crs_num=NULL, too_big=FALSE,use_IDW=FALSE,
#				use_st_nearest_point=FALSE,sub=NULL,name="no2_monitors",
#                                days_in_total=days_in_total, monitors=TRUE,sub=NULL)
#print("monitor_gathered")


#############
#transport data
#############
here_data_IGN=paste0(here_data,"IGN/",current_year,"/")#

files <- dir(path = here_data_IGN,pattern="*.tif")
list_trspt=list(here_data_pred=here_data_IGN,already_read=FALSE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			 take_part_raster=FALSE,mean_over_time = FALSE,crs_num=NULL,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         files_final=files)

all_sub=c( 'roads_D', 'roads_A','roads_N','roads_T', 'road_nodes', 'rail_E','rail_NE',
#'train_stations_T','train_stations_F','train_stations_TF'
'train_stations'
)

for (i in 1:length(all_sub)) {
#list_trspt$sub=all_sub[i]
list_trspt$name=all_sub[i]
list_trspt$files_final=paste0(all_sub[i],"_",current_year,".tif")
assign(paste0("list_trspt_",all_sub[i]),list_trspt)
}
print("transport data gathered")


#############
#transport data, dist to nearest
#############
here_data_IGN_nrst=paste0(here_data,"IGN_nrst/",current_year,"/")#

files <- dir(path = here_data_IGN,pattern="*.tif")
list_trspt_nrst=list(here_data_pred=here_data_IGN_nrst,already_read=FALSE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			 take_part_raster=FALSE,mean_over_time = FALSE,crs_num=NULL,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         files_final=files)
all_sub=c( 'roads_D_dist_nearest', 'roads_A_dist_nearest','roads_N_dist_nearest','roads_T_dist_nearest', 'road_nodes_dist_nearest', 'rail_E_dist_nearest','rail_NE_dist_nearest',
#'train_stations_T_dist_nearest','train_stations_F_dist_nearest','train_stations_TF_dist_nearest'
'train_stations'
)

for (i in 1:length(all_sub)) {
#list_trspt_nrst$sub=all_sub[i]
list_trspt_nrst$name=all_sub[i]
list_trspt_nrst$files_final=paste0(all_sub[i],"_",current_year,".tif")
assign(paste0("list_trspt_nrst_",all_sub[i]),list_trspt_nrst)
}
print("transport to nearest data gathered")

##########
#emission data
##########
here_data_emission=paste0(here_data,"INERIS_emissions/",current_year ,"/")

files <- dir(path = here_data_emission,pattern="*.tif")
list_emissions=list(here_data_pred=here_data_emission,already_read=TRUE, file_read=NULL,file_sf=NULL,
                         mosaicking=FALSE,files_mosaic=NULL,which_att=FALSE,too_big=FALSE,
			 take_part_raster=FALSE,
                         mean_over_time = FALSE,crs_num=NULL,monitors=FALSE,
                         days_in_total=days_in_total,use_IDW=FALSE,use_st_nearest_point=TRUE,
                         sub = TRUE,files_final=files,name="emission")

for (i in 1:length(all_emissions)) {
list_emissions$files_final=paste0("r_",all_emissions[i],current_year,".tif")
list_emissions$name=all_emissions[i]
assign(paste0("list_",all_emissions[i]),list_emissions)
}
print("emission_gathered")

##########
#concat all param
##########
param_list=list(
list_omi,list_cams,#list_ineris,
list_era5_u10,list_era5_v10,list_era5_t2m_mean,list_era5_t2m_sd,list_era5_d2m,list_era5_e,list_era5_ssr,list_era5_asn,list_era5_sp,list_era5_tp,list_era5_tcc,list_era5_blh_00,list_era5_blh_12, 
list_elev,list_NDVI,
list_LAN,
list_pop_ds,list_pop_dist_to_nearest,#list_no2_monitors,
list_CLC_RES_c, list_CLC_IND_c, list_CLC_URBGR_c, list_CLC_BUILT_c, list_CLC_AGR_c,list_CLC_NAT_c,
list_trspt_roads_D,list_trspt_roads_A,list_trspt_roads_N,list_trspt_roads_T,list_trspt_road_nodes,
list_trspt_rail_E,list_trspt_rail_NE,list_trspt_train_stations,
#list_trspt_train_stations_T,list_trspt_train_stations_F,list_trspt_train_stations_TF,
list_trspt_nrst_roads_D_dist_nearest,list_trspt_nrst_roads_A_dist_nearest,list_trspt_nrst_roads_N_dist_nearest,list_trspt_nrst_roads_T_dist_nearest,list_trspt_nrst_road_nodes_dist_nearest,
#list_trspt_nrst_rail_dist_nearest,list_trspt_nrst_train_stations_T_dist_nearest,list_trspt_nrst_train_stations_F_dist_nearest,list_trspt_nrst_train_stations_TF_dist_nearest,
#list_emission_2_,list_emission_3_,list_emission_7_,list_emission_8_,list_emission_9_,list_emission_11_
#list_emission_1_,list_emission_2_,list_emission_3_,list_emission_6_,list_emission_7_,list_emission_8_,list_emission_10_,list_emission_99_
list_emission_99_

)

#(updated_DMraster=mclapply(X=param_list, concat_raster,mc.cores = 32))

for (i in 1:length(param_list)) {
updated_DMraster=concat_raster(param_list[[i]])
save(updated_DMraster,file=paste0("updated_DMraster_France_var",i,"_",current_year,".RData"))

updated_DMdf=updated_DMraster %>% as.data.frame() %>% na.omit() %>% 
		     		mutate(time_month = month(as.Date(time, origin = paste0(current_year-1,"-12-31")))) 
updated_DMdf=split(updated_DMdf, f = updated_DMdf$time_month)

	for (j in 1:12) { #one raster per month
	updated_DMraster=st_as_stars(updated_DMdf[[j]] %>% select(-time_month),coords=c("x","y","time"))
	save(updated_DMraster,file=paste0("updated_DMraster_France_var",i,"_","month",j,"_",current_year,".RData"))
	}



}

end_time=Sys.time()
print(end_time-start_time)