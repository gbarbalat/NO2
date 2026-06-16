#!/bin/bash

oarsub -S ./preproc_NDVI1_200m.sh | tee out_preproc_NDVI1_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_NDVI1_200m.tmp`
jobid_preproc_NDVI1_200m=$OAR_JOB_ID

oarsub -a $jobid_preproc_NDVI1_200m -S ./preproc_NDVI2_200m.sh | tee out_preproc_NDVI2_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_NDVI2_200m.tmp`
jobid_preproc_NDVI2_200m=$OAR_JOB_ID


oarsub -S ./preproc_elevation_200m.sh | tee out_preproc_elevation_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_elevation_200m.tmp`
jobid_preproc_elevation_200m=$OAR_JOB_ID


oarsub -S ./concat_pred_ens.sh | tee out_concat_pred_ens.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_concat_pred_ens.tmp`
jobid_concat_pred_ens=$OAR_JOB_ID

oarsub -a $jobid_concat_pred_ens -S ./preproc_predictions1_1_200m.sh | tee out_preproc_predictions1_1_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_predictions1_1_200m.tmp`
jobid_preproc_predictions1_1_200m=$OAR_JOB_ID
 
oarsub -a $jobid_concat_pred_ens -S ./preproc_predictions1_2_200m.sh | tee out_preproc_predictions1_2_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_predictions1_2_200m.tmp`
jobid_preproc_predictions1_2_200m=$OAR_JOB_ID

oarsub -a $jobid_concat_pred_ens -S ./preproc_predictions1_3_200m.sh | tee out_preproc_predictions1_3_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_predictions1_3_200m.tmp`
jobid_preproc_predictions1_3_200m=$OAR_JOB_ID

oarsub -a $jobid_concat_pred_ens -S ./preproc_predictions1_4_200m.sh | tee out_preproc_predictions1_4_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_predictions1_4_200m.tmp`
jobid_preproc_predictions1_4_200m=$OAR_JOB_ID

oarsub -a $jobid_concat_pred_ens -S ./preproc_predictions1_5_200m.sh | tee out_preproc_predictions1_5_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_predictions1_5_200m.tmp`
jobid_preproc_predictions1_5_200m=$OAR_JOB_ID

oarsub -a $jobid_concat_pred_ens -S ./preproc_predictions1_6_200m.sh | tee out_preproc_predictions1_6_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_predictions1_6_200m.tmp`
jobid_preproc_predictions1_6_200m=$OAR_JOB_ID

oarsub -a $jobid_preproc_predictions1_1_200m -a $jobid_preproc_predictions1_2_200m -a $jobid_preproc_predictions1_3_200m -a $jobid_preproc_predictions1_4_200m -a $jobid_preproc_predictions1_5_200m -a $jobid_preproc_predictions1_6_200m -S ./preproc_predictions2_200m.sh | tee out_preproc_predictions2_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_predictions2_200m.tmp`
jobid_preproc_predictions2_200m=$OAR_JOB_ID


oarsub -S ./preproc_CLC_200m.sh | tee out_preproc_CLC_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_CLC_200m.tmp`
jobid_preproc_CLC_200m=$OAR_JOB_ID


oarsub -S ./preproc_IGN1_200m.sh | tee out_preproc_IGN1_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_IGN1_200m.tmp`
jobid_preproc_IGN1_200m=$OAR_JOB_ID

oarsub -S ./preproc_IGN2_200m.sh | tee out_preproc_IGN2_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_IGN2_200m.tmp`
jobid_preproc_IGN2_200m=$OAR_JOB_ID

oarsub -S ./preproc_IGN3_200m.sh | tee out_preproc_IGN3_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_IGN3_200m.tmp`
jobid_preproc_IGN3_200m=$OAR_JOB_ID

oarsub -S ./preproc_IGN4_200m.sh | tee out_preproc_IGN4_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_IGN4_200m.tmp`
jobid_preproc_IGN4_200m=$OAR_JOB_ID

