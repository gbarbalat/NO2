#!/bin/bash

#OAR -n preproc_IGN4_MPI
#OAR -l /nodes=1,walltime=40:00:00
#OAR --stdout preproc_IGN4_MPI.out
#OAR --stderr preproc_IGN4_MPI.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_IGN4_MPI.R