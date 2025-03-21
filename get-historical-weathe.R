#included install packages first so we could use the library but only need once
install.packages("httr")

#library misspelled so fixed that by adding an "r"
#both of these packages are used to interact with the API with the httr allowing us to make http requests
#jsonlite is used to process the JSON data returned by the API into a readable format
library(httr)
if (!require(jsonlite)) install.packages("jsonlite")
library(jsonlite)

#tells R where to look for the data aka defines the API base URL
base_url <- "https://archive-api.open-meteo.com/v1/archive"

#adding space for ease of reading between different actions
#setting the parameters for the data request
#fixed the spelling of temperature unit (needed an a)
params <- list(
  latitude = 40.7128,
  longitude = -74.0060,
  start_date = "2014-01-02",
  end_date = "2024-12-31",
  temperature_unit = "fahrenheit",
  hourly = "temperature_2m,precipitation,relative_humidity_2m,dew_point_2m",
  timezone = "America/New_York"
)

#this makes the API request itself
#query was misspelled, needing an e
response <- GET(url = base_url, query = params)

#this checks the status of the request
if (response$status != 200) {
  stop("Failed to retrieve data. Status code: ", response$status)
}
  
#this processes the JSON response
json_data <- content(response, as = "text", encoding = "UTF-8")
weather_data <- fromJSON(json_data, flatten = TRUE)

#checks to see if hourly data is available?
if (!"hourly" %in% names(weather_data)) {
    stop("Unexpected data format: 'hourly' field not found in the API response.")
}

#format was misspelled and needed an "a"
#had to change hourly$temp to hourly$temperature_2m to match the API
#exports hourly data if there
hourly <- weather_data$hourly
df <- data.frame(
  time = as.POSIXct(hourly$time, format = "%Y-%m-%dT%H:%M", tz = "America/New_York"),
  temperature = hourly$temperature_2m,
  precipitation = hourly$precipitation,
  relative_humidity = hourly$relative_humidity_2m,
  dew_point = hourly$dew_point_2m
)

#plotting the weather data
png(filename = "weather_plots.png", width = 800, height = 800)
par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))

#had to change df$temp to df$temperature to match the API 
plot(df$time, df$temperature, type = "l", col = "blue",
     main = "Temperature over Time",
     xlab = "Time", ylab = "Temperature (°F)")

plot(df$time, df$precipitation, type = "l", col = "blue",
     main = "Precipitation over Time",
     xlab = "Time", ylab = "Precipitation")

plot(df$time, df$relative_humidity, type = "l", col = "blue",
     main = "Relative Humidity over Time",
     xlab = "Time", ylab = "Relative Humidity (%)")

plot(df$time, df$dew_point, type = "l", col = "blue",
     main = "Dew Point over Time",
     xlab = "Time", ylab = "Dew Point (°F)")

dev.off()

#save the data
saveRDS(df, file = "historical_weather_data.rds")

cat("Data download, visualization, and saving complete.\n")
