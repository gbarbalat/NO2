#!/bin/bash

#OAR -n concat_weights_200
#OAR -l /nodes=1,walltime=20:00:00
#OAR --stdout concat_weights_200.out
#OAR --stderr concat_weights_200.err
#OAR --project epimed

cd /bettik/barbalag/output_for_plots_200/
source /applis/environments/conda.sh
conda activate renv
Rscript concat_weights_200.R