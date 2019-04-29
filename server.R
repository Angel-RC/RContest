source("src/librerias.R")
source("src/funciones.R")
load("data/mapa.RData")
load("data_tidy/datos.RData")
shinyServer(function(input, output, session) { 

  filter_data <- reactive({
    if(input$dates[1] > input$dates[2])
    shinyalert("Oops!", "Erroneus date range.", type = "error")
    
    data_filtered <- datos %>% 
      filter( if(!is.null(input$year)) year %in% input$year else TRUE) %>% 
      filter( if(!is.null(input$month)) month %in% input$month else TRUE) %>% 
      filter( if(!is.null(input$type)) type %in% input$type else TRUE) %>% 
      filter( if(!is.null(input$calification)) calification %in% input$calification else TRUE) %>% 
      filter( if(!is.null(input$points)) points %in% input$points else TRUE) %>% 
      filter( if(!is.na(input$dates)) between(fecha, input$dates[1], input$dates[2]) else TRUE) 
  })
  
  data_to_map <- reactive({
    
     ifelse(input$separar == "Nothing", cruce <- c("latitude", "longitude"), 
                                        cruce <- c("latitude", "longitude", tolower(input$separar)))
     
     data.point <- filter_data() %>% filter(!is.na(latitude) & !is.na(longitude)) %>% 
       group_by_at(cruce) %>% 
       summarise(n = n()) %>% 
       filter(if(!is.na(input$top)) n>=input$top else TRUE)
       
       
       data_filtered <- filter_data() %>% left_join(data.point, by = cruce) %>% 
         filter(n>=input$top)
  })
  
  final_map <- reactive({
 
  new.map(map     = mapa,
          data    = data_to_map(),
          facet   = tolower(input$separar), 
          points  = input$map_type %in% c("Both", "Points"), 
          heatmap = input$map_type %in% c("Heat map", "Both"),
          top     = input$top) 
  })


output$mapa <- renderPlot({final_map()})

observeEvent(input$tabset1, {
  if(input$tabset1 == "Map"){
    mensaje = "You can see a map showing the exact locations where drivers have been fined (only for records including the location)
With the left menu, you can filter the data and change options of the map (heat map, points, compare by year, etc.)."
    }else {
    mensaje = "Two graphs are displayed. The first one represents how the fines are distributed according to the selected categories. The second one depicts a time series corresponding to the complete set of fines or to a subset of fines according to the selected categories (you just need to click in the first graph in the category that you are interested in). 
With the left menu, you can filter the data and change the time series."}
  
  shinyalert("Explanation", mensaje, type = "info")
})

output$sunburst <- renderSunburst({
  
  validate(
    need(!is.null(input$capas), "select levels to create the plot.")
  )

  capas <- input$capas %>% tolower()
  data <- filter_data() %>% 
    group_by_at(capas) %>% 
    summarise(n = n()) %>%
    unite("secuencia", capas, sep = "-")

  custom.message = "function (d) {
  root = d;
while (root.parent) {
root = root.parent
}
p = (100*d.value/root.value).toPrecision(3);
msg = p+' %<br/>'+d.value+' of '+root.value;
return msg;
}"

sb2 <- sunburst(
  data,
  width = "100%",
  height = "100vh",
  explanation = custom.message)

add_shiny(sb2)
})

 output$dygraph <- renderDygraph({  
   
   validate(
     need(is.null(input$month), "If the month filter is activated, the time series cannot be generated.")
   )
   
   data_serie <- filter_data() %>% 
     {if(length(input$sunburst_click) >=1 & !is.null(input$capas)) filter_at(.,vars(tolower(input$capas[1])), all_vars(. == input$sunburst_click[1])) else .} %>% 
     {if(length(input$sunburst_click) > 1 & !is.null(input$capas)) filter_at(.,vars(tolower(input$capas[2])), all_vars(. == input$sunburst_click[2])) else .} %>% 
     {if(length(input$sunburst_click) > 2 & !is.null(input$capas)) filter_at(.,vars(tolower(input$capas[3])), all_vars(. == input$sunburst_click[3])) else .} %>% 
     group_by(year, month) %>%
     summarise(n ={if(input$serie != "Nº Cases") sum(fee - disccount) else n()})
   
   categorias <- if(!is.null(input$capas)) paste(input$sunburst_click, collapse = " - ") else NULL
   
   title <-if(length(input$sunburst_click)>0 & !is.null(input$capas)){
     if(input$serie == "Nº Cases") "Number of fines per month corresponding to: " else "Euros collected in fines per month corresponding to: "
   }else{ 
     if(input$serie == "Nº Cases") "Number of fines per month" else "Euros collected in fines per month"}
   
   if(nrow(data_serie)>0){
   data_serie %>% 
     pull(n) %>% 
     ts(start = c(data_serie$year[1], as.numeric(data_serie$month[1])), frequency = 12) %>% 
     dygraph(main = paste0(title, categorias)) %>% 
     dyRangeSelector(height = 20, strokeColor = "") %>%
     dyBarChart()
   }
  }) 
 
 
})
