rm(list=ls())

setwd("/bettik/barbalag/output_for_plots_200/")


library(mgcv)
library(reshape2)
library(data.table)
library(dplyr)
library(stars)
library(sf)
library(lubridate)
library(zoo)

path="/bettik/barbalag/200m_header/"
current_year=2012
first_year=2005
last_year=2022
i_year=1
all_global_metrics_Mod2=list()
all_metrics_Mod2=list()
all_Imp_mean=list()
all_Imp_sd=list()
N_mon_all=list()
mean_mon_all=list()
mon_mon_all=list()


#Start looping
for (current_year in first_year:last_year) {

print(current_year)
  
n_days=yday(as.Date(paste0(current_year,"-12-31")))
#if(!file.exists(path)) {next}

print("loading ensemble predictions and model")
source("concat_pred_ens_200.R")
#load(paste0(path,current_year,"/all_predict_ens1_",current_year,".RData"))
load(paste0(path,current_year,"/mod1_",current_year,".RData"))

#

head(all_predict_ens1)
#summary(all_predict_ens1)

#===============================================================================
#weights of each model
#===============================================================================
print("weights of each model")
library(parallel)
w2=list()
weights_per_day=function(i_day) {

grid=all_predict_ens1  %>%
  filter(all_time_sub==i_day) %>% #a specific day
  select(all_x_sub,all_y_sub, all_time_sub) %>%
  mutate(all_predXGB_sub=1, all_predRanger_sub=1,all_predcatboost_sub=1)
w=predict.gam(mod1, newdata=grid,type = "terms") %>% cbind(grid)
w[,6:9]=NULL
colnames(w)=c("ranger","XGB","catboost", "X", "Y")
print(i_day)
w2=w %>% tidyr::pivot_longer(cols=c("ranger","XGB","catboost"),
                             names_to = "model",
                             values_to = "weights")
}
#w2=mclapply(1:n_days,weights_per_day,mc.cores = parallel::detectCores())
w2=lapply(1:n_days,weights_per_day)
save(w2,file=paste0("w2_allyear_",current_year,".RData"))


ifelse (current_year==2022,break,next) 


#===============================================================================
#plot final predictions from each final model,including ensemble
#===============================================================================
print("mean predictions")
#mean over one year
all_predict_ens1_mean=all_predict_ens1 %>% #dplyr::select(predict_ens1, all_x_sub,all_y_sub, all_time_sub) %>%
  dplyr::group_by(all_x_sub,all_y_sub) %>%
  summarise(mGAM=mean(predict_ens1),
            mRang=mean(all_predRanger_sub),
            mXGB=mean(all_predXGB_sub),
            mcatB=mean(all_predcatboost_sub)
  ) %>% tidyr::pivot_longer(cols=c("mRang","mXGB","mcatB","mGAM"),
                            names_to = "model",
                            values_to = "predictions")
head(all_predict_ens1_mean)
save(all_predict_ens1_mean,file=paste0("all_predict_ens1_mean_",current_year,".RData"))


#predictions for just one day
print("one day predictions")
all_predict_ens1_1=all_predict_ens1 %>% filter(all_time_sub==49) %>%
  mutate(mGAM=predict_ens1,
         mRang=all_predRanger_sub,
         mXGB=all_predXGB_sub,
         mcatB=all_predcatboost_sub) %>% 
  tidyr::pivot_longer(cols=c("mRang","mXGB","mcatB","mGAM"),
                      names_to = "model",
                      values_to = "predictions"
  )
head(all_predict_ens1_1)
save(all_predict_ens1_1,file=paste0("all_predict_ens1_1_",current_year,".RData"))


#predictions over Paris
print("one day predictions over Paris")
tmp_stars=st_as_stars(all_predict_ens1_1,coords = c("all_x_sub", "all_y_sub"));st_crs(tmp_stars)=2154
Paris_bbox=st_bbox(c(xmin=2,ymin=48.6, xmax=2.7, ymax=49.1),crs=st_crs(4326))

france_sf_nobuff_2154 = st_as_sf(maps::map(database = "france", plot = FALSE, fill = TRUE)) %>% st_transform(crs=2154) %>%
  filter(ID!="Corse du Sud") %>%
  filter(ID!="Haute-Corse") %>%
  st_make_valid()
Paris_sf_nobuff_2154=france_sf_nobuff_2154 %>% filter(ID=="Paris")
Paris_stars=tmp_stars[Paris_sf_nobuff_2154]
#Paris_stars = Paris_stars %>% st_as_sf()  %>% st_transform(crs=st_crs(4326)) %>% st_rasterize()
save(Paris_stars,file=paste0("Paris_stars_",current_year,".RData"))


#===============================================================================
#NO2 predictions over the WHO threshold in 2022
#===============================================================================
if (current_year==2022) {
print("WHO threshold")

#over the WHO threshold for the whole year 
all_predict_ens1_mean_WHO=all_predict_ens1_mean %>% mutate(over=case_when(predictions>=10 ~ TRUE,
                                                                      predictions<10 ~ FALSE))
head(all_predict_ens1_mean)
save(all_predict_ens1_mean_WHO,file="all_predict_ens1_mean_WHO.RData")

#nb of days over the WHO threshold
ndays_overWHO=all_predict_ens1 %>% 
  dplyr::select(predict_ens1, all_x_sub,all_y_sub, all_time_sub) %>%
  dplyr::count(all_x_sub,all_y_sub,wt=predict_ens1>=25) 
save(ndays_overWHO,file="ndays_overWHO.RData")
}

}




