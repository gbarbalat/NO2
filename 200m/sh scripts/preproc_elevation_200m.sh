#!/bin/bash

#OAR -n preproc_elevation_200m
#OAR -l /nodes=1,walltime=30:00:00
#OAR --stdout preproc_elevation_200m.out
#OAR --stderr preproc_elevation_200m.err
#OAR --project epimed

cd /bettik/barbalag/200m_header/
source /applis/environments/conda.sh
conda activate renv
Rscript preproc_elevation_200m.R