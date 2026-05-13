#!/bin/bash

#OAR -n concat_weights
#OAR -l /nodes=1,walltime=20:00:00
#OAR --stdout concat_weights.out
#OAR --stderr concat_weights.err
#OAR --project epimed

cd /bettik/barbalag/output_for_plots/
source /applis/environments/conda.sh
conda activate renv
Rscript concat_weights.R