library(leaflet)
library(dplyr)
library(shiny)

Vancouver_Parking_Meters_with_address <- readxl::read_xlsx('Vancouver_Parking_Meters_with_address.xlsx',sheet=1)
Vancouver_OffStreet_Parking <- readxl::read_xlsx('Vancouver_OffStreet_Parking.xlsx',sheet=1)

# set up dataframe for onstreet
meter_ID = Vancouver_Parking_Meters_with_address$METERID
latitude = Vancouver_Parking_Meters_with_address$lat
longitude = Vancouver_Parking_Meters_with_address$lng
meter_type = Vancouver_Parking_Meters_with_address$METERHEAD
meter_spot = Vancouver_Parking_Meters_with_address$Spots
group_block = substr(meter_ID,1,4)
meter_side = as.character(as.numeric(substr(meter_ID,6,6))%%2)
group = paste(group_block,meter_side)

meter_popup_info=paste(
  "MeterID: ",meter_ID,"<br/>",
  "Meter Type: ", meter_type,"<br/>",
  Vancouver_Parking_Meters_with_address$HouseNumber," ",Vancouver_Parking_Meters_with_address$StreetName)

meter_df = data.frame(meter_ID, meter_spot, latitude, longitude, group_block, group, meter_popup_info)
colnames(meter_df) = c("meterID", "Spots", "latitude", "longitude", "group_block","group_blockperside", "meter popup info")

# set up dataframe for offstreet parking lots
lot_lat = Vancouver_OffStreet_Parking$lat
lot_lng = Vancouver_OffStreet_Parking$lng
offstreet = data.frame(lot_lat,lot_lng)

# set up datafram for block info
agg1 = aggregate(meter_df[,c("latitude", "longitude")],
                by = list(meter_df$group_block),
                FUN = mean)
agg2 = aggregate(meter_df[,c("Spots")],
                 by = list(meter_df$group_block),
                 FUN = sum)
block_ID = agg1$Group.1
block_lng = agg1$longitude
block_lat = agg1$latitude
block_spot = agg2$x

# compute 4 measures
occupancy<- as.numeric(block_lng)%%100
occupancy<- round(occupancy,digits=2)
road_safety<- as.numeric(block_lng)%%100
road_safety<- round(road_safety,digits=2)
VKT<- as.numeric(block_lat)%%100
VKT<- round(VKT,digits=2)
airpollution<- as.numeric(block_lat)%%100
airpollution<- round(airpollution,digits=2)

block_df = data.frame(block_ID, block_lat, block_lng, block_spot, occupancy, road_safety, VKT, airpollution)
colnames(block_df) = c("BlockID", "latitude", "longitude", "block spot", "occupancy", "road safety", "VKT", "air pollution")

block_popup_info=paste(
  "Number of parking spots in this block: ", block_spot, "<br/>",
  "Occupancy Rate: ",occupancy,"<br/>",
  "Road Safety: ",road_safety,"<br/>",
  "Vehicle Kilometers Traveled: ",VKT,"<br/>",
  "Air Pollution: ",airpollution,"<br/>")

myMap = leaflet() %>%
  setView(lng = -123.12333, lat = 49.2835, zoom = 14) %>%
  addTiles()%>%
  
  # mark a circle in each parking meter
   addCircles(data = meter_df,
             lng = ~ longitude, lat = ~ latitude,
             radius = ~1,
             color = "#5583a6",
             popup =~meter_popup_info) %>%
  
  
  # mark a circle in each offstreet parking lot
  addCircles(data = offstreet,
             lng = ~ lot_lng, lat = ~ lot_lat,
             radius = ~10,
             color = "#FF0000")  %>%

  # mark a circle in each parking block
  addCircles(data = block_df,
           lng = ~ block_lng, lat = ~ block_lat,
           radius = ~10,
           color = "#0000FF",
           popup =~block_popup_info)

# cluster the parking meters block by block
# for(group in levels(meter_df$group)){
#  myMap = addPolylines(myMap, 
#                       lng= ~ longitude,
#                       lat= ~ latitude,
#                       data = meter_df[meter_df$group == group,], 
#                       weight = 6)
#}

ui = fluidPage(
  leafletOutput(outputId='myMap')
)

server = function(input,output){
  output$myMap = renderLeaflet({
    myMap
  })
  
}

shinyApp(ui,server)

