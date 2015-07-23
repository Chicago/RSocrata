library(leaflet)
library(geojsonio)


asdsadas <- geojson_read("https://data.cityofchicago.org/resource/6zsd-86xi.geojson", method = "local", parse = FALSE, what = "list")

m <- leaflet() %>%
  addGeoJSON(asdsadas) %>%
  setView(-87.6, 41.8, zoom = 10) %>% addTiles()
m

