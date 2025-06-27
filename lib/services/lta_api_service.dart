import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bus_arrival.dart';
import 'package:flutter/foundation.dart';

class LtaApiService {
  static const _apiKey = 'xEh4xOy6SK2WlgFabWlmfg==';
  static const _defaultBusStopCode = '83139';

  static Future<List<BusArrival>> fetchBusArrivals({String busStopCode = _defaultBusStopCode}) async {
    // Use mock data for web, live API for other platforms
    if (kIsWeb) {
      // Return mock data for web
      await Future.delayed(Duration(seconds: 1));
      return [
        BusArrival(serviceNo: '12', arrivalTimes: ['08:15:00', '08:25:00', '08:35:00']),
        BusArrival(serviceNo: '21', arrivalTimes: ['08:18:00', '08:28:00', '08:38:00']),
        BusArrival(serviceNo: '65', arrivalTimes: ['08:20:00', '08:30:00', '08:40:00']),
      ];
    }
    
    final url = Uri.parse('http://localhost:3000/lta/ltaodataservice/BusArrivalv2?BusStopCode=$busStopCode');
    try {
      final response = await http.get(url, headers: {
        'AccountKey': _apiKey,
        'accept': 'application/json',
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to load bus arrivals: ${response.statusCode}');
      }
      final jsonData = jsonDecode(response.body);
      final List buses = jsonData['Services'];
      return buses.map((bus) {
        final List<String> times = ['NextBus', 'NextBus2', 'NextBus3'].map((key) {
          final eta = bus[key]['EstimatedArrival'];
          return eta == '' ? 'N/A' : DateTime.parse(eta).toLocal().toString().substring(11, 19);
        }).toList();
        return BusArrival(serviceNo: bus['ServiceNo'], arrivalTimes: times);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching bus arrivals: ${e.toString()}');
    }
  }
}
