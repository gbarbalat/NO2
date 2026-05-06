#!/bin/bash

#OAR -n Model2_catboost_caret1_MPI
#OAR -l /nodes=1,walltime=15:00:00
#OAR --stdout Model2_catboost_caret1_MPI.out
#OAR --stderr Model2_catboost_caret1_MPI.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript Model2_catboost_caret1_MPI.R