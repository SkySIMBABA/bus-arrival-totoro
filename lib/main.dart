import 'package:flutter/material.dart';
import 'pages/bus_dashboard_page.dart';
import 'bus_arrival_page.dart';

void main() {
  runApp(MaterialApp(
    home: BusArrivalPage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'SFProDisplay',
      textTheme: ThemeData.light().textTheme.copyWith(
        titleLarge: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontFamily: 'SFProDisplay'),
      ),
    ),
    routes: {
      '/bus-arrival': (context) => BusArrivalPage(),
    },
  ));
}
