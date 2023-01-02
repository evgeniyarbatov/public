import json
import boto3
import urllib3
import os

from datetime import datetime
from statistics import mean
from datetime import datetime

def callAPI(url):
    http = urllib3.PoolManager()
    raw_response = http.request('GET', url)
    return json.loads(raw_response.data.decode('utf-8'))

def getTemperature():
    readings = []
    response = callAPI(os.environ['TEMPERATURE_URL'])
    for item in response['items']:
        for reading in item['readings']:
            readings.append(reading['value'])
    return mean(readings)

def getRainfall():
    station_ids = ['S78', 'S214', 'S108']
    readings = []
    response = callAPI(os.environ['RAINFALL_URL'])
    for item in response['items']:
        for reading in item['readings']:
            if reading['station_id'] in station_ids:
                readings.append(reading['value'])
    return mean(readings)

def get2HForecast():
    areas = ['City', 'Kallang', 'Geylang', 'Marine Parade']
    forecacts = []
    response = callAPI(os.environ['TWO_HOUR_FORECAST_URL'])
    for item in response['items']:
        for reading in item['forecasts']:
            if reading['area'] in areas:
                forecacts.append(reading['forecast'])
    return ', '.join(list(set(forecacts)))

def get24HForecast():
    regions = ['east', 'central', 'south']
    forecasts = {}
    response = callAPI(os.environ['TWENTY_FOUR_HOUR_FORECAST_URL'])
    for item in response['items']:
        for period in item['periods']:
            start_time_datetime = datetime.strptime(
                period['time']['start'], 
                '%Y-%m-%dT%H:%M:%S+08:00'
            )
            ts = start_time_datetime.strftime("%H")
    
            forecasts[ts] = []
            for region in regions:
                forecast = period['regions'][region]
                if not forecast in forecasts[ts]:
                    forecasts[ts].append(forecast)
    
            forecasts[ts] = ', '.join(forecasts[ts])
            
            
    forecasts = [v + ' @ ' + k for k,v in forecasts.items()]
    return ', '.join(forecasts)

def getTimeNow():
    return datetime.now().strftime("%d-%m-%Y %H:%M:%S")
    
def updatePage(
    temperature,
    rainfall,
    two_hour_forecast,
    twenty_four_hour_forecast,
    time_now,
):
    with open('index.html', 'r') as file:
        html_template = file.read()
    
    page_html = html_template\
        .replace('TEMPERATURE', "{:.2f}".format(temperature))\
        .replace('RAINFALL', "{:.2f}".format(rainfall))\
        .replace('2H_FORECAST', two_hour_forecast)\
        .replace('24H_FORECAST', twenty_four_hour_forecast)\
        .replace('UPDATED_AT', time_now)
    
    s3 = boto3.resource('s3')
    object = s3.Bucket(os.environ['BUCKET_NAME']).Object(os.environ['BUCKET_FILE'])
    object.put(
        Body=page_html,
        ContentType="text/html",
    )

def lambda_handler(event, context):
    updatePage(
        getTemperature(),
        getRainfall(),
        get2HForecast(),
        get24HForecast(),
        getTimeNow(),
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Done')
    }
