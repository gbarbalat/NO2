
First, run jobs that you would run once for a period of time eg   
preproc_INERIS_emissions  
preproc_pop  
preproc_CLC  
modify hdr in each script, check where the data should be  


ALL_SCRIPTS_MPI.sh defines the arborescence of jobs on the computation grid (gricad).  
It's called MPI, but it has nothing to do with MPI ...  

preproc scripts preprocess raw data  
try_parallel_preproc finish the preprocessing and concatenates  

prepara_df_Model1 and 2 prepare dataframes before running Model 1 and 2  

FoldsID prepare folds  for Model2  
basis_lrn_pred4ens_ST_MPI prepares folds for Model3  


concat_pred_ens concatenates ens predictions for the year   
modify hdr in the script and check where the data should be  
