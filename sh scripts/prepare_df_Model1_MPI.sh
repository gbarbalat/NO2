#!/bin/bash

#OAR -n prepare_df_Model1_MPI
#OAR -l /nodes=1,walltime=10:00:00
#OAR --stdout prepare_df_Model1_MPI.out
#OAR --stderr prepare_df_Model1_MPI.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript prepare_df_Model1_MPI.R