oarsub -S ./preproc_IGN5_200m.sh | tee out_preproc_IGN5_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_IGN5_200m.tmp`
jobid_preproc_IGN5_200m=$OAR_JOB_ID

oarsub -S ./preproc_IGN6_200m.sh | tee out_preproc_IGN6_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_IGN6_200m.tmp`
jobid_preproc_IGN6_200m=$OAR_JOB_ID

oarsub -S ./preproc_IGN7_200m.sh | tee out_preproc_IGN7_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_IGN7_200m.tmp`
jobid_preproc_IGN7_200m=$OAR_JOB_ID

oarsub -S ./preproc_IGN8_200m.sh | tee out_preproc_IGN8_200m.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_IGN8_200m.tmp`
jobid_preproc_IGN8_200m=$OAR_JOB_ID




oarsub -a $jobid_preproc_elevation_200m -a $jobid_preproc_NDVI2_200m -a $jobid_preproc_predictions2_200m -a $jobid_preproc_CLC_200m -a $jobid_preproc_IGN1_200m -a $jobid_preproc_IGN2_200m -a $jobid_preproc_IGN3_200m -a $jobid_preproc_IGN4_200m -a $jobid_preproc_IGN5_200m -a $jobid_preproc_IGN6_200m -a $jobid_preproc_IGN7_200m -a $jobid_preproc_IGN8_200m -S ./prepare_df_Model2_MPI.sh | tee out_prepare_df_Model2_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_prepare_df_Model2_MPI.tmp`
jobid_prepare_df_Model2_MPI=$OAR_JOB_ID

oarsub -a $jobid_preproc_elevation_200m -a $jobid_preproc_NDVI2_200m -a $jobid_preproc_predictions2_200m -a $jobid_preproc_CLC_200m -a $jobid_preproc_IGN1_200m -a $jobid_preproc_IGN2_200m -a $jobid_preproc_IGN3_200m -a $jobid_preproc_IGN4_200m -a $jobid_preproc_IGN5_200m -a $jobid_preproc_IGN6_200m -a $jobid_preproc_IGN7_200m -a $jobid_preproc_IGN8_200m -S ./reorg_raster_MPI.sh | tee out_reorg_raster_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_reorg_raster_MPI.tmp`
jobid_reorg_raster_MPI=$OAR_JOB_ID



oarsub -a $jobid_prepare_df_Model2_MPI -S ./FoldsID_final_MPI.sh | tee out_FoldsID_final_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_FoldsID_final_MPI.tmp`
jobid_FoldsID_final_MPI=$OAR_JOB_ID

oarsub -a $jobid_FoldsID_final_MPI -S ./basis_lrn_pred4ens_ST_MPI.sh | tee out_basis_lrn_pred4ens_ST_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_basis_lrn_pred4ens_ST_MPI.tmp`
jobid_basis_lrn_pred4ens_ST_MPI=$OAR_JOB_ID



oarsub -a $jobid_FoldsID_final_MPI -a $jobid_reorg_raster_MPI -S ./Model2_ranger_caret_MPI.sh | tee out_Model2_ranger_caret_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model2_ranger_caret_MPI.tmp`
jobid_Model2_ranger_caret_MPI=$OAR_JOB_ID

oarsub -a $jobid_FoldsID_final_MPI -a $jobid_reorg_raster_MPI -S ./Model2_catboost_caret_MPI.sh | tee out_Model2_catboost_caret_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model2_catboost_caret_MPI.tmp`
jobid_Model2_catboost_caret_MPI=$OAR_JOB_ID

oarsub -a $jobid_FoldsID_final_MPI -a $jobid_reorg_raster_MPI -S ./Model2_xgboost_caret_MPI.sh | tee out_Model2_xgboost_caret_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model2_xgboost_caret_MPI.tmp`
jobid_Model2_xgboost_caret_MPI=$OAR_JOB_ID



oarsub -a $jobid_basis_lrn_pred4ens_ST_MPI -a $jobid_Model2_xgboost_caret_MPI -S ./Model3_ensemble_MPI.sh | tee out_Model3_ensemble_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model3_ensemble_MPI.tmp`
jobid_Model3_ensemble_MPI=$OAR_JOB_ID