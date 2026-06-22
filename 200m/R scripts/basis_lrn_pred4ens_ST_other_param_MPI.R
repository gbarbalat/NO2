#this is to compute predictions from basis lrnr for future ensembling
#you first read file=paste0("holdout_folds_%YOUR SCHEME%_",current_year,".RData")
#(df,idx_folds,idx_out)
#then for each idx_fold, you divide df[idx_folds[[idx_fold]],] which is one of the training set of the ensemble model, into K folds
#in other words, your idx_folds[[idx_fold]] is your new testing sets that you'll predict with your basis lrnr

#this function creates folds manually and using caret groupKfold function
#3 blocking schemes are implemented
#1- one test fold = whole data series from a monitor (N_monitor folds)
#2- one test fold = 1 monitor for a single date (500 folds using groupKfold)
#3- one test fold = 1 monitor for a specific period with left- and right-sided buffers ()
#buffer is based on temporal and spatial auto-correlation (spatio-temporal variogram)

rm(list=ls())

library(caret)
library(plyr)
library(dplyr)
library(catboost)
library(sf)
library(lubridate)

#stop(nrow(idx_out[[1]]))
##############################
#header
##############################
catboost=TRUE
load_monitors=0
source("header_200m.R")

start_time=Sys.time()

which_outcome="no2_monitors"
which_folds_type="STBlMo_5F"
#HERE CHANGE
path_to="/bettik/barbalag/200m_header/"
file_is=paste0("holdout_folds_",which_folds_type,"_",current_year,".RData")

#trainDat,testData,idx_folds
load(file=paste0(path_to,file_is))
df= df %>% mutate(time_day = time %% 7) %>% 
  mutate(time_month = month(as.Date(time, origin = paste0(current_year-1,"-12-31")))) %>%
  #mutate(no2_monitors=day_mean) %>% select(-day_mean) %>% 
  select(-c("spacevar","spacetimevar","spaceperiodvar"))

#HERE CHANGE x 10
metric="R2"
nfolds=length(idx_folds)
#nfolds=1
nfolds_sub=4
#nfolds_sub=2
nfolds_caret=4
#nfolds_caret=2
tuneLength=4
#tuneLength=2

##############################

############
#fit control param
###############
defaultSummaryCustom = function (data, lev = NULL, model = NULL) 
{
  out<-postResample(data[, "pred"], data[, "obs"])
  names(out) <- c("RMSE", "R2", "MAE")
  out
}

#HERE CHANGE
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
                                                        cutoff = 0.95,#for correlation cutoff
                                                        na.remove = TRUE
                                  ),
                                  savePredictions="final"
)


########################################
#a whole ts in the testing set
########################################

#start with testData
idx_out_sub=list()
idx_folds_sub=list()

tmp=list()#train

