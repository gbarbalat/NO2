#simply converts raster file ("updated_DMraster_France_",current_year,".RData")
# into a data frame (updated_DM_df.RData)
# and into a data frame w/o NA (df_final.RData)
library(raster)
library(sf)
library(stars)
library(dplyr)

start_time=Sys.time()

source("header_MPI.R")
header=1;

#predictors
variables=c('omi','cams','X','Y'
             ,"time"
             )#

###########################################
#Main path and libraries
#Load raw data
#clean raw datasliced
###########################################
path_to="/bettik/barbalag/"
#path_to="C:/Users/Guillaume/Desktop/PhD Epidemio_PROJECT/"

#missing values OMI
file_is=paste0("updated_DMraster_France_var",1,"_",current_year,".RData")
load(file=paste0(path_to,file_is)) 
updated_DM_OMI=updated_DMraster %>% as.data.frame()
OMI_notNA=complete.cases(updated_DM_OMI)

##########
i=2
#for (i in 2:40) {#length nvar
file_is=paste0("updated_DMraster_France_var",i,"_",current_year,".RData")
load(file=paste0(path_to,file_is)) 

# END STAGE: convert to data.frame
#updated_DM_df <-  updated_DMraster %>% 
 # st_as_sf(as_points = TRUE,
  #         merge=FALSE,
   #        long=TRUE,
    #       na.rm=TRUE
  #) 

#convert to df
updated_DM_df <-  updated_DMraster %>% as.data.frame()
#you will use the df below in the predicting stage
#save(updated_DM_df,file=paste0("updated_DM_df_var",i,"_",current_year,".RData"))

##################################################################################################
#No missing values except in outcomes
#if (i==2) {
df_final=cbind(updated_DM_OMI,cams=updated_DM_df[,4]) %>%
	 rename(X=x,Y=y)
df_final=df_final[OMI_notNA,]
#}

#}

save(df_final,file=paste0("df_final_",current_year,".RData"))


end_time=Sys.time()
print(end_time-start_time)
