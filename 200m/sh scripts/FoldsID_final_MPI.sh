#!/bin/bash

#OAR -n FoldsID_final_MPI
#OAR -l /nodes=1,walltime=10:00:00
#OAR --stdout FoldsID_final_MPI.out
#OAR --stderr FoldsID_final_MPI.err
#OAR --project edenpelagie

cd /bettik/barbalag/200m_header/
source /applis/environments/conda.sh
conda activate renv
Rscript FoldsID_final_MPI.R