library(MLmetrics)
library(caret)
library(dplyr)
library(ranger)
library(stars)
library(lubridate)

##############################
#header
##############################
start_time=Sys.time()

source("header_MPI.R")

r_forest=TRUE
folds_type="caret"#caret or CAST
which_outcome="omi"
metric="R2"
nfolds=5#no folds as such but you'll devide the data
proba_partition=0.8
strata_ids=NULL
path_to="/bettik/barbalag/"
file_is=paste0("df_final_",current_year,".RData")#without NA

load(file=paste0(path_to,file_is))

df=df_final %>% mutate(time_day = time %% 7
		      ,time_month = month(as.Date(time, origin = paste0(current_year-1,"-12-31")))
)

##############################



###############################
#create trainining and holdout sets
###############################
#cv or holdout
df$spacevar=paste0(as.character(df$X),"-",as.character(df$Y))

set.seed(123)
##########
#with caret
##########
FoldIndex = createFolds(df$omi, 5, returnTrain = TRUE)
trainDat=df[FoldIndex$Fold1,]
testData=df[-FoldIndex$Fold1,]

save(trainDat,testData,file=paste0("df_forMPI_",current_year,".RData"))
             
end_time=Sys.time()
print(end_time-start_time)