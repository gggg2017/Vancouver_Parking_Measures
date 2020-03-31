library(ggmap)

library(leaflet)
library(dplyr)
leaflet()%>%addTiles()
leaflet()%>%addTiles()%>%addCircleMarkers(data=Vancouver_Parking_Meters,lat=~lat,lng=~lng,radius=~1)

latitude = Vancouver_Parking_Meters$lat
longitude = Vancouver_Parking_Meters$lng
latlng = data.frame(longitude,latitude)

# Loop through the addresses to get the latitude and longitude of each address and add it to the
# origAddress data frame in new columns lat and lon
for(i in 1:length(latitude))
{
  result[i] <- revgeocode(as.numeric(latlng[i,]))
}

# Write a CSV file containing origAddress to the working directory
write.csv(result, "D:/Github/vancouver_parking/address.csv", row.names=FALSE)
