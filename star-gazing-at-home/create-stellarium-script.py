#!/usr/bin/python

import pandas as pd

def main():
    start_date = input('Start date [2024-02-20]: ') or '2024-02-20'
    start_time = input('Start time [19:21]: ') or '19:21'

    end_date = input('End date [2024-02-21]: ') or '2024-02-21'
    end_time = input('End time [7:16]: ') or '7:16'

    lat = input('Latitude [1.2837587]: ') or '1.2837587'
    lnt = input('Longitude [103.8401528]: ') or '103.8401528'
    
    elevation = input('Elevation [9.2]: ') or '9.2'
    azimuth = input('Azimuth [90]: ') or '90'

    for ds in pd.date_range(
        start=pd.Timestamp(f"{start_date}T{start_time}"), 
        end=pd.Timestamp(f"{end_date}T{end_time}"), 
        freq="10min"
    ):
        print(ds)

if __name__ == "__main__":
    main()