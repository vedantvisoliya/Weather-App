import 'package:flutter/material.dart';
import 'package:weather_app/weather_app_material_page.dart';

void main(){
  runApp(MyMaterialApp());
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Weather App",
      theme: ThemeData.dark(useMaterial3: true),
      home: const WeatherAppMaterialPage(),
    );
  }
}
