#!/bin/bash

#OAR -n try_parallel_preproc_MPI
#OAR -l /nodes=1,walltime=10:00:00
#OAR --stdout try_parallel_preproc_MPI.out
#OAR --stderr try_parallel_preproc_MPI.err
#OAR --project edenpelagie

cd /bettik/barbalag/
source /applis/environments/conda.sh
conda activate renv
Rscript try_parallel_preproc_MPI.R