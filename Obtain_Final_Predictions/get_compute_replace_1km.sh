#!/bin/bash

#OAR -n get_compute_replace_1km
#OAR -l /nodes=1,walltime=30:00:00
#OAR --stdout get_compute_replace_1km.out
#OAR --stderr get_compute_replace_1km.err
#OAR --project edenpelagie

cd /bettik/barbalag/FINAL PREDS/
source /applis/environments/conda.sh
conda activate renv
Rscript get_compute_replace_1km.R