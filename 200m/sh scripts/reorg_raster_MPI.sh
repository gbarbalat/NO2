#!/bin/bash

#OAR -n reorg_raster_MPI
#OAR -t fat
#OAR -l /nodes=1,walltime=15:00:00
#OAR --stdout reorg_raster_MPI.out
#OAR --stderr reorg_raster_MPI.err
#OAR --project epimed

cd /bettik/barbalag/200m_header/
source /applis/environments/conda.sh
conda activate renv
Rscript reorg_raster_MPI.R