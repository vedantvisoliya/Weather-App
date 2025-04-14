import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/hourly_forecast_items.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/openweather_api_key.dart';
import 'dart:convert';

class WeatherAppMaterialPage extends StatefulWidget {
  const WeatherAppMaterialPage({super.key});

  @override
  State<WeatherAppMaterialPage> createState() => _WeatherAppMaterialPageState();
}

class _WeatherAppMaterialPageState extends State<WeatherAppMaterialPage> {

Future<Map<String, dynamic>> fetchWeather(String city) async {
  final url = "https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$openWeatherAPIKEY";

  try {
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    if(data["cod"] != "200"){
      throw "An unexpected error occured";
    }
    else{
      return data;
    }

  } catch (e) {
    throw e.toString();
  }
}

  @override
  Widget build(BuildContext context) {

    String cityName = "New Delhi";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => {
              // debugPrint("Refresh");
              setState(() {        
                fetchWeather(cityName);
              })
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchWeather(cityName),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return LinearProgressIndicator();
          }
          if(snapshot.hasError){
            return Text(snapshot.error.toString());
          }

          // CURRENT DATA 
          final data = snapshot.data!;
          final currentTemp = data['list'][0]['main']['temp'];
          final windSpeed = data['list'][0]['wind']['speed'];
          final humidity = data['list'][0]['main']['humidity'];
          final pressure = data['list'][0]['main']['pressure'];
          final city = data['city']['name'];
          final sky = data['list'][0]['weather'][0]['main'];
    
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding( 
                padding: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MAIN CARD
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: Color.fromARGB(255, 44, 41, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 15,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Text(
                                    "$city",
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 19,
                                      fontWeight: FontWeight.w200,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 2,
                                    ), 
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${currentTemp-273}°C",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Icon(
                                    sky == "Clouds" || sky == "Rain" ? Icons.cloud:Icons.sunny, size: 64,
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    "$sky",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
              
                    // hourly forecast cards
                    Text(
                      "Hourly Forecast",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: "Poppins",
                      ),
                    ),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: [
                        //   HourlyForecastItem(
                        //     time: "03:00",
                        //     icon: Icons.sunny,
                        //     temperature: "300.52",
                        //   ),
                        //   HourlyForecastItem(
                        //     time: "06:00",
                        //     icon: Icons.cloud,
                        //     temperature: "302.22",
                        //   ),
                        //   HourlyForecastItem(
                        //     time: "09:00",
                        //     icon: Icons.sunny,
                        //     temperature: "300.12",
                        //   ),
                        //   HourlyForecastItem(
                        //     time: "12:00",
                        //     icon: Icons.cloudy_snowing,
                        //     temperature: "304.12",
                        //   ),
                      //     for (int i = 0; i < 6; i++) ...[
                      //       HourlyForecastItem(
                      //         icon: (data["list"][i+1]["weather"][0]["main"] == "Clouds" || data["list"][i+1]["weather"][0]["main"] == "Rain") ? Icons.cloud:Icons.sunny,
                      //         time: data["list"][i+1]["dt"].toString(),
                      //         temperature: data["list"][i+1]["main"]["temp"].toString(),
                      //       )
                      //     ]
                      //   ],
                      // ),
                    // ),
            
                    SizedBox(
                      height: 125,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final timeObject = DateTime.parse(data["list"][index+1]["dt_txt"]);
                          final time = DateFormat.j().format(timeObject);
                          double temperatureInDegreeCelcius = (data["list"][index+1]["main"]["temp"])-273;
                          return HourlyForecastItem(
                            time: time.toString(),
                            icon: (data["list"][index+1]["weather"][0]["main"] == "Clouds" || data["list"][index+1]["weather"][0]["main"] == "Rain") ? Icons.cloud:Icons.sunny,
                            temperature: "${temperatureInDegreeCelcius.toStringAsFixed(2)}°C",
                          );
                        }
                      ),
                    ),
            
                    const SizedBox(height: 20),
              
                    // additional information
                    Text(
                      "Additional Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: "Poppins",
                      ),
                    ),
              
                    const SizedBox(height: 8),
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                          icon: Icons.water_drop,
                          label: "Humidity",
                          value: "$humidity",
                        ),
                        AdditionalInfoItem(
                          icon: Icons.air,
                          label: "Wind Speed",
                          value: "$windSpeed",
                        ),
                        AdditionalInfoItem(
                          icon: Icons.beach_access,
                          label: "Pressure",
                          value: "$pressure",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          );
        },
      ),
    );
  }
}