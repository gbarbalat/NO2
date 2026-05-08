#!/bin/bash

#OAR -n preproc_INERIS_emission
#OAR -l /nodes=1,walltime=5:00:00
#OAR --stdout preproc_INERIS_emission.out
#OAR --stderr preproc_INERIS_emission.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_INERIS_emissions.R