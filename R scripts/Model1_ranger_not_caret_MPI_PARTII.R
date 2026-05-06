############################################################################
#fit using ranger
############################################################################
source("header_MPI.R")

load(paste0("df_forMPI_",current_year,".RData"))#trainDat and testData
predictors=c('cams','X','Y',"time", "time_day","time_month")

library(ranger)#library(randomForest)
library(dplyr)
library (parallel)
#RNGkind("L'Ecuyer-CMRG") # mc
set.seed( seed = 123)

c.ranger = function(f1,f2){
  f3 = f1
  f3$num.trees = f1$num.trees + f2$num.trees
  f3$prediction.error = c(f1$prediction.error,f2$prediction.error)
  f3$r.squared = c(f1$r.squared,f2$r.squared)
  f3$num.samples = c(f1$num.samples,f2$num.samples)
  f3$replace = c(f1$replace,f2$replace)
  f3$forest$num.trees = f1$forest$num.trees+f2$forest$num.trees
  f3$forest$child.nodeIDs = c(f1$forest$child.nodeIDs,f2$forest$child.nodeIDs)
  f3$forest$split.varIDs = c(f1$forest$split.varIDs,f2$forest$split.varIDs)
  f3$forest$split.values = c(f1$forest$split.values,f2$forest$split.values)
  return(f3)}

 nc <- detectCores () # mc
 ntree <- lapply ( splitIndices (500 , nc ) , length ) # mc
 crows <- splitIndices ( nrow ( testData ) , nc ) # mc

train=dplyr::select(trainDat,-c(spacevar))
# #my.rf=function(x) randomForest(omi ~ ., dplyr::select(trainDat,-c(spacevar)), ntree =x , norm.votes = FALSE)
 my.rf=function(x) ranger(omi ~ ., train , num.trees =x , importance="impurity")
 
 #rf.out <- mclapply ( ntree , my.rf , mc.cores = nc ) # mc
 rf.out <- lapply ( ntree , my.rf ) # mc

save(rf.out,file="rf_out.RData")
 
 hyper_params_ranger=rf.out[[1]]
 for (i in 2:length(rf.out)) {
   hyper_params_ranger=c.ranger(hyper_params_ranger,rf.out[[i]]) 
 }

save(hyper_params_ranger,file=paste0("Model1_ranger_",current_year,".RData"))

############################################################################


################################################
#predict holdout set with RF set of hyperparameters!
################################################
sub_test= dplyr::select(testData,all_of(predictors))
rfp <- function(x) as.vector(predict (hyper_params_ranger, sub_test [x , ])$predictions) # mc
#cpred <- mclapply ( crows , rfp , nc.cores = nc ) # mc
cpred <- lapply ( crows , rfp ) # mc

all_predict_ranger<- do.call (c, cpred ) # mc

save(all_predict_ranger,file=paste0("test_ranger1_",current_year,".RData"))

