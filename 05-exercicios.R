## ----eval=TRUE, echo=FALSE, message=FALSE, warning=FALSE-----------------------------------------------------------------------------
library(tidyverse)
library(gapminder)
library(readxl)

glimpse(gapminder)


## ----eval=TRUE, echo=FALSE, message=FALSE, warning=FALSE-----------------------------------------------------------------------------
continents <- read_excel("input/continents.xlsx")

continents


## ----eval=TRUE, echo=FALSE-----------------------------------------------------------------------------------------------------------
gap_cont <- left_join(gapminder, continents) 

gap_cont


## ----eval=TRUE, echo=FALSE-----------------------------------------------------------------------------------------------------------
gap_cont %>%
  filter(continent == "Oceania")


## ----eval=TRUE, echo=FALSE-----------------------------------------------------------------------------------------------------------
gap_cont %>% 
  filter(continent == "Asia") %>% 
  ggplot(aes(x = year, y = country, fill = lifeExp)) +
    geom_tile()


## ----eval=TRUE, echo=FALSE-----------------------------------------------------------------------------------------------------------
gapminder %>%
  mutate(GDP = gdpPercap * pop) %>%  
  group_by(continent) %>%  
  summarize(cont_gdp = sum(GDP), rpc = mean(gdpPercap)) %>%  
    left_join(continents) %>%  
    mutate(per_cap = cont_gdp / population) %>%  
    ggplot(aes(x = area_km2, y = per_cap)) +
    geom_point() +  
    geom_text(aes(label = continent), nudge_y = 5e3)  

