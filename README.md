# NO2  

## Paper  
A multi-resolution ensemble model of three decision-tree-based algorithms to predict daily NO2 concentration in France 2005–2022 by Barbalat et al.  

## Scripts and Processes  

### Pre-processing
- IGN data (roads, road_nodes, train_stations, rail) with script read_IGN_data; produces RData files which you will transfer onto the grid
- Download the following data: IGN, OMI, CAMS, all ERA5, monitor data, NDVI, DMSP (all yearly data), CLC (6 years), Pop (5 years), Emission (INERIS : 2004-2007-2012), Elevation (once)
- Transfer to gricad (UGA grid to make computations)

### 1 km model (gricad)  
dir=/bettik/barbalag/  
use so-called "MPI" scripts
Change header.R
Make sure everything there in "data" folder  
Run ALL_SCRIPTS_....sh  
Keep 1 km ensemble predictions for the year in main directory  

- Fit each predictor to the 1km MODIS grid (1km x 1km x 1 day)  
- Reprojection, down or upsample, crop  
- Finish up preproc & concatenate all predictors: try_parallel_preproc.R  
- To prepare dataframe for (Model 1): prepare_df_Model1.R  
- Run model1 which predicts missing OMI data: Model1_ranger_not_caret.R (ranger without caret HP tuning)
- Model2 and 3 predict daily NO2 concentrations using NO2 at monitoring stations as true outcomes  
- Extract all data at monitoring stations: Prepare_df_Model2.R
- Make folds with FoldsID_final.R
- Run ML models: Model2_ranger_caret, Model2_catboost_caret, Model2_xgboost_caret  
- basis_lrn_pred4ens_ST
- ensemble those predictions: Model3_ensemble_MPI.R

### 200 m model (gricad)  
dir=/bettik/barbalag/200m_header/  
uses elevation, CLC, IGN, NDVI, monitors, beware NDVI data should be in /data/$year  
Run ALL_SCRIPTS_200_MPI.sh  
Put output in ./200m_header/$year  
Put 1 km ensemble predictions in /bettik/barbalag/output4plot/  

### Final predictions  
Run get_compute_replace for each year  
