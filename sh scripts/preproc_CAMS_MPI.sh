#!/bin/bash

#OAR -n preproc_CAMS_MPI
#OAR -l /nodes=1,walltime=5:00:00
#OAR --stdout preproc_CAMS_MPI.out
#OAR --stderr preproc_CAMS_MPI.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_CAMS_MPI.R