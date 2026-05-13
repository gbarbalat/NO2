#!/bin/bash

#OAR -n get_compute_replace_200m
#OAR -l /nodes=1,walltime=48:00:00
#OAR --stdout get_compute_replace_200m.out
#OAR --stderr get_compute_replace_200m.err
#OAR --project edenpelagie

cd /bettik/barbalag/FINAL PREDS/
source /applis/environments/conda.sh
conda activate renv
Rscript get_compute_replace_200m.R