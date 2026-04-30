# NO2  

## Paper  
A multi-resolution ensemble model of three decision-tree-based algorithms to predict daily NO2 concentration in France 2005–2022 by Barbalat et al.  

## Scripts and Processes  

### Pre-processing
- IGN data
- Download data from
- Transfer to gricad (UGA grid to make computations)

### 1 km model  
Change header.R
Make sure everything there in data folder

I- PREPROCESSING

Download variables and transfer onto grid for further preproc and calc

Preproc IGN on the computer with script read_IGN_data, transfer Rdata onto grid

To fit each predictor with the 1km MODIS grid (1km x 1km x 1 day)
Reprojection, down or upsample, crop

Every few years :
CLC (6 years), Pop (5 years), Emission (INERIS : 2004-2007-2012)

Every year :
Preproc IGN 

Preproc OMI

Preproc CAMS

Preproc all ERA5

Preproc monitor data

Preproc NDVI

To finish up preproc & concatenate all predictors (try_parallel_preproc)
Finish up preproc : Elevation, DMSP
all IGN = roads, road_nodes, train_stations, rail

To prepare dataframe for (Model 1)
prepare_df_Model1

II- PREDICT MISSING OMI (MODEL 1)

Model1_ranger_not_caret (ranger without HP tuning)

Prepare_df_Model2 (extract at monitors)

III- PREDICT MISSING MONITOR DATA (MODELS 2 and 3)

FoldsID_final

Model2_ranger_caret, Model2_catboost_caret, Model2_xgboost_caret

basis_lrn_pred4ens_ST

Model3_ensemble_MPI=$OAR_JOB_ID

### 200 m model  
