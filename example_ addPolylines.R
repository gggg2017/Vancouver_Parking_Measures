library(shiny)
library(leaflet)

station = c("A", "B", "C", "D", "E", "F")
latitude = c(-1.63, -1.62, -1.62, -1.77, -1.85, -1.85)
longitude = c(34.3, 34.4, 34.7, 34.3, 34.5, 34.7)
big = c(0, 20, 60, 90, 50, 10)
small = c(100, 80, 40, 10, 50, 90)
colour = c("blue", "blue", "red", "red", "black", "black")
group = c("A", "A", "B", "B", "C", "C")

df = cbind.data.frame(station, latitude, longitude, big, small, colour, group)

colnames(df) = c("station", "latitude", "longitude", "big", "small", "colour", "group")



myMap = leaflet() %>%
  setView(lng = 34.4, lat = -1.653, zoom = 8) %>%
  addTiles()%>%
  
  addCircles(data = df,
             lng = ~ longitude, lat = ~ latitude,
             color = ~ colour,
             radius = 2000,
             stroke = TRUE,
             opacity = 5,
             weight = 1,
             fillColor = ~ colour,
             fillOpacity = 1)

for(group in levels(df$group)){
  myMap = addPolylines(myMap, 
                       lng= ~ longitude,
                       lat= ~ latitude,
                       data = df[df$group == group,], 
                       color= ~ colour,
                       weight = 3)
}

myMap

