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
library(fst)

create_index_lists <- function(df, nc) {
  total_rows <- nrow(df)
  
  # Create a sequence of row numbers
  all_indices <- seq_len(total_rows)
  
  # Use cut to create groups
  groups <- cut(all_indices, breaks = nc, labels = FALSE)
  
  # Split the indices based on the groups
  index_lists <- split(all_indices, groups)
  
  return(index_lists)
}

#stop(nrow(idx_out[[1]]))
##############################
#header
##############################
catboost=TRUE
load_monitors=0
source("header_200m.R")

start_time=Sys.time()


which_outcome="resid"
which_folds_type="STBlMo_5F"
path_to="/bettik/barbalag/200m_header/"

#trainDat,testData,idx_folds
load(file=paste0(path_to,"holdout_folds_",which_folds_type,"_",current_year,".RData"))
df= df %>% mutate(time_day = time %% 7) %>% 
	   mutate(time_month = month(as.Date(time, origin = paste0(current_year-1,"-12-31")))) %>%
	   select(-day_mean) %>% 
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
  dplyr::select(!contains(c("resid"))) %>% 
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
  preproc_f=caret::preProcess(sub_train %>% select(-contains(c("resid","time","x","y"))),#
                              method=c("corr","center","scale"),
                              cutoff=0.95)
  predictors=predictors[predictors %in% colnames(predict(preproc_f,sub_train))]
  
  sub_train=predict(preproc_f,sub_train)
  sub_test=predict(preproc_f,sub_test)
  ##############################################################################

      hyper_params <- caret::train(y=sub_train$resid,
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
    if (!!length(sub_test$resid)) {
    catboostMetrics=calculateMMetrics(y_true=sub_test$resid,
                                    y_hat=matrix(CV_predict_catboost,ncol=1))
    } else {catboostMetrics=NULL}

    #save predictions
    predictions_resid_catboost=CV_predict_catboost

return(list(catboostImportance,catboostMetrics,predictions_resid_catboost,hyper_params,preproc_f))
  
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
  preproc_f=caret::preProcess(sub_train %>% select(-contains(c("resid","time","x","y"))),##########
                              method=c("corr","center","scale"),
                              cutoff=0.95)
  predictors=predictors[predictors %in% colnames(predict(preproc_f,sub_train))]
  
  sub_train=predict(preproc_f,sub_train)
  ##############################################################################
      
      hyper_params <- caret::train(y=sub_train$resid,
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

#data4_Model2=split(data4_Model2, f = data4_Model2$time_month)
length_to_skip=0
length_sub_test=length_sub_test #data4Model2 TOT/12
nsplit=12

for (i_test in 1:nsplit) {
  sub_test = read_fst(paste0(current_year,"_pred_res_200.RData.fst"), 
                      from = length_to_skip + 1, 
                      to = length_to_skip + length_sub_test,
                      columns = c("x","y","time","predict_ens1")) %>% #, "time_day", "time_month"
    mutate(time_day = time %% 7) %>% 
    mutate(time_month = month(as.Date(time, origin = paste0(current_year-1,"-12-31"))))
  
  head(sub_test)
  length_sub_test = nrow(sub_test)
  
  # load them all
  files_to_predict <- dir(pattern="*_200.RData.fst")
  for (i_file in 1:length(files_to_predict)) {
    if (files_to_predict[i_file] == paste0(current_year,"_pred_res_200.RData.fst")) {next} # skip _pred_res_200.RData.fst
    
    updated_DMdf = read_fst(files_to_predict[i_file], 
                            from = length_to_skip + 1, 
                            to = length_to_skip + length_sub_test,
                            columns = c("x","y", gsub(paste0(current_year,"_(.+)_200.*"), "\\1", files_to_predict[i_file])))
    
    sub_test = sub_test %>% cbind(dplyr::select(updated_DMdf, -c(x,y)))
  }
  
  print(i_test)
  head(sub_test)
  sub_test = predict(preproc_f, sub_test)
  
  crows <- create_index_lists(sub_test, nc)
  
  rfp <- function(idx) as.vector(predict.train(hyper_params, dplyr::select(sub_test, all_of(predictors))[idx, ]))
  cpred <- lapply(crows, rfp)
  catboost_Roberts1 <- do.call(c, cpred)
  all_predict_catboost1 = cbind(predict_catboost1 = catboost_Roberts1, dplyr::select(sub_test, c(x,y,time)))
  save(all_predict_catboost1, file = paste0("all_predict_catboost1_", current_year, "_", i_test, ".RData"))
  length_to_skip = length_to_skip + length_sub_test
  
  rm(all_predict_catboost1, catboost_Roberts1, sub_test, updated_DMdf, updatedDM_raster)
}




##########
#Model Metrics - save
##########
y_true=NULL
all_prediction=NULL
grid_id=NULL
x=NULL
y=NULL
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
y_true=c(y_true,sub_test$resid)
grid_id=c(grid_id,paste0(sub_test$x,"-",sub_test$y))
x=c(x,sub_test$x)
y=c(y,sub_test$y)
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