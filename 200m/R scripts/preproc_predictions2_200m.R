rm(list=ls())

library(stars)
library(dplyr)

load_monitors=1
source("header_200m.R")

####################################################################"
#concatenate
r_=list()

load(file=paste0(current_year,"_pred_res1.RData")); r1=r_
load(file=paste0(current_year,"_pred_res2.RData")); r2=r_
load(file=paste0(current_year,"_pred_res3.RData")); r3=r_
load(file=paste0(current_year,"_pred_res4.RData")); r4=r_
load(file=paste0(current_year,"_pred_res5.RData")); r5=r_
load(file=paste0(current_year,"_pred_res6.RData")); r6=r_

r_=c(r1,r2,r3,r4,r5,r6)

save(r_,file=paste0(current_year,"_pred_res_200.RData"))


####################################################################"
#extract at monitors (no2.sf then intersected_mon from header) and join with monitor data
load(paste0(current_year,"_pred_res_200.RData"))
extract_at_mon=function(x) {
output=r_[[x]][,,,1,drop=TRUE] %>% 
  st_extract(at=intersected_mon %>% filter(time==x) 
             #,time_column="time"
             ) %>% na.omit() %>%
  st_join(intersected_mon %>% filter(time==x)) %>% # 
  #filter(time.x==time.y) %>% mutate(time=time.x) %>%
  mutate(resid=predict_ens1-day_mean) %>% select(-all_of(starts_with("time.")))
}

sf_=lapply(1:days_in_total,extract_at_mon)
save(sf_, file=paste0(current_year,"_pred_res_mon_at_mon.RData"))
