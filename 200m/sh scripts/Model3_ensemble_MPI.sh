#!/bin/bash

#OAR -n Model3_ensemble1_MPI
#OAR -l /nodes=1,walltime=5:00:00
#OAR --stdout Model3_ensemble1_MPI.out
#OAR --stderr Model3_ensemble1_MPI.err
#OAR --project epimed

cd /bettik/barbalag/200m_header/
source /applis/environments/conda.sh
conda activate renv
Rscript Model3_ensemble1_MPI.R