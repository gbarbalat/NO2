# NO2  

## Paper  
A multi-resolution ensemble model of three decision-tree-based algorithms to predict daily NO2 concentration in France 2005–2022 by Barbalat et al.  

## Scripts and Processes  
To obtain predictions of NO2 concentrations (in micrograms per m3) for the years 2000 to 2022.
Each year is composed of two .fst files. Each file contains daily predictions of NO2 concentrations over Metropolitan France (does not include Corsica) for each year.
Spatial resolution is of 1 km x 1 km ('*_1km.fst'), and 200 m x 200 m for large urban areas ('*_200m.fst'). The general method is explained in details in Barbalat et al., Environmental Research, 2024.
Briefly, predictions were obtained following 3 modeling stages  
- stage 1 fits a Random Forest model to predict missing OMI satellite data   
- stage 2 fits an ensemble of 3 basis learners (Random Forest, Categorical Boosting, Extreme Gradient Boosting) to predict 1 km NO2 concentrations   
- stage 3 also fits an ensemble of 3 basis learners (Random Forest, Categorical Boosting, Extreme Gradient Boosting) to predict residuals of the 1km ensemble model associated with a 200m grid.  

### Where to download data: see How to access data.csv  
- IGN
- OMI
- CAMS
- ERA5
- NDVI
- DMSP
- CLC (6 years)
- Population (5 years)
- Emission (INERIS : 2004-2007-2012)
- Elevation (once)
- NO2 at Monitoring stations

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
- Make folds for Model2: with FoldsID_final.R
- Run ML models: Model2_ranger_caret, Model2_catboost_caret, Model2_xgboost_caret  
- Make folds for Model3: basis_lrn_pred4ens_ST
- ensemble those predictions: Model3_ensemble_MPI.R

### 200 m model (gricad)  
dir=/bettik/barbalag/200m_header/  
Change header.R  
uses elevation, CLC, IGN, NDVI, monitors, beware NDVI data should be in /data/$year  
Run ALL_SCRIPTS_200_MPI.sh  
Put output in ./200m_header/$year  
Put 1 km ensemble predictions in /bettik/barbalag/output4plot/  

### Final predictions  
Run get_compute_replace for each year  
Produces final predictions as .fst files  
Each '*_1km.fst' file is a dataframe of 4 columns and 591,869 x nDays rows. nDays=365 (366 for leap years)  
4 columns: x, y, predictions, time  
-The coordinate reference system (x and y) is Lambert-93 (EPSG 2154, also called RGF93 / Lambert-93), which is the official projection for Metropolitan France.  
-Predictions are the actual values of NO2 concentrations predicted by our ensemble geospatial model (see Barbalat et al, 2024, Environmental Research)  
Where predicted concentrations were negative (no bounds were specified in the modeling stages), they were reset to 0.  
-time indicate the day of the year (1 ... 365 or 366 for leap years). 1 indicates the first day of the year (1st of Jan); 365 (366 for leap years) indicates the last day of the year (31st of Dec)  The first 591,869 rows cover the first day of the year (time==1), going on with the second day (time==2), till the last day of the year (time==365 or 366 for leap years)  

In Barbalat et al. 2024, Env. Res., we obtained a 200m resolution grid covering large urban areas by selecting the 118 French towns with a population larger than 50,000 inhabitants as per the 2020 census (Insee, 2023) (obtained from https://www.observatoire-des-territoires.gouv.fr/outils/cartographie-interactive/). The location of each area was obtained from https://www.data.gouv.fr/fr/datasets/decoupage-administratif-communal-francais-issu-d-openstreetmap/, a government database using data reconstructed from OpenStreetMap. This dataset was subsequently merged with our 1km grid, and downscaled to a finer 200m grid.  
To obtain the residuals, we started by associating each 200m grid cell with 1km NO2 predictions obtained from stage 2 by interpolating the 1km predictions to the 200m grid centroids. 
Next, we calculated the residuals for all 200m grid cell-days with a monitoring station.

For these files however, the grid is somewhat different than that used by Hough et al., 2020. In this study, the authors estimated temperature in French urban areas at a 200m resolution with the following grid: "Starting from a 200 m grid in the ETRS89-LAEA Europe (EPSG:3035) equal-area projection, we select all cells in continental France containing “Urban fabric” or “Industrial or commercial units” in the 2012 CLC inventory. We associate each cell with the corresponding INSEE gridded population and select cells with 50 or more inhabitants as well as the eight surrounding cells (i.e. including diagonal neighbors). We define urban areas as four-wise contiguous (i.e. excluding diagonal neighbors) groups of cells and sum the population of all cells in each urban area. Finally, we eliminate urban areas with population < 50,000. This leaves 103 large urban areas ranging from greater Paris (9.4 million inhabitants) to Armentières (50,260 inhabitants)."

To have a single grid for both NO2 and temperature data, we used the grid employed by Hough et al. (2020) and re-launched our 200m model. 

Each '*_200m.fst' file is a dataframe of 4 columns and nDays rows. nDays=365 (366 for leap years)  
4 columns: x, y, predictions, time  
-The coordinate reference system (x and y) is Lambert-93 (EPSG 2154, also called RGF93 / Lambert-93), which is the official projection for Metropolitan France.  
-predictions are the actual values of NO2 concentrations predicted by our ensemble geospatial model (see Barbalat et al, 2024, Environmental Research)  
Where predicted concentrations were negative (no bounds were specified in the modeling stages), they were reset to 0.  
-time indicate the day of the year (1 ... 365 or 366 for leap years). 1 indicates the first day of the year (1st of Jan); 365 (366 for leap years) indicates the last day of the year (31st of Dec)  The first 246,332 rows cover the first day of the year (time==1), going on with the second day (time==2), till the last day of the year (time==365 or 366 for leap years)  

## Specificities of the 2000-2004 modeling stages  
Models ran for years 2000-2004 did not include predictions of missing OMI data (stage 1). This is because there was no OMI data in 2004 and before (OMI started from Oct 2004). For years 2000, 2001 and 2002, stage 2 models were run without CAMS data as CAMS data started to be produced in 2003. We obtained very similar CV predictive performances for stage 2 whether or not we included stage 1 and CAMS data as stage 2 predictors. Therefore, we can be reasonably confident that not including stage 1 and CAMS data as predictors for stage 2 will not significantly decrease the predictive performance of our 1 km model.

