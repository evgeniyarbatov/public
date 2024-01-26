import json
import csv
import os
import re

from bs4 import BeautifulSoup
from urllib.request import urlopen
from kaggle.api.kaggle_api_extended import KaggleApi

output_dir = '/tmp/data/'

def lambda_handler(event, context):
    api = KaggleApi()
    api.authenticate()
    
    if not os.path.exists(output_dir):
        os.mkdir(output_dir)

    os.system('cp dataset-metadata.json ' + output_dir)  

    outfile = open(
        output_dir + "data.csv", 
        "w",
    )
    writer = csv.writer(outfile)

    writer.writerow([
        'Rank',
        'Time',
        'Name',
        'Country',
        'Date of Birth',
        'Place',
        'City',
        'Date',
        'Gender',
        'Event',
    ])
    
    with open('config.json', 'r') as f:
        config = json.load(f)
    
    for config in config['sources']:
        with urlopen(config['url']) as response:
            content = response.read()
    
        soup = BeautifulSoup(content, 'html.parser')

        contents = soup.find_all('pre')
        for content in contents:
            for line in content.text.splitlines():
                entry = line.strip()
                if entry:
                    row = re.split(r" {2,}", entry, maxsplit=8)
                    row[1] = re.sub("[^0-9:]", "", row[1])
                    if len(row) == 8:
                        row += config['gender'] + config['event']
                        writer.writerow(row)
                        
        api.dataset_create_version(
            output_dir,
            "Automated update"
        )