for (idx_fold in (1:nfolds)) {#  outer folds 1:nfolds
    
  df_sub=df[idx_folds[[idx_fold]],] #train
  df_test=df[idx_out[[idx_fold]],] #test
  
  all_predRanger_sub=NULL
  all_predXGB_sub=NULL
  all_predcatboost_sub=NULL
  all_x_sub=NULL
  all_y_sub=NULL
  all_time_sub=NULL
  all_ytrue_sub=NULL
  
  Nseed=123
  idx_folds_sub=NULL
  k=0
  while (length(idx_folds_sub)!=nfolds_sub) {
    set.seed(Nseed+k)
    idx_folds_sub=caret::groupKFold(df_sub$period, nfolds_sub) 
    k=k+1
  }
  
  idx_out_sub=list()
  idx_rm_all=NULL
  
  for (i in 1:length(idx_folds_sub)) {#inner folds
    
    print(i)
    
    ##function
    find_sub_train_test=function(df_sub) {
      
      idx_rm_all=NULL
      idx_out_sub[[i]]= setdiff(1:nrow(df_sub),idx_folds_sub[[i]])
      
      trainDat=df_sub[idx_folds_sub[[i]],]
      testDat=df_sub[idx_out_sub[[i]],] 
      
      for (j in (1:length(unique(testDat$period)))) {
        
        period_idx=unique(testDat$period)[j]
        testDat2=testDat %>% filter(period==period_idx) 
        
        #temporal windows for temporal buffer
        time_min=min(testDat2$time)
        time_max=max(testDat2$time)
        
        testDat2_sf=st_as_sf(testDat2,coords=c("x","y"))
        trainDat_sf=st_as_sf(trainDat,coords=c("x","y"))
        k=st_is_within_distance(trainDat_sf, testDat2_sf,dist=buffer_dist, sparse=F)
        
        idx_rm=which(lengths(k)>0 & (trainDat$time <= time_max +buffer_size & trainDat$time >= time_min-buffer_size))
        idx_rm_all=c(idx_rm_all,idx_rm)
      }
      
      idx_folds_sub[[i]]=idx_folds_sub[[i]][-idx_rm_all]
      
      
      #run basis learner for this fold and gather predictions
      sub_train=df_sub[idx_folds_sub[[i]],]
      
      #CV predictions
      sub_test=df_sub[idx_out_sub[[i]],]
      
      predictors=df_sub %>% dplyr::select(!contains(c("resid","spacevar","spacetimevar","period","spaceperiodvar"))) %>% 
        colnames()

      #### corr, center, scale
      preproc_f=caret::preProcess(sub_train %>% select(-contains(c("resid","time","x","y"))),#
                                  method=c("corr","center","scale"),
                                  cutoff=0.95)
      predictors=predictors[predictors %in% colnames(predict(preproc_f,sub_train))]
      
      sub_train=predict(preproc_f,sub_train)
      sub_test=predict(preproc_f,sub_test)
      
      return(list(sub_train,sub_test, predictors))
    }#end of function
    ##
    
    ##############################################################################
    out_f=find_sub_train_test(df_sub)
    sub_train=out_f[[1]]
    sub_test=out_f[[2]]
    predictors=out_f[[3]]
    
    ##########
    #ranger
    ##########
    hyper_params_ranger= caret::train(y=sub_train$resid,
                                      x=dplyr::select(sub_train,all_of(predictors)),
                                      method = "ranger",
                                      preProcess=NULL,
                                      trControl = fitControl,
                                      tuneGrid = NULL,
                                      tuneLength=tuneLength,
                                      metric = metric,#"Rsquared",
                                      maximize=TRUE
                                      # ,na.action=na.pass
    )
    all_predict_ranger=predict(hyper_params_ranger,
                               dplyr::select(sub_test,
                                             all_of(predictors))
    )
    message("ranger done");rm(hyper_params_ranger)
    
    ##########
    #XGB
    ##########
    hyper_params_XGB = caret::train(y=sub_train$resid,
                                    x=dplyr::select(sub_train,all_of(predictors)),
                                    method = "xgbTree",
                                    preProcess=NULL,
                                    trControl = fitControl,
                                    tuneGrid = NULL,
                                    tuneLength=tuneLength,
                                    metric = metric,#"Rsquared",
                                    maximize=TRUE,
                                    verbose=0
                                    # ,na.action=na.pass
    )
    all_predict_xgb=predict(hyper_params_XGB,
                            dplyr::select(sub_test,
                                          all_of(predictors))
    )
    message("xgb done");rm(hyper_params_XGB)
    
    
    ##########
    #catboost
    ##########
    hyper_params_catboost = caret::train(y=sub_train$resid,
                                    x=dplyr::select(sub_train,all_of(predictors)),
                                    method = catboost.caret,
                                    preProcess=NULL,
                                    trControl = fitControl,
                                    tuneGrid = NULL,
                                    tuneLength=tuneLength,
                                    metric = metric,#"Rsquared",
                                    maximize=TRUE,
                                    verbose=0
                                    # ,na.action=na.pass
    )
    all_predict_catboost=predict(hyper_params_catboost,
                            dplyr::select(sub_test,
                                          all_of(predictors))
    )
    message("catboost done");rm(hyper_params_catboost)
    
    ##########
    #compile predictions, x, y, time, y_true
    ##########
    all_predRanger_sub=c(all_predRanger_sub,all_predict_ranger)
    all_predXGB_sub=c(all_predXGB_sub,all_predict_xgb)
    all_predcatboost_sub=c(all_predcatboost_sub,all_predict_catboost)
    
    all_x_sub=c(all_x_sub,sub_test$x)
    all_y_sub=c(all_y_sub,sub_test$y)
    all_time_sub=c(all_time_sub,sub_test$time)
    all_ytrue_sub=c(all_ytrue_sub,sub_test$resid)	
    
  }#end of inner folds
  
  #tmp[[idx_fold]]=data.frame(all_predRanger_sub,all_predXGB_sub,all_predcatboost_sub,
  #                           all_x_sub,all_y_sub,all_time_sub,all_ytrue_sub)
  tmp_tmp=data.frame(all_predRanger_sub,all_predXGB_sub,all_predcatboost_sub,
                             all_x_sub,all_y_sub,all_time_sub,all_ytrue_sub)
  save(tmp_tmp,file=paste0(path_to,
                                   paste0("holdout_folds_",idx_fold,"_",current_year,
                                   "_POST_basislrn.RData")))
  rm(tmp_tmp)

  #evaluate predictions
  #print(postResample(obs=tmp[[idx_fold]]$all_ytrue_sub,pred=tmp[[idx_fold]]$all_predGAM_))
  
}#end of outer folds

#save(tmp,df,idx_folds, idx_out,file=paste0(path_to,
#                                           paste0("holdout_folds_",which_folds_type,"_",current_year,
#                                                  "_POST_basislrn.RData")
#))

print("yeah! you've reached the end of your script (a.k.a point G)")

end_time=Sys.time()
print(end_time-start_time)