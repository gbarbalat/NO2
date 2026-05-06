#!/bin/bash

#OAR -n Model1_ranger_not_caret_MPI_PARTII
#OAR -l /nodes=1,walltime=20:00:00
#OAR --stdout Model1_ranger_not_caret_MPI_PARTII.out
#OAR --stderr Model1_ranger_not_caret_MPI_PARTII.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript Model1_ranger_not_caret_MPI_PARTII.R