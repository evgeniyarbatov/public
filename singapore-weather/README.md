# Weather Forecast

AWS Lambda to query APIs to fetch temperature and weather forecast. The result is saved as an HTML page and stored in S3 bucket. HTML from S3 is rendered in the browser with [basic website setup](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html).


## APIs used

I am calling these APIs for weather in Singapore

```
https://api.data.gov.sg/v1/environment/air-temperature
https://api.data.gov.sg/v1/environment/rainfall
https://api.data.gov.sg/v1/environment/2-hour-weather-forecast
https://api.data.gov.sg/v1/environment/24-hour-weather-forecast
```

## Demo

![SG Weather Demo](images/sg-weather.jpg?raw=true "SG Weather Demo" | height=300)


## Scheduling Lambda with CloudWatch Events

Run every day at 5am SGT:

```
aws events put-rule \
--name "SGWeatherUpdate" \
--schedule-expression "cron(0 21 * * ? *)"
```

Permission to invoke Lamda from CloudWatch

```
aws lambda add-permission \
--function-name sgWeather \
--statement-id SGWeatherUpdate \
--action 'lambda:InvokeFunction' \
--principal events.amazonaws.com \
--source-arn arn:aws:events:ap-southeast-1:655701728733:rule/SGWeatherUpdate
```

Schedule

```
aws events put-targets --rule SGWeatherUpdate --targets file://targets.json
```
