#!/bin/bash

#OAR -n concat_pred_ens
#OAR -l /nodes=1,walltime=1:00:00
#OAR --stdout concat_pred_ens.out
#OAR --stderr concat_pred_ens.err
#OAR --project epimed

cd /bettik/barbalag/200m_header/
source /applis/environments/conda.sh
conda activate renv
Rscript concat_pred_ens.R