#!/bin/bash

#OAR -n prepare_df_Model2_MPI
#OAR -l /nodes=1,walltime=12:00:00
#OAR --stdout prepare_df_Model2_MPI.out
#OAR --stderr prepare_df_Model2_MPI.err
#OAR --project edenpelagie

cd /bettik/barbalag/200m_header/
source /applis/environments/conda.sh
conda activate renv
Rscript prepare_df_Model2_MPI.R