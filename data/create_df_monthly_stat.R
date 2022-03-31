#load libraries 
library(tidyverse)
library(dplyr)
library(lubridate)

#load extended DB
df <- read_csv('data/db_wind_accepted.csv')
names(df_wind)

#df <- df_wind %>%
 # filter(date_AE > "2019-12-31") %>%
  #select(cols)

df_month <- df %>% 
  mutate(date_AE = as_date(date_AE, format = '%d-%m-%y')) %>%
  mutate(year_month = floor_date(date_AE, 'month')) %>%
  select('date_AE', 'year_month', 'Pmax_parc', 'nr_machine', 'unit_capacity') #%>% # wrong calc: data already aggregated so nr_machines WRONG
  #filter(year_month >= '2019-12-31')

#df_month
write_csv(df_month, 'data/db_wind_month.csv')