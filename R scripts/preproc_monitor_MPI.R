source("bare_minimum_parallel_MPI.R")

##########################################################
##########################################################

here_data_monitor=paste0(here_data,"monitor_data/")
message("which sep do I need to use?")
sep=","

coord_file="all_stations.csv"
  no2.df=read.csv(paste0(here_data_monitor,"NO2_daily_",current_year,".csv"), header = TRUE, sep=sep)
  
  ## Replace unknown values with NA
  head(no2.df)
  no2.df_average <- no2.df %>%
    select(day_mean,validity, date,pollutant, station) %>%
    filter(validity==1 & pollutant=="NO2") %>%
    filter(day_mean<=209) %>%
    mutate(datey = yday(as.Date(date,format="%Y/%m/%d")), datem=month(date), datew=wday(date))

summary(no2.df_average)

  ## Adding coordinate information
  ## This was obtained also from SUMMER slama server
  coords <- read.csv(file=paste0(here_data_monitor,"all_stations.csv"), 
                     header=TRUE, stringsAsFactors = FALSE, sep=";") %>%
	    select(c(Code,Latitude,Longitude, Implantation))
  no2.df_average_coords <- no2.df_average %>%
    left_join(coords, by = c("station"="Code")) %>%
    select(c(station,datey,datem,datew,
             day_mean,Latitude,Longitude, Implantation, pollutant)) %>%
    mutate(across(c( Latitude,Longitude),~gsub(pattern=",",replacement = ".",.x))) %>%
    mutate(across(c( Latitude,Longitude),~as.numeric(.x))) 


#to sf
  no2.df_average_coords_wide <- no2.df_average_coords %>%
    select(datey, Latitude, Longitude,day_mean) 
  
  no2.sf <- st_as_sf(x=no2.df_average_coords_wide,
                     coords = c("Longitude", "Latitude"),
                     crs = st_crs(4326),
                     na.fail = FALSE,
                     agr = NA_agr_,
                     dim = "XYZ",
                     remove = TRUE,
                     sf_column_name = NULL)
  
  no2.sf=st_transform(no2.sf,crs=2154)
  no2.sf=st_crop(no2.sf, st_transform(france_sf, crs=st_crs(no2.sf))) %>%
		st_transform(crs=st_crs(2154))


(no2.sf)
save(no2.sf,file=paste0("monitors_",current_year,".RData"))