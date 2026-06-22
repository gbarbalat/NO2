#!/bin/bash

#OAR -n preproc_predictions1_5_200m
#OAR -l /nodes=1,walltime=30:00:00
#OAR --stdout preproc_predictions1_5_200m.out
#OAR --stderr preproc_predictions1_5_200m.err
#OAR --project epimed

cd /bettik/barbalag/200m_header/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_predictions1_5_200m.R