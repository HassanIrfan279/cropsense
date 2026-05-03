from fastapi import APIRouter, HTTPException
import httpx
from datetime import datetime

router = APIRouter()

DISTRICT_COORDS = {
    'faisalabad':  (31.45, 73.13),
    'lahore':      (31.55, 74.34),
    'multan':      (30.20, 71.47),
    'rawalpindi':  (33.57, 73.02),
    'gujranwala':  (32.19, 74.19),
    'sialkot':     (32.49, 74.53),
    'bahawalpur':  (29.40, 71.68),
    'sargodha':    (32.08, 72.67),
    'sahiwal':     (30.67, 73.11),
    'okara':       (30.81, 73.45),
    'karachi':     (24.86, 67.00),
    'hyderabad':   (25.40, 68.36),
    'sukkur':      (27.71, 68.86),
    'larkana':     (27.56, 68.22),
    'nawabshah':   (26.24, 68.41),
    'peshawar':    (34.02, 71.52),
    'mardan':      (34.20, 72.05),
    'swat':        (35.22, 72.43),
    'quetta':      (30.18, 66.98),
    'turbat':      (26.00, 63.04),
    # fallback coords for districts not in the list
    'sheikhupura': (31.71, 73.98),
    'jhang':       (31.27, 72.32),
    'vehari':      (30.04, 72.35),
    'kasur':       (31.12, 74.45),
    'mirpur-khas': (25.53, 69.01),
    'tharparkar':  (25.18, 70.26),
    'kashmore':    (28.44, 69.57),
    'abbottabad':  (34.15, 73.22),
    'charsadda':   (34.15, 71.73),
    'dera-ismail-khan': (31.83, 70.90),
    'khuzdar':     (27.81, 66.61),
    'hub':         (25.00, 67.11),
    'loralai':     (30.37, 68.59),
    'zhob':        (31.34, 69.45),
    'naseerabad':  (29.00, 67.92),
    'sibi':        (29.54, 67.88),
}


def _clamp(val, lo, hi):
    return max(lo, min(hi, val))


@router.get('/weather/{district}')
async def get_weather(district: str):
    district_lower = district.lower()
    coords = DISTRICT_COORDS.get(district_lower)
    if coords is None:
        raise HTTPException(status_code=404, detail=f'District "{district}" not found')

    lat, lng = coords
    url = (
        f'https://api.open-meteo.com/v1/forecast'
        f'?latitude={lat}&longitude={lng}'
        f'&current=temperature_2m,precipitation,relative_humidity_2m,wind_speed_10m'
        f'&daily=precipitation_sum,temperature_2m_max,temperature_2m_min,et0_fao_evapotranspiration'
        f'&timezone=Asia%2FKarachi&past_days=30'
    )

    async with httpx.AsyncClient(timeout=15.0) as client:
        resp = await client.get(url)
        resp.raise_for_status()
        data = resp.json()

    current = data.get('current', {})
    daily   = data.get('daily', {})

    temperature  = current.get('temperature_2m', 0.0)
    humidity     = current.get('relative_humidity_2m', 0.0)
    wind_speed   = current.get('wind_speed_10m', 0.0)

    precip_list  = daily.get('precipitation_sum', [])
    # sum last 30 days of precipitation
    rainfall_30day = sum(v for v in precip_list if v is not None)

    temp_max_list = daily.get('temperature_2m_max', [])
    temp_min_list = daily.get('temperature_2m_min', [])
    et0_list      = daily.get('et0_fao_evapotranspiration', [])

    # forecast = next 7 days (index 30 onwards since past_days=30)
    future_max = [v for v in temp_max_list[30:] if v is not None]
    future_min = [v for v in temp_min_list[30:] if v is not None]
    future_et0 = [v for v in et0_list[30:]      if v is not None]

    temp_max_forecast = round(sum(future_max) / len(future_max), 1) if future_max else round(temperature + 2, 1)
    temp_min_forecast = round(sum(future_min) / len(future_min), 1) if future_min else round(temperature - 8, 1)
    evapotranspiration = round(sum(future_et0) / len(future_et0), 2) if future_et0 else 0.0

    ndvi_raw = (rainfall_30day / 300.0) * 0.8 + 0.2
    ndvi_estimate = round(_clamp(ndvi_raw, 0.1, 0.9), 3)

    return {
        'district':           district_lower,
        'temperature':        round(temperature, 1),
        'rainfall_30day':     round(rainfall_30day, 1),
        'humidity':           round(humidity, 1),
        'wind_speed':         round(wind_speed, 1),
        'temp_max_forecast':  temp_max_forecast,
        'temp_min_forecast':  temp_min_forecast,
        'evapotranspiration': evapotranspiration,
        'heat_stress_alert':  temperature > 40.0,
        'drought_alert':      rainfall_30day < 50.0,
        'ndvi_estimate':      ndvi_estimate,
        'data_source':        'Open-Meteo',
        'fetched_at':         datetime.utcnow().isoformat() + 'Z',
    }
