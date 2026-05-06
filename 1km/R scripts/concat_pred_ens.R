rm(list=ls())
library(dplyr)
library(data.table)
MPI=TRUE
source("header_MPI.R")
all_predict_ens1_l=list()

if (MPI==TRUE) {

load(paste0("/bettik/barbalag/all_predict_ens1_month1_",current_year,".RData")); all_predict_ens1_l[[1]]=all_predict_ens1;print("p1 is loaded")
load(paste0("/bettik/barbalag/all_predict_ens1_month2_",current_year,".RData")); all_predict_ens1_l[[2]]=all_predict_ens1;print("p2 is loaded")
load(paste0("/bettik/barbalag/all_predict_ens1_month3_",current_year,".RData")); all_predict_ens1_l[[3]]=all_predict_ens1;print("p3 is loaded")
print("part1 is loaded!")


load(paste0("/bettik/barbalag/all_predict_ens1_month4_",current_year,".RData")); all_predict_ens1_l[[4]]=all_predict_ens1;print("p4 is loaded")
load(paste0("/bettik/barbalag/all_predict_ens1_month5_",current_year,".RData")); all_predict_ens1_l[[5]]=all_predict_ens1;print("p5 is loaded")
load(paste0("/bettik/barbalag/all_predict_ens1_month6_",current_year,".RData")); all_predict_ens1_l[[6]]=all_predict_ens1;print("p6 is loaded")
print("part2 is loaded!")

load(paste0("/bettik/barbalag/all_predict_ens1_month7_",current_year,".RData")); all_predict_ens1_l[[7]]=all_predict_ens1;print("p7 is loaded")
load(paste0("/bettik/barbalag/all_predict_ens1_month8_",current_year,".RData")); all_predict_ens1_l[[8]]=all_predict_ens1;print("p8 is loaded")
load(paste0("/bettik/barbalag/all_predict_ens1_month9_",current_year,".RData")); all_predict_ens1_l[[9]]=all_predict_ens1;print("p9 is loaded")
print("part3 is loaded!")

load(paste0("/bettik/barbalag/all_predict_ens1_month10_",current_year,".RData")); all_predict_ens1_l[[10]]=all_predict_ens1;print("p10 is loaded")
load(paste0("/bettik/barbalag/all_predict_ens1_month11_",current_year,".RData")); all_predict_ens1_l[[11]]=all_predict_ens1;print("p11 is loaded")
load(paste0("/bettik/barbalag/all_predict_ens1_month12_",current_year,".RData")); all_predict_ens1_l[[12]]=all_predict_ens1;print("p12 is loaded")
print("part4 is loaded!")

all_predict_ens1=rbindlist(all_predict_ens1_l);

print("you've finished with loadings!")


save(all_predict_ens1,file=paste0("/bettik/barbalag/all_predict_ens1_",current_year,".RData"))
}

