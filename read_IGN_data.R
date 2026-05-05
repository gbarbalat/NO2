rm(list=ls())

library(sf)
library(dplyr)
year <- "2023"
year_input <- "2024"

here_data_IGN <- paste0("C:/Users/Guillaume/Desktop/PhD_epidemio/Exposure Modeling/PartI_Ian&mock/data_mock/ROUTE500/current/",year_input,"/")
dir(here_data_IGN,pattern = ".shp")

#"NOEUD_ROUTIER.shp" tout sauf "Changement d'attribut" &  "Noeud représentatif d'une commune" 
# 
# [1] "Carrefour simple"                 "Changement d'attribut"             "Noeud représentatif d'une commune"
# [4] "Echangeur complet"                 "Rond-point"                        "Echangeur partiel"                
# [7] "Noeud de communication restreinte" "Carrefour aménagé"                 "Embarcadère"                      
# [10] "Barrière de douane"               

#HERE CHANGE x 3
file <- "NOEUD_ROUTIER.shp"
add_on <- "_";#default
type <- "road_nodes"#rail train_stations road_nodes roads

#"NOEUD_ROUTIER.shp" tout sauf "Changement d'attribut" 
#"TRONCON_ROUTE.shp" by classe_admin de etat=revetu 
#"TRONCON_VOIE_FERREE.shp" !=electrifié - use both
# "NOEUD_FERRE.shp" = gare de fret et de voyageurs
# NOEUD_COMMUNE=NOPE COMMUNICATION_RESTREINTE=NOPE AERODROME=NOPE

tmp <-  st_read(paste0(here_data_IGN,file))
head(tmp)

####################
plot(tmp$geometry)

#NATURE, ENERGIE
unique(tmp$NATURE)#e.g. TGV ...
unique(tmp$VOCATION) #"Liaison régionale"  "Liaison principale" "Liaison locale"     "Type autoroutier"   "Bretelle"     
unique(tmp$CLASS_ADM)
unique(tmp$NB_CHAUSSE)#1 or 2
unique(tmp$NB_VOIES)# --- quantité
unique(tmp$ETAT)#only revêtu
unique(tmp$ACCES)#nope
unique(tmp$RES_VERT)#nope
unique(tmp$CLASS_ADM)#nationale, dpt, sans objet, autoroute --- vitesse
###################


######################################
######################################

###
#NOEUD ROUTIER
###
file <- "NOEUD_ROUTIER.shp"
add_on <- "_";#default
type <- "road_nodes"#rail train_stations road_nodes roads
tmp  <-  st_read(paste0(here_data_IGN,file))
#tmp2 <- dplyr::filter(tmp,TYPE!="changement d'attribut") 
tmp2 <- dplyr::filter(tmp,NATURE!="Changement d'attribut") # %>% filter(NATURE!="Intersection du réseau ferré")
x <- tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))

###
#TRONCON_ROUTE
###
file <- "TRONCON_ROUTE.shp"
add_on <- "_";#default
type <- "roads"#rail train_stations road_nodes roads
tmp <- st_read(paste0(here_data_IGN,file))
colnames(tmp); unique (tmp$ETAT)
tmp <- dplyr::filter(tmp,ETAT=="Revêtu")#Revêtu Rev?tu Rev\xeatu
tmp <- dplyr::filter(tmp,grepl("Rev",ETAT)); 
tmp <- dplyr::filter(tmp,ETAT_GEN=="route revêtue")#Revêtu Rev?tu

unique (tmp$CLASS_ADM)
tmp2 <- dplyr::filter(tmp,CLASS_ADM=="Sans objet");add_on="_T_";x=tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
tmp2 <- dplyr::filter(tmp,CLASS_ADM=="Autoroute");add_on="_A_";x=tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
tmp2 <- dplyr::filter(tmp,CLASS_ADM=="Nationale");add_on="_N_";x=tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
tmp2 <- dplyr::filter(tmp,CLASS_ADM=="Départementale");add_on="_D_";x=tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
tmp2 <- dplyr::filter(tmp,grepl("partementale",CLASS_ADM));add_on="_D_";x=tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))

