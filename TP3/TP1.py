import os
import requests
from fastapi import FastAPI, Request
import uvicorn

app = FastAPI()

@app.get("/")
async def get_weather(request: Request):
    api_key = os.getenv("API_KEY", "")
    lat = request.query_params.get('lat')
    lon = request.query_params.get('lon')
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={api_key}"
    weather = requests.get(url).json()
    info_globale = weather["weather"][0]["description"]
    ville = weather["name"]
    temperature = weather["main"]["temp"] - 273.15
    return {"ville": ville, "info_globale": info_globale, "temperature": temperature}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8081)

"""
import os
import requests

def getweather(lat, lon, api_key):
    url = f'https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={api_key}'

    response = requests.get(url)
    data = response.json()

    weather_description = data['weather'][0]['description']
    temperature = round(data['main']['temp'] - 273.15, 2)
    humidity = data['main']['humidity']
    wind_speed = data['wind']['speed']

    print(f"The weather in this location is {weather_description}, the temperature is {temperature}°C, the humidity is {humidity}%, and the wind speed is {wind_speed} m/s.")

# On récupère les variables d'environnement
lat = os.environ['LAT']
lon = os.environ['LONG']
api_key = os.environ['API_KEY']

# On appelle la fonction getweather() avec les variables d'environnement
getweather(lat, lon, api_key)

"""