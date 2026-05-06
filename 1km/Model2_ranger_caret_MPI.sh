#!/bin/bash

#OAR -n Model2_ranger_caret1_MPI
#OAR -l /nodes=1,walltime=10:00:00
#OAR --stdout Model2_ranger_caret1_MPI.out
#OAR --stderr Model2_ranger_caret1_MPI.err
#OAR --project edenpelagie

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript Model2_ranger_caret1_MPI.R