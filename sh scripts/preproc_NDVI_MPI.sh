#!/bin/bash

#OAR -n preproc_NDVI_MPI
#OAR -l /nodes=1,walltime=2:00:00
#OAR --stdout preproc_NDVI_MPI.out
#OAR --stderr preproc_NDVI_MPI.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_NDVI_MPI.R