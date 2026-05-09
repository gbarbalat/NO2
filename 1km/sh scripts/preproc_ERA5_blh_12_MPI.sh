#!/bin/bash

#OAR -n preproc_ERA5_blh_12_MPI
#OAR -l /nodes=1,walltime=5:00:00
#OAR --stdout preproc_ERA5_blh_12_MPI.out
#OAR --stderr preproc_ERA5_blh_12_MPI.err
#OAR --project edenpelagie

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_ERA5_blh_12_MPI.R