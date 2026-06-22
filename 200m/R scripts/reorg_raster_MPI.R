rm(list=ls())

library(stars)
library(dplyr)
library(fst)

load_monitors=0
source("header_200m.R")

#load them all
files_to_predict <- dir(pattern="*_200.RData")
	for (i_file in 1:length(files_to_predict)) {#
		load(file=paste0(files_to_predict[i_file]))
		print(i_file)
		df_=list()

		for (i_day in 1:length(r_)) {
		print(i_day)
		df_[[i_day]]=as.data.frame(r_[[i_day]]) %>% na.omit()
		}
		rm(r_)

		updated_DMdf= do.call(rbind,df_)
		rm(df_)

		#save as fst
		#write.csv(updated_DMdf,file=paste0(files_to_predict[i_file],".csv"))
		write_fst(updated_DMdf, paste0(files_to_predict[i_file], ".fst"))
		rm(updated_DMdf)		    


 	}
