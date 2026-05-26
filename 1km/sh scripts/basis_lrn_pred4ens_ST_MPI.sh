#!/bin/bash

#OAR -n basis_lrn_pred4ens_ST_MPI
#OAR -l /nodes=1,walltime=15:00:00
#OAR --stdout basis_lrn_pred4ens_ST_MPI.out
#OAR --stderr basis_lrn_pred4ens_ST_MPI.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript basis_lrn_pred4ens_ST_MPI.R