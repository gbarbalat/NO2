#!/bin/bash

#OAR -n proc_ens_pred
#OAR -l /nodes=1,walltime=20:00:00
#OAR --stdout proc_ens_pred.out
#OAR --stderr proc_ens_pred.err
#OAR --project epimed

cd /bettik/barbalag/output_for_plots/
source /applis/environments/conda.sh
conda activate renv
Rscript proc_ens_pred.R