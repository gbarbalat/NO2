#!/bin/bash

#OAR -n Model1_ranger_not_caret_MPI_PARTIII
#OAR -l /nodes=1,walltime=10:00:00
#OAR --stdout Model1_ranger_not_caret_MPI_PARTIII.out
#OAR --stderr Model1_ranger_not_caret_MPI_PARTIII.err
#OAR --project epimed

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript Model1_ranger_not_caret_MPI_PARTIII.R