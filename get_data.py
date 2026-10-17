import cdsapi

c = cdsapi.Client()

# Downloads hourly surface weather for UK/Europe region
c.retrieve(
    'reanalysis-era5-land',
    {
        'variable': [
            '2m_temperature',
            '2m_dewpoint_temperature', # Used to calculate Relative Humidity
            'total_precipitation',
            '10m_u_component_of_wind',
            '10m_v_component_of_wind',
        ],
        'year': '2023',
        'month': ['05', '06', '07', '08'], # Fire season
        'day': [f"{i:02d}" for i in range(1, 32)],
        'time': ['12:00'], # Peak burn time (midday)
        'area': [60.9, -10.5, 49.8, 1.8], # North, West, South, East
        'format': 'netcdf',
    },
    'era5_weather_2023.nc'
)