#Départementale D?partementale
tmp2 <- dplyr::filter(tmp,CLAS_ADM=="sans objet");add_on="_T_";x=tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
tmp2 <- dplyr::filter(tmp,CLAS_ADM=="autoroute");add_on="_A_";x=tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
tmp2 <- dplyr::filter(tmp,CLAS_ADM=="route nationale");add_on="_N_";x=tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
tmp2 <- dplyr::filter(tmp,CLAS_ADM=="route départementale");add_on="_D_";x=tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))

###
#TRONCON_VOIE_FERREE (rail)
###
file <- "TRONCON_VOIE_FERREE.shp"
add_on <- "_";#default
type <- "rail"#rail train_stations road_nodes roads
tmp <- st_read(paste0(here_data_IGN,file))
colnames(tmp)
unique (tmp$CLASSEMENT)
unique (tmp$ENERGIE)
tmp2 <- dplyr::filter(tmp,CLASSEMENT=="En service") %>% 
  #filter(ENERGIE=="Non ?lectrifi?e")#Non électrifié
  filter(ENERGIE=="Electrifié");x <- tmp2$geometry;add_on <- "_E_";save(x,file=paste0(type,add_on,year,".RData"))
tmp2 <- dplyr::filter(tmp,CLASSEMENT=="En service") %>% 
  #filter(ENERGIE=="Non ?lectrifi?e")#Non électrifié
  filter(ENERGIE!="Electrifié");x <- tmp2$geometry;add_on <- "_NE_";save(x,file=paste0(type,add_on,year,".RData"))

tmp2 <- dplyr::filter(tmp,CLASSE=="exploité") %>% 
  filter(ENERGIE=="électrique ou en cours d'électrification");x <- tmp2$geometry;add_on <- "_E_";save(x,file=paste0(type,add_on,year,".RData"))
tmp2=dplyr::filter(tmp,CLASSE=="exploité") %>% 
  filter(ENERGIE!="électrique ou en cours d'électrification");x <- tmp2$geometry;add_on <- "_NE_";save(x,file=paste0(type,add_on,year,".RData"))

tmp2 <- dplyr::filter(tmp,CLASSEMENT=="En service") %>% 
  filter(grepl("Elec",ENERGIE));x <- tmp2$geometry;add_on <- "_E_";save(x,file=paste0(type,add_on,year,".RData"))
tmp2 <- dplyr::filter(tmp,CLASSEMENT=="En service") %>% 
  dplyr::filter(!grepl("Elec",ENERGIE));x <- tmp2$geometry;add_on <- "_NE_";save(x,file=paste0(type,add_on,year,".RData"))

###
#NOEUD_FERRE
###
file <- "NOEUD_FERRE.shp"
add_on <- "_";#default
type <- "train_stations"#rail train_stations road_nodes roads
tmp <- st_read(paste0(here_data_IGN,file))
colnames(tmp)
unique(tmp$NATURE)
tmp2 <- dplyr::filter(tmp,grepl("Gare",NATURE));add_on <- "_";x <- tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
# tmp2 <- dplyr::filter(tmp,NATURE=="Gare de fret");add_on <- "_F_";x <- tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
# tmp2 <- dplyr::filter(tmp,NATURE=="Gare de voyageurs");add_on <- "_T_";x <- tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
# tmp2 <- dplyr::filter(tmp,NATURE=="Gare de voyageurs et de fret");add_on <- "_TF_";x <- tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))
tmp2=dplyr::filter(tmp,grepl("gare",TYPE));add_on <- "_";x <- tmp2$geometry;save(x,file=paste0(type,add_on,year,".RData"))

plot(x)










#################################################################"
########## NOT FOR USE AT THIS POINT
#################################################################"

plot(tmp2_d$geometry)
x=tmp2$geometry

save(x,file=paste0(type,add_on,year,".RData"))
#transform 
st_rasterize(tmp2$geometry)
##########