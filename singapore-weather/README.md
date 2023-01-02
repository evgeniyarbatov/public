# Weather Forecast

AWS Lambda to query APIs to fetch temperature and weather forecast.

The result is saved as an HTML page and stored in S3 bucket.

HTML from S3 is rendered in the browser with basic website setup.


## APIs used

I am calling these APIs for weather in Singapore

```
https://api.data.gov.sg/v1/environment/air-temperature
https://api.data.gov.sg/v1/environment/rainfall
https://api.data.gov.sg/v1/environment/2-hour-weather-forecast
https://api.data.gov.sg/v1/environment/24-hour-weather-forecast
```

## Demo

![SG Weather Demo](images/sg-weather.jpg?raw=true "SG Weather Demo")