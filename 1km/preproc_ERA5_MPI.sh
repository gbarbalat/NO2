#!/bin/bash

#OAR -n preproc_ERA5
#OAR -l /nodes=1,walltime=10:00:00
#OAR --stdout preproc_ERA5.out
#OAR --stderr preproc_ERA5.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_ERA5.R