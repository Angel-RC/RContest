load("data/datos.RData")  

datos <- dd %>% 
  as_tibble() %>% 
  select(-hour) %>% 
  mutate(fecha     = ymd(paste(year, month, day)),
         type      = ifelse(!(type %in% c("Cimadevilla", "Foto Rojo", "ORA", "Velocidad" )), "Tráfico", type),
         latitude  = as.numeric(sub(",", ".", latitude, fixed = TRUE)), 
         longitude = as.numeric(sub(",", ".", longitude, fixed = TRUE)))


save(datos, file = "data_tidy/datos.RData")
