#!/bin/bash

#OAR -n basis_lrn_pred4ens_ST_other_param_MPI
#OAR -l /nodes=1,walltime=15:00:00
#OAR --stdout basis_lrn_pred4ens_ST_other_param_MPI.out
#OAR --stderr basis_lrn_pred4ens_ST_other_param_MPI.err
#OAR --project edenpelagie

cd /bettik/barbalag/200m_header/
source /applis/environments/conda.sh
conda activate renv
Rscript basis_lrn_pred4ens_ST_other_param_MPI.R