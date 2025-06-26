import 'package:flutter/material.dart';
import 'pages/bus_dashboard_page.dart';
import 'bus_arrival_page.dart';

void main() {
  runApp(MaterialApp(
    home: BusDashboardPage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.blue),
    routes: {
      '/bus-arrival': (context) => BusArrivalPage(),
    },
  ));
}
