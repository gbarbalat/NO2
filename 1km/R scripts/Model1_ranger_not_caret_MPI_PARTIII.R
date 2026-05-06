library(MLmetrics)
library(caret)
library(dplyr)
library(ranger)
library(stars)
library(lubridate)

source("header_MPI.R")


load(paste0("df_forMPI_",current_year,".RData"))#train and testData
load(paste0("test_ranger1_",current_year,".RData"))#predicted data all_predict_ranger
load(paste0("Model1_ranger_",current_year,".RData"))#hyper_param_ranger
path_to="/bettik/barbalag/"

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

#test set
(rangerMetrics=calculateMMetrics(y_true=testData$omi,
                                 y_hat=matrix(all_predict_ranger,ncol=1)))

##########
#spatial and temporal Metricx
##########
mod.all=data.frame(grid_id=testData$spacevar,
		   omi_no2=testData$omi,
		   pred.no2.cv=matrix(all_predict_ranger,ncol=1)
)
# Spatial
spatial_all <- mod.all %>%
  group_by(grid_id) %>%
  dplyr::summarize(
    bar_omi = mean(omi_no2),
    bar_pred = mean(pred.no2.cv))

m1.fit.all.s    <- lm(bar_omi ~ bar_pred, data=spatial_all)
(r2.spatial      <- summary(m1.fit.all.s)$r.squared)
(rmse.spatial    <- ModelMetrics::rmse(modelObject = m1.fit.all.s))
(spatial.inter   <- summary(m1.fit.all.s)$coef[1,1])
(spatial.slope   <- summary(m1.fit.all.s)$coef[2,1])

# Temporal
temporal_all    <- left_join(mod.all,spatial_all)
del_no2         <- temporal_all$omi_no2-temporal_all$bar_omi
del_pred        <- temporal_all$pred.no2.cv-temporal_all$bar_pred
mod_temporal    <- lm(del_no2 ~ del_pred)
(r2.temporal     <- summary(mod_temporal)$r.squared)
(rmse.temporal   <- ModelMetrics::rmse(modelObject = mod_temporal))
(temporal.inter  <- summary(mod_temporal)$coef[1,1])
(temporal.slope  <- summary(mod_temporal)$coef[2,1])

Importance=hyper_params_ranger$variable.importance
save(rangerMetrics,Importance,
     r2.spatial, rmse.spatial, spatial.inter, spatial.slope,
     r2.temporal, rmse.temporal, temporal.inter, temporal.slope,
     file=paste0("all_metrics_Model1Ranger_",current_year,".RData")
)

print("you've reached point E")

################################################
#predict whole dataset with RF set of hyperparameters!
################################################

file_to_predict=paste0("updated_DMraster_France_var",2,"_",current_year,".RData")#CAMS
load(file=paste0(path_to,file_to_predict))
updated_DMdf= updated_DMraster %>%
				as.data.frame() %>%
				na.omit() %>%
				rename(X=x, Y=y) %>%
				mutate(time_day = time %% 7,
				       time_month = month(as.Date(time, origin = paste0(current_year-1,"-12-31")))
				      )
library(parallel)
nc <- detectCores () # mc
crows <- splitIndices ( nrow ( updated_DMdf ) , nc ) # mc

rfp <- function(x) as.vector(predict (hyper_params_ranger, updated_DMdf[x , ])$predictions) # mc
#cpred <- mclapply ( crows , rfp , nc.cores = nc ) # mc
cpred <- lapply ( crows , rfp ) # mc

predict_omi<- do.call (c, cpred ) # mc
data4_Model2=cbind(predictions=predict_omi, updated_DMdf %>% select(-cams)) %>%
			st_as_stars(dims=c("X","Y","time"))

#append to updated_DM_df
save(data4_Model2,file=paste0("data4_Model2_",current_year,".RData"))
print("yeah! you've reached point G")
