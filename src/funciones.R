
show_tabla <- function(datos, fijar = 0) {
  
  res <- DT::datatable(select_if(datos,negate(is.list)), 
                       rownames   = FALSE,
                       extensions = c('ColReorder',
                                      'Buttons',
                                      'FixedColumns',
                                      'FixedHeader',
                                      'Scroller'),
                       
                       options    = list(
                         fixedHeader  = TRUE,
                         dom          = 'Bfrtip',
                         fixedColumns = list(leftColumns = fijar),
                         pageLength   = 300,
                         scrollY      = "500px",
                         scrollX      = TRUE,
                         colReorder   = TRUE,
                         buttons = list('colvis')
                       )
  )
  return(res)
}




new.map <- function(map, data, facet, points = TRUE, heatmap = TRUE, top) {
  
  data <- data %>% 
    filter(!is.na(latitude) & !is.na(longitude))
  
  ifelse(facet == "nothing", cruce <- c("latitude", "longitude"), 
         cruce <- c("latitude", "longitude", tolower(facet)))
  
  data.point <- data %>% 
    group_by_at(cruce) 
  
  result <- ggmap(map) +
    labs(x        = "Longitude", 
         y        = "Latitude",
         title    = "Observed cases with location",
         subtitle = paste0("Cases: ", as.character(nrow(data)))) +
  theme(plot.margin = margin(0, 0, 0, 0),
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle = element_text(size = 13))
  
  if(points){
    result <- result + 
      geom_point(data    = data.point, 
                 mapping = aes(x = longitude, y = latitude, size = n, colour = n),
                 alpha   = 0.6) + 
      scale_colour_gradient(low = "dodgerblue1", high = "black") +
      guides( size = guide_legend(reverse = TRUE, title = "Number of fines"))+
      labs(colour = "Number of fines")
    }
  
  if(heatmap){
    result <- result + 
      stat_density2d(mapping = aes(x = longitude, y = latitude, fill = ..level..),
                     alpha   = 0.25, 
                     size    = 0.2, 
                     bins    = 30, 
                     data    = data,
                     geom    = "polygon")  + 
      scale_fill_gradient(low  = "yellow", 
                          high = "red") 
  
  }
  
  if(facet != "nothing"){
    result <- result +
      facet_grid(as.formula(paste("~", facet)))
    
  }
  return(result)
}


