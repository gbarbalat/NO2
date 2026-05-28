rm(list=ls())

library(parallel)
library(doMC)
library(MLmetrics)
library(caret)
library(CAST)
library(plyr)
library(dplyr)
library(catboost)
library(sf)
library(stars)
library(spdep)
library(lubridate)

#stop(nrow(idx_out[[1]]))
##############################
#header
##############################
catboost=TRUE
source("header_MPI.R")

start_time=Sys.time()


which_outcome="no2_monitors"
which_folds_type="STBlMo_5F"
path_to="/bettik/barbalag/"

#trainDat,testData,idx_folds
load(file=paste0(path_to,"holdout_folds_",which_folds_type,"_",current_year,".RData"))
df= df %>% mutate(time_day = time %% 7) %>% 
	   mutate(time_month = month(as.Date(time, origin = paste0(current_year-1,"-12-31")))) %>%
	   mutate(no2_monitors=day_mean) %>% select(-day_mean) %>% 
  	   select(-c("spacevar","spacetimevar","period","spaceperiodvar" ))

metric="R2"
nfolds=length(idx_folds)
nfolds_caret=5
tuneLength=5
sp_temp_metrics=TRUE
residuals=FALSE

##########
#predictors
predictors=df %>% 
  dplyr::select(!contains(c("no2_monitors"))) %>% 
  #select(!contains(c("dist_nearest"))) %>%
  colnames()

##########

##############################

#####################################
#which metrics?
#####################################
#overall RMSE, MAE, R2
#geospatial and temporal
defaultSummaryCustom = function (data, lev = NULL, model = NULL) 
{
  out<-postResample(data[, "pred"], data[, "obs"])
  names(out) <- c("RMSE", "R2", "MAE")
  out
}

#####################################
#function to calculate metrics
#####################################
#overall RMSE, MAE, R2
#geospatial and temporal
calculateMMetrics <- function(y_true,y_hat) {
  out<-apply(y_hat,2,postResample,obs=y_true)
  return(out)
}


#to concatenate CV-predictions
predictions_NO2_catboost=list()

############################################################################
#main function using caret
############################################################################
fitControl <- caret::trainControl(method = "adaptive_cv",#boot #cv #oob #adaptive_cv #repeatedcv
                                        adaptive = list(min =3,                 # minimum number of resamples per hyperparameter
                                                        alpha =0.05,            # Confidence level for removing hyperparameters
                                                        method = "BT",# Bradly-Terry Resampling method (here you can instead also use "gls")
                                                        complete = FALSE),      # If TRUE a full resampling set will be generated 
                                        number =nfolds_caret,
                                        allowParallel = TRUE,
                                        #repeats = 1,#the number of complete sets of folds to compute
                                        index=NULL,
					verboseIter=TRUE,
                                        classProbs = FALSE,
                                        summaryFunction = defaultSummaryCustom,#multiClassSummary defaultSummary
                                        search = "random",#random or grid
                                        preProcOptions = list(thresh = 0.95, #cumulative percent of variance to be retained by PCA
                                                              ICAcomp = 3, 
                                                              k = 5, knnSummary=mean,
                                                              freqCut = 95/5, #95% of most common compared to 2nd most common
                                                              uniqueCut =10,
                                                              cutoff = 0.9,#for correlation cutoff
                                                              na.remove = TRUE
                                        ),
                                        savePredictions="final"
      )

