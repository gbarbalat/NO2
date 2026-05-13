library(data.table)
library(dplyr)

setwd("/bettik/barbalag/output_for_plots")

current_year=2005
start=2005
finish=2022

all_weights_list=list()
idx_year=1;

for (current_year in start:finish) {

load(paste0("w2_allyear_",current_year,".RData"))

all_weights_list[[idx_year]]=rbindlist(w2) %>% 
  group_by(model) %>% 
  summarise(mean=mean(weights),
            sd=sd(weights),
            min=min(weights),
            max=max(weights)) %>% select(-sd) %>%
  tidyr::pivot_wider(names_from = model,
                     values_from = c(mean,min,max)) %>%
  mutate(year=current_year) %>%
  relocate(c("year",
             "mean_catboost","min_catboost","max_catboost",
             "mean_XGB","min_XGB","max_XGB",
             "mean_ranger","min_ranger","max_ranger"))
idx_year=idx_year+1

print(current_year)
}

all_weights_df=rbindlist(all_weights_list)
save(all_weights_df,file="all_weights_df.RData")