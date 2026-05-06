#!/bin/bash

oarsub -S ./preproc_OMI_MPI.sh | tee out_preproc_OMI_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_preproc_OMI_MPI.tmp`
jobid_preproc_OMI_MPI=$OAR_JOB_ID


oarsub -S ./preproc_IGN1_MPI.sh | tee out_preproc_IGN1_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_preproc_IGN1_MPI.tmp`
jobid_preproc_IGN1_MPI=$OAR_JOB_ID

oarsub -S ./preproc_IGN2_MPI.sh | tee out_preproc_IGN2_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_preproc_IGN2_MPI.tmp`
jobid_preproc_IGN2_MPI=$OAR_JOB_ID

oarsub -S ./preproc_IGN3_MPI.sh | tee out_preproc_IGN3_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_preproc_IGN3_MPI.tmp`
jobid_preproc_IGN3_MPI=$OAR_JOB_ID

oarsub -S ./preproc_IGN4_MPI.sh | tee out_preproc_IGN4_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_preproc_IGN4_MPI.tmp`
jobid_preproc_IGN4_MPI=$OAR_JOB_ID

oarsub -S ./preproc_IGN5_MPI.sh | tee out_preproc_IGN5_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_preproc_IGN5_MPI.tmp`
jobid_preproc_IGN5_MPI=$OAR_JOB_ID

oarsub -S ./preproc_IGN6_MPI.sh | tee out_preproc_IGN6_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_preproc_IGN6_MPI.tmp`
jobid_preproc_IGN6_MPI=$OAR_JOB_ID

oarsub -S ./preproc_IGN7_MPI.sh | tee out_preproc_IGN7_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_preproc_IGN7_MPI.tmp`
jobid_preproc_IGN7_MPI=$OAR_JOB_ID

oarsub -S ./preproc_IGN8_MPI.sh | tee out_preproc_IGN8_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_preproc_IGN8_MPI.tmp`
jobid_preproc_IGN8_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_asn_MPI.sh | tee out_preproc_ERA5_asn_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_asn_MPI.tmp`
jobid_preproc_ERA5_asn_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_blh_00_MPI.sh | tee out_preproc_ERA5_blh_00_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_blh_00_MPI.tmp`
jobid_preproc_ERA5_blh_00_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_blh_12_MPI.sh | tee out_preproc_ERA5_blh_12_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_blh_12_MPI.tmp`
jobid_preproc_ERA5_blh_12_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_d2m_MPI.sh | tee out_preproc_ERA5_d2m_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_d2m_MPI.tmp`
jobid_preproc_ERA5_d2m_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_e_MPI.sh | tee out_preproc_ERA5_e_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_e_MPI.tmp`
jobid_preproc_ERA5_e_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_sp_MPI.sh | tee out_preproc_ERA5_sp_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_sp_MPI.tmp`
jobid_preproc_ERA5_sp_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_ssr_MPI.sh | tee out_preproc_ERA5_ssr_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_ssr_MPI.tmp`
jobid_preproc_ERA5_ssr_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_t2m_mean_MPI.sh | tee out_preproc_ERA5_t2m_mean_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_t2m_mean_MPI.tmp`
jobid_preproc_ERA5_t2m_mean_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_t2m_sd_MPI.sh | tee out_preproc_ERA5_t2m_sd_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_t2m_sd_MPI.tmp`
jobid_preproc_ERA5_t2m_sd_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_tcc_MPI.sh | tee out_preproc_ERA5_tcc_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_tcc_MPI.tmp`
jobid_preproc_ERA5_tcc_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_tp_MPI.sh | tee out_preproc_ERA5_tp_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_tp_MPI.tmp`
jobid_preproc_ERA5_tp_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_u10_MPI.sh | tee out_preproc_ERA5_u10_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_u10_MPI.tmp`
jobid_preproc_ERA5_u10_MPI=$OAR_JOB_ID

oarsub -S ./preproc_ERA5_v10_MPI.sh | tee out_preproc_ERA5_v10_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_ERA5_v10_MPI.tmp`
jobid_preproc_ERA5_v10_MPI=$OAR_JOB_ID

oarsub -S ./preproc_monitor_MPI.sh | tee out_preproc_monitor_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_monitor_MPI.tmp`
jobid_preproc_monitor_MPI=$OAR_JOB_ID

oarsub -S ./preproc_NDVI_MPI.sh | tee out_preproc_NDVI_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_NDVI_MPI.tmp`
jobid_preproc_NDVI_MPI=$OAR_JOB_ID

