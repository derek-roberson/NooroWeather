
|  Document  | Draft                                                                                 |
| :--------: | ------------------------------------------------------------------------------------- |
| Figma Link | https://www.figma.com/design/0zySCKWbyeRO805ifaz1lr/Weather-App-Test-Task?node-id=0-1 |
| Start Date | 1/28/2025                                                                             |
#  🎯 **Objective**

Build a weather app that demonstrates your skills in Swift, SwiftUI, and clean architecture. The app should allow users to search for a city, display its weather on the home screen, and persist the selected city across launches. Follow the Figma designs closely and integrate data from [WeatherAPI](WeatherAPI.com).
# 🔭 Scope

### Home Screen:

- Displays weather for a single saved city, including:
	- City name
	- Temperature.
	- Weather condition (with corresponding icon from the API).
	- Humidity (%).
	- UV index.
	- "Feels like" temperature.
- If no city is saved, prompt the user to search.
- Search bar for querying new cities.

###  Search Behavior:

- Show a search result card for the queried city.
- Tapping the result updates the Home Screen with the city’s weather and persists the selection.

###  Local Storage:

- Use UserDefaults (or equivalent) to persist the selected city.
- Reload the city’s weather on app launch.

### API Integration

- Use WeatherAPI.com to fetch weather data:
	- API Documentation: [WeatherAPI Documentation](https://www.weatherapi.com/docs/).
	- Free tier includes current weather data with:
		- Temperature.
		- Weather condition (including an icon URL).
		- Humidity (%).
		- UV index.
		- Feels like temperature.

#  🤔 Assumptions/Context

There is no requirement to display both temperature units so Fahrenheit was chosen.

# ✅ Possible Approaches

#### Search Behavior:

1. Trigger search on submit
	-  Simpler
	- Single API Call
1. Search while typing <mark style="background: #BBFABBA6;">(***Winning Option***)</mark>
	- Requires multiple API calls
		- Search/Autocomplete then Current
		- In order to be efficient, the Current Weather API calls should happen in parallel if there are multiple cities


Search/AutoComplete Response

| Field   | Data Type | Description                                                  |
| ------- | --------- | ------------------------------------------------------------ |
| id      | string    | Local time when the real time data was updated.              |
| ==name==    | ==string==    | ==Local time when the real time data was updated in unix time.== |
| region  | string    | Temperature in celsius                                       |
| country | string    | Temperature in fahrenheit                                    |
| lat     | decimal   | Feels like temperature in celsius                            |
| long    | decimal   | Feels like temperature in fahrenheit                         |
| url     | string    |                                                              |
Current Weather Response

| Field              | Data Type   | Description                                                          |
| ------------------ | ----------- | -------------------------------------------------------------------- |
| last_updated       | string      | Local time when the real time data was updated.                      |
| last_updated_epoch | int         | Local time when the real time data was updated in unix time.         |
| temp_c             | decimal     | Temperature in celsius                                               |
| ==temp_f==         | ==decimal== | ==Temperature in fahrenheit==                                        |
| feelslike_c        | decimal     | Feels like temperature in celsius                                    |
| ==feelslike_f==    | ==decimal== | ==Feels like temperature in fahrenheit==                             |
| windchill_c        | decimal     | Windchill temperature in celcius                                     |
| windchill_f        | decimal     | Windchill temperature in fahrenheit                                  |
| heatindex_c        | decimal     | Heat index in celcius                                                |
| heatindex_f        | decimal     | Heat index in fahrenheit                                             |
| dewpoint_c         | decimal     | Dew point in celcius                                                 |
| dewpoint_f         | decimal     | Dew point in fahrenheit                                              |
| condition:text     | string      | Weather condition text                                               |
| ==condition:icon== | ==string==  | ==Weather icon url==                                                 |
| condition:code     | int         | Weather condition unique code.                                       |
| wind_mph           | decimal     | Wind speed in miles per hour                                         |
| wind_kph           | decimal     | Wind speed in kilometer per hour                                     |
| wind_degree        | int         | Wind direction in degrees                                            |
| wind_dir           | string      | Wind direction as 16 point compass. e.g.: NSW                        |
| pressure_mb        | decimal     | Pressure in millibars                                                |
| pressure_in        | decimal     | Pressure in inches                                                   |
| precip_mm          | decimal     | Precipitation amount in millimeters                                  |
| precip_in          | decimal     | Precipitation amount in inches                                       |
| ==humidity==       | ==int==     | ==Humidity as percentage==                                           |
| cloud              | int         | Cloud cover as percentage                                            |
| is_day             | int         | 1 = Yes 0 = No  <br>Whether to show day condition icon or night icon |
| ==uv==             | ==decimal== | ==UV Index==                                                         |
| gust_mph           | decimal     | Wind gust in miles per hour                                          |
| gust_kph           | decimal     | Wind gust in kilometer per hour                                      |

# 🚫 Out of Scope

- Full scope of unit testing is out of scope. A single one was added to show the testing capabilities of the code base. It should be straightforward to add to the suite.
- Caching support for images
- More elegant error handling