############################################################################
calculate_predictions <- function(idx_fold=NULL,sub_train=NULL, sub_test=NULL) {
  
  if (!!length(idx_fold)) {
    print(idx_fold)
    sub_test=df[idx_out[[idx_fold]],]# %>% select(c(all_of(predictors),"no2_monitors"))
    sub_train=df[idx_folds[[idx_fold]],] #%>% select(c(all_of(predictors),"no2_monitors"))
  }
  
  ##############################################################################
  preproc_f=caret::preProcess(sub_train %>% select(-contains(c("no2_monitors","time","X","Y"))),#
                              method=c("corr","center","scale"),
                              cutoff=0.95)
  predictors=predictors[predictors %in% colnames(predict(preproc_f,sub_train))]
  
  sub_train=predict(preproc_f,sub_train)
  sub_test=predict(preproc_f,sub_test)
  ##############################################################################

      hyper_params <- caret::train(y=sub_train$no2_monitors,
			           x=dplyr::select(sub_train,c(all_of(predictors))),
				   method = catboost.caret,
                                   preProcess=NULL,
                                   tuneGrid = NULL,
                                   tuneLength=tuneLength,
                                   trControl = fitControl,
                                   metric = metric,#ROC Sens, Spec Mean_Neg_Pred_Value R2
                                   maximize=TRUE,
				   verbose=0
                                   # ,na.action=na.pass
      )

CV_predict_catboost=predict.train(hyper_params,
                                 dplyr::select(sub_test,all_of(predictors))
)

#importance
catboostImportance=varImp(hyper_params)

#evaluate predictions
    if (!!length(sub_test$no2_monitors)) {
    catboostMetrics=calculateMMetrics(y_true=sub_test$no2_monitors,
                                    y_hat=matrix(CV_predict_catboost,ncol=1))
    } else {catboostMetrics=NULL}

    #save predictions
    predictions_NO2_catboost=CV_predict_catboost

return(list(catboostImportance,catboostMetrics,predictions_NO2_catboost,hyper_params,preproc_f))
  
}#end of function
############################################################################
############################################################################
nc=detectCores()
catboost_results=mclapply(1:nfolds, calculate_predictions,mc.cores=nc)
save(catboost_results,file=paste0("all_predict_catboost_folds_",current_year,".RData"))


##########
#predict the whole area: Roberts Method 1
##########
#train on all available data and predict all Data
print("fit model on whole available monitors")
sub_train=df 
##############################################################################
  preproc_f=caret::preProcess(sub_train %>% select(-contains(c("no2_monitors","time","X","Y"))),##########
                              method=c("corr","center","scale"),
                              cutoff=0.95)
  predictors=predictors[predictors %in% colnames(predict(preproc_f,sub_train))]
  
  sub_train=predict(preproc_f,sub_train)
  ##############################################################################
      
      hyper_params <- caret::train(y=sub_train$no2_monitors,
			           x=dplyr::select(sub_train,c(all_of(predictors))),
				   method = catboost.caret,
                                   preProcess=NULL,
                                   tuneGrid = NULL,
                                   tuneLength=tuneLength,
                                   trControl = fitControl,
                                   metric = metric,#ROC Sens, Spec Mean_Neg_Pred_Value R2
                                   maximize=TRUE,
				   verbose=0
                                   # ,na.action=na.pass
      )


##########
#allData
##########
load(file=paste0(path_to,"data4_Model2_",current_year,".RData"))
data4_Model2= data4_Model2 %>% as.data.frame() %>%
			      na.omit() %>%
			      mutate(time_day = time %% 7)  %>% 
              		      mutate(time_month = month(as.Date(time, origin = paste0(current_year-1,"-12-31")))) 

data4_Model2=split(data4_Model2, f = data4_Model2$time_month)
#data4_Model2= data4_Model2 %>% nest(.by = time_month)
##########

