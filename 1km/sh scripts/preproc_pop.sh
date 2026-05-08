#!/bin/bash

#OAR -n preproc_pop
#OAR -l /nodes=1,walltime=2:00:00
#OAR --stdout preproc_pop.out
#OAR --stderr preproc_pop.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_pop.R