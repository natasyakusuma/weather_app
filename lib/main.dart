import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weatherDescription = 'Loading...';
  String _location = '';
  double _temperature = 0.0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _updateWeather();
  }

  Future<void> _updateWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      final response = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String weather = data['weather'][0]['description'];
        String location = data['name'];
        double temperature = data['main']['temp'];
        double latitude = position.latitude;
        double longitude = position.longitude;

        setState(() {
          _weatherDescription = weather;
          _location = location;
          _temperature = temperature.toDouble();
          _latitude = latitude;
          _longitude = longitude;
          _isLoading = false;
        });
      } else {
        setState(() {
          _weatherDescription = 'Failed to load weather data.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _weatherDescription = 'Error fetching weather data.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue,
              Colors.lightBlueAccent,
            ],
          ),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(
                  color: Colors.white,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BoxedIcon(
                      _getWeatherIcon(_weatherDescription),
                      color: Colors.white,
                      size: 70,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '$_temperature°C',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$_weatherDescription',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Location: $_location',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Latitude : $_latitude',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Longitude : $_longitude',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String weatherDescription) {
    switch (weatherDescription.toLowerCase()) {
      case 'clear sky':
        return WeatherIcons.day_sunny;
      case 'few clouds':
        return WeatherIcons.day_cloudy;
      case 'scattered clouds':
      case 'broken clouds':
        return WeatherIcons.cloudy;
      case 'shower rain':
      case 'rain':
        return WeatherIcons.showers;
      case 'thunderstorm':
        return WeatherIcons.thunderstorm;
      case 'snow':
        return WeatherIcons.snow;
      case 'mist':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.day_sunny;
    }
  }
}
