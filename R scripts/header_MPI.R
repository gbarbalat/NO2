header=1;
days_in_total=365
current_year=2007
#check NO2 monitors!!!!!!

#for pop
year_at_stake=2015## 2005-2010-2015-2020, year and next four years
pop_ds_chosen=1500

#for INERIS_emissions
year_emission=2012#2004 2007 2012 

#for CLC
year_CLC="U2018_"#2006(2000) 2012(2006) 2018(2012) 2018(2018)

#for roads
road_ds_chosen=0

DMSP=FALSE #till 2013
VIIRS=TRUE #from 2014 onwards

idx_emissions=99
all_emissions='emission_99_'

#for Models 2 and 3, buffer size and n_breaks depend on the STvariogram
buffer_size=5
buffer_dist=2000
n_breaks=73#try with more n_breaks