oarsub -S ./preproc_CAMS_MPI.sh | tee out_preproc_CAMS_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_preproc_CAMS_MPI.tmp`
jobid_preproc_CAMS_MPI=$OAR_JOB_ID

oarsub -a $jobid_preproc_OMI_MPI -a $jobid_preproc_IGN1_MPI -a $jobid_preproc_IGN2_MPI -a $jobid_preproc_IGN3_MPI -a $jobid_preproc_IGN4_MPI -a $jobid_preproc_IGN5_MPI -a $jobid_preproc_IGN6_MPI -a $jobid_preproc_IGN7_MPI -a $jobid_preproc_IGN8_MPI -a $jobid_preproc_ERA5_asn_MPI -a $jobid_preproc_ERA5_blh_00_MPI -a $jobid_preproc_ERA5_blh_12_MPI -a $jobid_preproc_ERA5_d2m_MPI -a $jobid_preproc_ERA5_e_MPI -a $jobid_preproc_ERA5_sp_MPI -a $jobid_preproc_ERA5_ssr_MPI -a $jobid_preproc_ERA5_t2m_mean_MPI -a $jobid_preproc_ERA5_t2m_sd_MPI -a $jobid_preproc_ERA5_tcc_MPI -a $jobid_preproc_ERA5_tp_MPI -a $jobid_preproc_ERA5_u10_MPI -a $jobid_preproc_ERA5_v10_MPI -S ./try_parallel_preproc_MPI.sh | tee out_try_parallel_preproc_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_try_parallel_preproc_MPI.tmp`
jobid_try_parallel_preproc_MPI=$OAR_JOB_ID


oarsub -a $jobid_try_parallel_preproc_MPI -S ./prepare_df_Model1_MPI.sh -a $OAR_JOB_ID | tee out_prepare_df_Model1_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_prepare_df_Model1_MPI.tmp`
jobid_prepare_df_Model1_MPI=$OAR_JOB_ID

oarsub -a $jobid_prepare_df_Model1_MPI -S ./Model1_ranger_not_caret_MPI_PARTI.sh -a $OAR_JOB_ID | tee out_Model1_ranger_not_caret_MPI_PARTI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model1_ranger_not_caret_MPI_PARTI.tmp`
jobid_Model1_ranger_not_caret_MPI_PARTI=$OAR_JOB_ID

oarsub -a $jobid_Model1_ranger_not_caret_MPI_PARTI -S ./Model1_ranger_not_caret_MPI_PARTII.sh -a $OAR_JOB_ID | tee out_Model1_ranger_not_caret_MPI_PARTII.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model1_ranger_not_caret_MPI_PARTII.tmp`
jobid_Model1_ranger_not_caret_MPI_PARTII=$OAR_JOB_ID

oarsub -a $jobid_Model1_ranger_not_caret_MPI_PARTII -S ./Model1_ranger_not_caret_MPI_PARTIII.sh -a $OAR_JOB_ID | tee out_Model1_ranger_not_caret_MPI_PARTIII.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model1_ranger_not_caret_MPI_PARTIII.tmp`
jobid_Model1_ranger_not_caret_MPI_PARTIII=$OAR_JOB_ID


oarsub -a $jobid_Model1_ranger_not_caret_MPI_PARTI -a $jobid_Model1_ranger_not_caret_MPI_PARTII -a $jobid_Model1_ranger_not_caret_MPI_PARTIII -S ./prepare_df_Model2_MPI.sh | tee out_prepare_df_Model2_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_prepare_df_Model2_MPI.tmp`
jobid_prepare_df_Model2_MPI=$OAR_JOB_ID

oarsub -a $jobid_prepare_df_Model2_MPI -S ./FoldsID_final_MPI.sh | tee out_FoldsID_final_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_FoldsID_final_MPI.tmp`
jobid_FoldsID_final_MPI=$OAR_JOB_ID

oarsub -a $jobid_FoldsID_final_MPI -S ./Model2_ranger_caret_MPI.sh | tee out_Model2_ranger_caret_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model2_ranger_caret_MPI.tmp`
jobid_Model2_ranger_caret_MPI=$OAR_JOB_ID

oarsub -a $jobid_FoldsID_final_MPI -S ./Model2_catboost_caret_MPI.sh | tee out_Model2_catboost_caret_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model2_catboost_caret_MPI.tmp`
jobid_Model2_catboost_caret_MPI=$OAR_JOB_ID

oarsub -a $jobid_FoldsID_final_MPI -S ./Model2_xgboost_caret_MPI.sh | tee out_Model2_xgboost_caret_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model2_xgboost_caret_MPI.tmp`
jobid_Model2_xgboost_caret_MPI=$OAR_JOB_ID

oarsub -a $jobid_FoldsID_final_MPI -S ./basis_lrn_pred4ens_ST_MPI.sh | tee out_basis_lrn_pred4ens_ST_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_basis_lrn_pred4ens_ST_MPI.tmp`
jobid_basis_lrn_pred4ens_ST_MPI=$OAR_JOB_ID

oarsub -a $jobid_basis_lrn_pred4ens_ST_MPI -a $jobid_Model2_xgboost_caret_MPI -S ./Model3_ensemble_MPI.sh | tee out_Model3_ensemble_MPI.tmp
eval `egrep -o "OAR_JOB_ID=.*" out_Model3_ensemble_MPI.tmp`
jobid_Model3_ensemble_MPI=$OAR_JOB_ID
