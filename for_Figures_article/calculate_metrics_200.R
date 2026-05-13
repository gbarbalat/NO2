rm(list=ls())


setwd("/bettik/barbalag/calculate_metrics_200/")


library(MLmetrics)
library(caret)
library(dplyr)
library(ranger)
library(xgboost)
library(mgcv)
library(stars)
library(data.table)

metric="R2"
sp_temp_metrics=TRUE

#HERE CHANGE
path_to="/bettik/barbalag/200m_header/"
which_folds_type="STBlMo_5F"
buffer_size=5
buffer_dist=2000
current_year=2012
n_breaks=73#try with more n_breaks
start=2005
finish=2022

##################################################################
#to calculate metrics
##################################################################
calculateMMetrics <- function(y_true,y_hat) {
  out<-apply(y_hat,2,postResample,obs=y_true)
  return(out)
}
##################################################################


###########
#prediction from basis lrn () for each fold
###########

blockCV="STBlMo_5F"

for (current_year in start:finish) {

print(current_year)

load(paste0(path_to,current_year,"/holdout_folds_STBlMo_5F_",current_year,".RData"))
#day_mean and no2_monitors
#df$day_mean=ifelse("day_mean" %in% colnames(df),df$day_mean,df$no2_monitors)
#df, idx_in and out
nfolds=10

############################################################################
#ensemble prediction for each fold
############################################################################
#ens_results=list(mod,pred,MMetrics,ens_DB_test)
load(file=paste0(path_to,current_year,"/all_predict_ens_folds_",current_year,".RData"))


##################################################################
#Model Metrics 
##################################################################
y_true=NULL
all_prediction=NULL
ranger_prediction=NULL
XGB_prediction=NULL
catB_prediction=NULL

grid_id=NULL
x=NULL
y=NULL
time=NULL
all_predict_ens2=list()
mod2=list()
all_metrics_folds=list()

for (idx_fold in 1:nfolds) {
  
  #Model Metrics
  (all_metrics_folds[[idx_fold]]=ens_results[[idx_fold]][[3]])
  print(all_metrics_folds[[idx_fold]])
  
  #ensemble predictions
  all_prediction=c(all_prediction,ens_results[[idx_fold]][[2]])

  #basis lrns predictions
  ranger_prediction=c(ranger_prediction,ens_results[[idx_fold]][[4]][,1])
  XGB_prediction=c(XGB_prediction,ens_results[[idx_fold]][[4]][,2])
  catB_prediction=c(catB_prediction,ens_results[[idx_fold]][[4]][,3])

  
  #for testing the ensemble
  ens_DB_test=df[idx_out[[idx_fold]],]  
  ens_DB_test$spacevar=paste0(ens_DB_test$x,"-",ens_DB_test$y)
  y_true=c(y_true,ens_DB_test$resid)
  grid_id=c(grid_id,ens_DB_test$spacevar)
  x=c(x,ens_DB_test$x)
  y=c(y,ens_DB_test$y)
  time=c(time,ens_DB_test$time) 
  
}

#overall metrics
(global_metrics=postResample(pred=all_prediction, obs=y_true))
(ranger_metrics=postResample(pred=ranger_prediction, obs=y_true))
(XGB_metrics=postResample(pred=XGB_prediction, obs=y_true))
(catB_metrics=postResample(pred=catB_prediction, obs=y_true))

#gather all_data and make it sf
all_data=data.frame(X=x,Y=y,time=time,
			      ranger=ranger_prediction, XGB=XGB_prediction,catB=catB_prediction, 
             		      pred.no2.cv=all_prediction,
			      y_true=y_true)
sf_data=all_data %>% mutate(month=lubridate::month(as.Date(paste0(current_year,"-01-01")) + time - 1))  %>% 
			st_as_sf(coords=c("X","Y"),crs=st_crs(2154))

#load monitor data and make it sf 
all_mon=read.csv("/bettik/barbalag/data/monitor_data/all_stations.csv",sep=";") %>%
		select(Longitude,Latitude,Implantation) %>%
		st_as_sf(coords=1:2,crs=st_crs(4326)) %>%
		st_transform(crs=st_crs(2154))

#join and summarize metrics
all_mon_jn=st_join(sf_data,all_mon)
metrics_implantation=all_mon_jn %>% st_drop_geometry() %>%
		group_by(Implantation) %>%
			summarise(ranger=postResample(pred=ranger, obs=y_true),
				  XGB=postResample(pred=XGB, obs=y_true),
				  catB=postResample(pred=catB, obs=y_true),
				  ens=postResample(pred=pred.no2.cv, obs=y_true)) %>%
			mutate(metrics=c("RMSE","R2","MAE")) %>%
			tidyr::pivot_wider(names_from=metrics,values_from=c(ranger,XGB,catB,ens))

metrics_month_implantation=all_mon_jn %>% st_drop_geometry() %>%
		group_by(Implantation,month) %>%
			summarise(ranger=postResample(pred=ranger, obs=y_true),
				  XGB=postResample(pred=XGB, obs=y_true),
				  catB=postResample(pred=catB, obs=y_true),
				  ens=postResample(pred=pred.no2.cv, obs=y_true)) %>%
			mutate(metrics=c("RMSE","R2","MAE")) %>%
			tidyr::pivot_wider(names_from=metrics,values_from=c(ranger,XGB,catB,ens))

metrics_month=all_mon_jn %>% st_drop_geometry()  %>% group_by(month) %>%
			summarise(ranger=postResample(pred=ranger, obs=y_true),
				  XGB=postResample(pred=XGB, obs=y_true),
				  catB=postResample(pred=catB, obs=y_true),
				  ens=postResample(pred=pred.no2.cv, obs=y_true)) %>%
			mutate(metrics=c("RMSE","R2","MAE")) %>%
			tidyr::pivot_wider(names_from=metrics,values_from=c(ranger,XGB,catB,ens))


##################################################################
#spatial and temporal Metricx and save all Metrics
##################################################################
  mod.all=data.frame(grid_id=grid_id,
                     no2_mon=y_true,
		     time=time,
                     pred.no2.cv=all_prediction,
		     ranger=ranger_prediction, XGB=XGB_prediction,catB=catB_prediction
  ) #%>%
  #mutate(month=lubridate::month(as.Date("2020-01-01") + time - 1))

  # Spatial
  spatial_all <- mod.all %>%
    group_by(grid_id) %>%
    dplyr::summarize(
      bar_no2_mon= mean(no2_mon),
      bar_pred = mean(pred.no2.cv),
      bar_ranger = mean(ranger),
      bar_XGB = mean(XGB),
      bar_catB=mean(catB)
  )

  # 
# spatial_month <- mod.all %>%
#   group_by(grid_id,month) %>%
#   dplyr::summarize(
#     bar_no2_mon= mean(no2_mon),
#     bar_pred = mean(pred.no2.cv),
#     bar_ranger = mean(ranger),
#     bar_XGB = mean(XGB),
#     bar_catB=mean(catB)
#   )


 # Temporal
  temporal_all    <- left_join(mod.all,spatial_all)
  del_no2         <- temporal_all$no2_mon-temporal_all$bar_no2_mon
  del_pred        <- temporal_all$pred.no2.cv-temporal_all$bar_pred
  del_ranger      <- temporal_all$ranger-temporal_all$bar_ranger
  del_XGB         <- temporal_all$XGB-temporal_all$bar_XGB
  del_catB        <- temporal_all$catB-temporal_all$bar_catB

# temporal_month    <- left_join(mod.all,spatial_month)
# del_no2_m         <- temporal_month$no2_mon-temporal_month$bar_no2_mon
# del_pred_m        <- temporal_month$pred.no2.cv-temporal_month$bar_pred
# del_ranger_m      <- temporal_month$ranger-temporal_month$bar_ranger
# del_XGB_m         <- temporal_month$XGB-temporal_month$bar_XGB
# del_catB_m        <- temporal_month$catB-temporal_month$bar_catB

  sp_temp_metrics <- function(spatial,temporal) {

  # Spatial
  m1.fit.all.s    <- lm(spatial_mon ~ spatial) #bar_pred
  r2.spatial      <- summary(m1.fit.all.s)$r.squared
  rmse.spatial    <- ModelMetrics::rmse(modelObject = m1.fit.all.s)
  #mae.spatial     <- ModelMetrics::mae(modelObject = m1.fit.all.s)
  spatial.inter   <- summary(m1.fit.all.s)$coef[1,1]
  spatial.slope   <- summary(m1.fit.all.s)$coef[2,1]
  
  # Temporal
  mod_temporal    <- lm(temporal_mon ~ temporal)#del_pred
  r2.temporal     <- summary(mod_temporal)$r.squared
  rmse.temporal   <- ModelMetrics::rmse(modelObject = mod_temporal)
  #mae.temporal   <- ModelMetrics::mae(modelObject =  glm(del_no2 ~ temporal))
  temporal.inter  <- summary(mod_temporal)$coef[1,1]
  temporal.slope  <- summary(mod_temporal)$coef[2,1]

  all_metrics=c(r2.spatial,rmse.spatial,spatial.inter,spatial.slope,
		r2.temporal,rmse.temporal,temporal.inter,temporal.slope)
  
  return(all_metrics)
 }#end of function

#spatial and temporal metrics
spatial_mon=spatial_all$bar_no2_mon 
temporal_mon=del_no2

ens_metrics_ST=sp_temp_metrics(spatial_all$bar_pred,del_pred)
ranger_metrics_ST=sp_temp_metrics(spatial_all$bar_ranger,del_ranger)
XGB_metrics_ST=sp_temp_metrics(spatial_all$bar_XGB,del_XGB)
catB_metrics_ST=sp_temp_metrics(spatial_all$bar_catB,del_catB)

# #spatial and temporal metrics for the month
# spatial_mon=spatial_month$bar_no2_mon 
# temporal_mon=del_no2_m
# 
# ens_metrics_m=sp_temp_metrics(spatial_month$bar_pred,del_pred_m)
# ranger_metrics_m=sp_temp_metrics(spatial_month$bar_ranger,del_ranger_m)
# XGB_metrics_m=sp_temp_metrics(spatial_month$bar_XGB,del_XGB_m)
# catB_metrics_m=sp_temp_metrics(spatial_month$bar_catB,del_catB_m)

  save(global_metrics,ranger_metrics,XGB_metrics,catB_metrics,#overall
       metrics_implantation, metrics_month,metrics_month_implantation,#for each month/implantation zone
       ens_metrics_ST,ranger_metrics_ST,XGB_metrics_ST,catB_metrics_ST,#sp and temporal#ST
       file=paste0("all_metrics_ens_",current_year,".RData")
  )

}#end of loop