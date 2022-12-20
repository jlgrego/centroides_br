#Script para coleta dos centroides de todos os municípios do Brasil

pacotes <- c("rgdal","sf","tidyverse")

if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  instalador <- pacotes[!pacotes %in% installed.packages()]
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}
  sapply(pacotes, require, character = T) 
} else {
  sapply(pacotes, require, character = T) 
}

#Carregando shapefile disponibilizado pelo IBGE em:
#https://www.ibge.gov.br/geociencias/organizacao-do-territorio/malhas-territoriais/15774-malhas.html?=&t=downloads 
#municipio_2021>Brasil>BR>BR_Municipios_2021.zip:
#Salvei as camadas dentro de uma pasta chamada "municipiois_br"

municipios_shp <- readOGR("municipios_br", "BR_Municipios_2021")

#Tranformando o Datum para WGS84 e em objeto sf:

municipios_sf <- spTransform(municipios_shp, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")) %>% 
  sf::st_as_sf()

#Obtendo os centróides dos municípios:

municipios_sf <- municipios_sf %>% mutate(centroide = st_centroid(municipios_sf$geometry))

#Criando colunas "Latitude" e "Longitude" a partir dos centróides:

municipios_sf <- municipios_sf %>% mutate(longitude = unlist(map(centroide,1)),
                                           latitude = unlist(map(centroide,2)))

#Capturando variáveis de interesse:

municipios <- municipios_sf[,c(2,3,7,8)] %>% as.tibble() %>% select(1:4)

#Salvando arquivo com longitude e latitude em xlsx:

write.csv(municipios, "municipios_br.csv")

#Fim