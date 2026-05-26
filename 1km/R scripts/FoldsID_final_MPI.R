#this function creates folds using only caret groupKfold function
#3 blocking schemes are implemented
#1- one test fold = whole data series from a monitor (5 folds)
#2- one test fold = 1 monitor for a single date (5 folds)
#3- one test fold = 1 monitor for a specific period with left- and right-sided buffers (5 folds)
#buffer is based on temporal and spatial auto-correlation (spatio-temporal variogram)

rm(list=ls())

##############################
#header
##############################
source("header_MPI.R")

start_time=Sys.time()

which_outcome="no2_monitors"
nfolds=10

library(caret)
library(CAST)
library(dplyr)
library(sf)
library(lubridate)

path_to="/bettik/barbalag/"
file_is=paste0("df_final_Model2_",current_year,".RData")
load(file=paste0(path_to,file_is))
df=as.data.frame(df_final_Model2) 

##############################

df$spacevar=paste0(as.character(df$X),"-",as.character(df$Y))
(length(unique(df$spacevar)))
df$spacetimevar=paste0(as.character(df$X),"-",as.character(df$Y),"-",as.character(df$time))
df$time <- yday(df$time); df$period=cut(df$time,breaks=quantile(1:days_in_total,probs=seq(0, 1, length.out = n_breaks+1)),labels=FALSE,include.lowest=TRUE)
df$spaceperiodvar=paste0(as.character(df$X),"-",as.character(df$Y),"-",as.character(df$period))

########################################
#a whole ts in the testing set
########################################
Nseed=123
idx_folds=NULL
k=0
while (length(idx_folds)!=nfolds) {
set.seed(Nseed+k)
idx_folds=caret::groupKFold(df$spacevar, nfolds) 
k=k+1
}


idx_out=list()

for (i in 1:length(idx_folds)) {
print(i) 
idx_out[[i]]= setdiff(1:nrow(df),idx_folds[[i]])
}
save(df,idx_folds,idx_out,file=paste0("holdout_folds_SpBlMo_5F_",current_year,".RData"))


########################################
#block monitor and 1 date
########################################
Nseed=123
idx_folds=NULL
k=0
while (length(idx_folds)!=nfolds) {
set.seed(Nseed+k)
idx_folds=caret::groupKFold(df$spacetimevar, nfolds) 
k=k+1
}


idx_out=list()

for (i in 1:length(idx_folds)) {
print(i) 
idx_out[[i]]= setdiff(1:nrow(df),idx_folds[[i]])
}
save(df,idx_folds,idx_out,file=paste0("holdout_folds_StBlMo_5F_",current_year,".RData"))


########################################
#block monitor with period in test set
########################################
Nseed=123
idx_folds=NULL

k=0
while (length(idx_folds)!=nfolds) {
set.seed(Nseed+k)
idx_folds=caret::groupKFold(df$period, nfolds) 
k=k+1
}

idx_rm_all=NULL

idx_out=list()
for (i in 1:length(idx_folds)) {
idx_out[[i]]= setdiff(1:nrow(df),idx_folds[[i]])
}

for (i in 1:length(idx_folds)) {
print(i) 

idx_rm_all=NULL
idx_out[[i]]= setdiff(1:nrow(df),idx_folds[[i]])

trainDat=df[idx_folds[[i]],] 
testDat=df[idx_out[[i]],] 

		for (j in (1:length(unique(testDat$period)))) {

		period_idx=unique(testDat$period)[j]
	        testDat2=testDat %>% filter(period==period_idx)
		
		#temporal windows for temporal buffer
		time_min=min(testDat2$time)
		time_max=max(testDat2$time)

		testDat2_sf=st_as_sf(testDat2,coords=c("X","Y"))
		trainDat_sf=st_as_sf(trainDat,coords=c("X","Y"))
		k=st_is_within_distance(trainDat_sf, testDat2_sf,dist=buffer_dist, sparse=F)

		idx_rm=which(lengths(k)>0 & (trainDat$time <= time_max +buffer_size & trainDat$time >= time_min-buffer_size))
		idx_rm_all=c(idx_rm_all,idx_rm)
		}

idx_folds[[i]]=idx_folds[[i]][-idx_rm_all]

}
save(df,idx_folds,idx_out,file=paste0("holdout_folds_STBlMo_5F_",current_year,".RData"))

test_here=df[idx_out[[1]],"spacevar"]
test=df[idx_out[[1]],] %>% filter(spacevar %in% test_here) %>% arrange(spacevar) %>% select(spacetimevar,time)
train=df[idx_folds[[1]],] %>% filter(spacevar %in% test_here) %>% arrange(spacevar) %>% select(spacetimevar,time)
print(head(test))
print(head(train,300))

for (i in 1:nfolds) {

print(length(idx_folds[[i]]))
print(length(idx_out[[i]]))

}

end_time=Sys.time()
print(end_time-start_time)
