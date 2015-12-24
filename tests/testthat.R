library(testthat)
library(RSocrata)
library(profvis)

test_check("RSocrata")

asd <- read.socrata("https://chronicdata.cdc.gov/resource/h5w7-v8i7.json")
asdasf <- read.socrata("https://sandbox.demo.socrata.com/resource/6cpn-3h7n.json")
ssefw <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json")
asdjsadf <-  read.socrata(url = "https://data.cityofchicago.org/resource/6zsd-86xi.json")

profvis({
  g <- read.socrata(url = "https://data.cityofchicago.org/Health-Human-Services/Food-Inspections/4ijn-s7e5")
  print(g)
})

profvis({
  b <- read.socrata(url = "https://data.cityofchicago.org/Buildings/Building-Permits/ydr8-5enu")
  print(b)
})

profvis({
  m <- getMetadata(url = "https://data.cityofchicago.org/resource/6zsd-86xi.json")
  print(m)
})