for (i_test in 1:length(data4_Model2)) {

sub_test = data4_Model2[[i_test]]
	
	for (i in 2:40) {
		#file_to_predict=paste0("updated_DMraster_France_var",i,"_",current_year,".RData")
		file_to_predict=paste0("updated_DMraster_France_var",i,"_month",i_test,"_",current_year,".RData")
		load(file=paste0(path_to,file_to_predict))

		updated_DMdf= updated_DMraster %>% as.data.frame() %>%
				   na.omit() #%>% ##########
				   #mutate(time_day = time %% 7,##########
				   #    time_month = month(as.Date(time, origin = paste0(current_year-1,"-12-31")))##########
				   #   )##########
		#updated_DMdf=split(updated_DMdf, f = updated_DMdf$time_month)##########
		#sub_test = sub_test %>% cbind(dplyr::select(updated_DMdf[[i_test]],-c(time,time_day,time_month,x,y)))
		sub_test = sub_test %>% cbind(dplyr::select(updated_DMdf,-c(time,x,y)))

	}
sub_test=predict(preproc_f,sub_test)

crows <- splitIndices ( nrow ( sub_test ) , nc ) # mc
rfp <- function(x) as.vector(predict.train(hyper_params, dplyr::select(sub_test,all_of(predictors))[x , ]) ) # mc
cpred <- lapply ( crows , rfp) # mc
catboost_Roberts1<- do.call (c, cpred ) # mc
all_predict_catboost1=cbind(predict_catboost1=catboost_Roberts1,dplyr::select(sub_test,c(X,Y,time)))
save(all_predict_catboost1,file=paste0("all_predict_catboost1_month",i_test,"_",current_year,".RData"))

rm(all_predict_catboost1,catboost_Roberts1,sub_test,updated_DMdf,updatedDM_raster)
}

#
#




##########
#Model Metrics - save
##########
y_true=NULL
all_prediction=NULL
grid_id=NULL
X=NULL
Y=NULL
time=NULL
all_predict_catboost2=list()
all_metrics_folds=list()
all_importance_folds=list()

for (idx_fold in 1:nfolds) {

print(idx_fold)
(all_metrics_folds[[idx_fold]]=catboost_results[[idx_fold]][[2]])
all_importance_folds[[idx_fold]]=catboost_results[[idx_fold]][[1]]

sub_test=df[idx_out[[idx_fold]],]
all_prediction=c(all_prediction,catboost_results[[idx_fold]][[3]])
y_true=c(y_true,sub_test$no2_monitors)
grid_id=c(grid_id,paste0(sub_test$X,"-",sub_test$Y))
X=c(X,sub_test$X)
Y=c(Y,sub_test$Y)
time=c(time,sub_test$time)

}
(global_metrics=postResample(pred=all_prediction, obs=y_true))
print(global_metrics)


##########
#spatial and temporal Metricx
##########
if(sp_temp_metrics) {

mod.all=data.frame(grid_id=grid_id,
		   no2_mon=y_true,
		   pred.no2.cv=all_prediction
)
# Spatial
spatial_all <- mod.all %>%
  group_by(grid_id) %>%
  dplyr::summarize(
    bar_no2_mon= mean(no2_mon),
    bar_pred = mean(pred.no2.cv))

m1.fit.all.s    <- lm(bar_no2_mon ~ bar_pred, data=spatial_all)
r2.spatial      <- summary(m1.fit.all.s)$r.squared
rmse.spatial    <- ModelMetrics::rmse(modelObject = m1.fit.all.s)
spatial.inter   <- summary(m1.fit.all.s)$coef[1,1]
spatial.slope   <- summary(m1.fit.all.s)$coef[2,1]

# Temporal
temporal_all    <- left_join(mod.all,spatial_all)
del_no2         <- temporal_all$no2_mon-temporal_all$bar_no2_mon
del_pred        <- temporal_all$pred.no2.cv-temporal_all$bar_pred
mod_temporal    <- lm(del_no2 ~ del_pred)
r2.temporal     <- summary(mod_temporal)$r.squared
rmse.temporal   <- ModelMetrics::rmse(modelObject = mod_temporal)
temporal.inter  <- summary(mod_temporal)$coef[1,1]
temporal.slope  <- summary(mod_temporal)$coef[2,1]
save(global_metrics,all_metrics_folds, all_importance_folds, 
     r2.spatial, rmse.spatial, spatial.inter, spatial.slope,
     r2.temporal, rmse.temporal, temporal.inter, temporal.slope,
     file=paste0("all_metrics_catboost_",current_year,".RData")
)
}
print("yeah! you've reached the end of your script (a.k.a point G)")

end_time=Sys.time()
print(end_time-start_time)
