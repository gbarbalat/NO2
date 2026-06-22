#!/bin/bash

#OAR -n preproc_pop_200m
#OAR -l /nodes=1,core=32,walltime=30:00:00
#OAR --stdout preproc_pop_200m.out
#OAR --stderr preproc_pop_200m.err
#OAR --project epimed

cd /bettik/barbalag/200m_header/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_pop_200m.R