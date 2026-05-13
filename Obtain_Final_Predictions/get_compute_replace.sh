#!/bin/bash

#OAR -n get_compute_replace
#OAR -t fat
#OAR -l /nodes=1,walltime=20:00:00
#OAR --stdout get_compute_replace.out
#OAR --stderr get_compute_replace.err
#OAR --project edenpelagie

cd /bettik/barbalag/FINAL PREDS/
source /applis/environments/conda.sh
conda activate renv
Rscript get_compute_replace.R $1