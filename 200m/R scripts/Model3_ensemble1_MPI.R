rm(list=ls())

load_monitors=0
source("header_200m.R")

start_time=Sys.time()

library(parallel)
library(doMC)
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
#path_to=""

##################################################################
#formula for ensembling
##################################################################
formula1 <- all_ytrue_sub ~ te(all_x_sub,all_y_sub,all_time_sub,
                               by=all_predRanger_sub,
                               bs="cr",#bs=c("tp","cr"),
                               #d=c(2,1),
                               k=3) +
  te(all_x_sub,all_y_sub,all_time_sub,
     by=all_predXGB_sub,
     bs="cr",
     k=3) +
  te(all_x_sub,all_y_sub,all_time_sub,
     by=all_predcatboost_sub,
     bs="cr",#bs=c("tp","cr"),
     #d=c(2,1),
     k=3)#k=c(10,5))
##################################################################

##################################################################
#to calculate metrics
##################################################################
calculateMMetrics <- function(y_true,y_hat) {
  out<-apply(y_hat,2,postResample,obs=y_true)
  return(out)
}
##################################################################


############################################################################
#calculate ensemble prediction for each fold
############################################################################

##########
# predictions from basis lrn (Model2) for each fold
##########
#ranger_results[[idx_fold]][[3]]
load(paste0(path_to,"all_predict_ranger_folds_",current_year,".RData"))
#xgb_results[[idx_fold]][[3]]
load(paste0(path_to,"all_predict_xgb_folds_",current_year,".RData"))
#catboost_results[[idx_fold]][[3]]
load(paste0(path_to,"all_predict_catboost_folds_",current_year,".RData"))

###########
#prediction from basis lrn () for each fold
###########
blockCV="STBlMo_5F"
file_is=paste0("holdout_folds_",blockCV,"_",current_year,"_POST_basislrn.RData")
load(file=paste0(path_to,file_is))
nfolds=length(tmp)
predictors=tmp[[1]] %>% select(-all_ytrue_sub) %>% colnames()

###########
#ensemble predictions
###########
calculate_predictions <- function(idx_fold) {
  
  print(idx_fold)
  
  ens_DB_train=tmp[[idx_fold]]
  
  ens_DB_test_ranger=ranger_results[[idx_fold]][[3]]
  #ens_DB_test_xgb=rnorm(n=length(ranger_results[[idx_fold]][[3]]), mean = 0, sd = 1)
  ens_DB_test_xgb=xgb_results[[idx_fold]][[3]]
  ens_DB_test_catboost=catboost_results[[idx_fold]][[3]]  
  ens_DB_test=data.frame(all_predRanger_sub=ens_DB_test_ranger,
                         all_predXGB_sub=ens_DB_test_xgb,
                         all_predcatboost_sub=ens_DB_test_catboost,
                         all_x_sub=df[idx_out[[idx_fold]],"x"],
                         all_y_sub=df[idx_out[[idx_fold]],"y"],
                         all_time_sub=df[idx_out[[idx_fold]],"time"],
                         all_ytrue_sub=df[idx_out[[idx_fold]],"resid"]
  )
  
  #fit ensemble
  mod <- gam(formula1,family=gaussian(),
             data = ens_DB_train
  )
  
  #predict test set
  pred = predict.gam(mod,select(ens_DB_test,all_of(predictors)))
  
  #model Metrics
  print(calculateMMetrics(y_true=ens_DB_test$all_ytrue_sub,
                          y_hat=matrix(pred,ncol=1)))
  MMetrics=calculateMMetrics(y_true=ens_DB_test$all_ytrue_sub,
                             y_hat=matrix(pred,ncol=1))
  
  return(list(mod,pred,MMetrics,ens_DB_test))
  
}#end of function
####################################################################
####################################################################
ens_results=lapply(1:nfolds, calculate_predictions)
save(ens_results,file=paste0("all_predict_ens_folds_",current_year,".RData"))


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
all_data=data.frame(x=x,y=y,time=time,
			      ranger=ranger_prediction, XGB=XGB_prediction,catB=catB_prediction, 
             		      pred.no2.cv=all_prediction,
			      y_true=y_true)
sf_data=all_data %>% mutate(month=lubridate::month(as.Date(paste0(current_year,"-01-01")) + time - 1))  %>% 
			st_as_sf(coords=c("x","y"),crs=st_crs(2154))

#load monitor data and make it sf 
all_mon=read.csv("/bettik/barbalag/data/monitor_data/all_stations.csv",sep=",") %>%
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


##################################################################
##predict all data
##################################################################


##################################################################
#Roberts Method 1 (using model for stacked data)
##################################################################
nc=detectCores()

#train on all available (stacked) data and predict all Data
#this is obtained from basis_lrn_etc... script
ens_DB_train=do.call("rbind",tmp)

#fit ensemble
mod1 <- gam(formula1,family=gaussian(),
            data = ens_DB_train
)
save(mod1,file=paste0("mod1_",current_year,".RData"))


####################
#load allData
####################
n_parts=12
for (i in 1:n_parts) {
load(paste0(path_to,"all_predict_ranger1_",current_year,"_",i,".RData"))#all predictions 1 & 2 correspond to Roberts 1 and 2
load(paste0(path_to,"all_predict_xgb1_",current_year,"_",i,".RData"))#all predictions 1 & 2 correspond to Roberts 1 and 2
load(paste0(path_to,"all_predict_catboost1_",current_year,"_",i,".RData"))#all predictions 1 & 2 correspond to Roberts 1 and 2

#test from all_predict_(ranger)1 etc...
data4_Model3=data.frame(all_x_sub=all_predict_ranger1$x,
                        all_y_sub=all_predict_ranger1$y,
                        all_time_sub=all_predict_ranger1$time,
                        all_predRanger_sub=all_predict_ranger1$predict_ranger1,
                        all_predXGB_sub=all_predict_xgb1$predict_xgb1,
                        all_predcatboost_sub=all_predict_catboost1$predict_catboost1
)

crows <- splitIndices ( nrow ( data4_Model3) , nc ) # mc
rfp <- function(x) as.vector(predict.gam(mod1,dplyr::select(data4_Model3,all_of(predictors))[x , ]) ) # mc
cpred <- lapply ( crows , rfp) # mc
predict_ens1<- do.call (c, cpred ) # mc
all_predict_ens1=cbind(predict_ens1,data4_Model3)
save(all_predict_ens1, file=paste0("all_predict_ens1_",current_year,"_",i,".RData"))

rm(all_predict_ens1,predict_ens1,data4_Model3,cpred,all_predict_xgb1,all_predict_ranger1,all_predict_catboost1)
}

print("yeah! you've reached the end of the ensemble modelling")

end_time=Sys.time()
print(end_time-start_time)
