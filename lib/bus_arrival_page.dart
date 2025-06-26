import 'package:flutter/material.dart';
import 'services/lta_api_service.dart';
import 'models/bus_arrival.dart';
import 'dart:math';

class BusArrivalPage extends StatefulWidget {
  @override
  _BusArrivalPageState createState() => _BusArrivalPageState();
}

class _BusArrivalPageState extends State<BusArrivalPage> {
  late Future<List<BusArrival>> _futureArrivals;

  @override
  void initState() {
    super.initState();
    _futureArrivals = LtaApiService.fetchBusArrivals();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureArrivals = LtaApiService.fetchBusArrivals();
    });
  }

  int? _minutesLeft(String arrivalTime) {
    if (arrivalTime == 'N/A') return null;
    try {
      final now = DateTime.now();
      final arrival = DateTime(now.year, now.month, now.day,
          int.parse(arrivalTime.substring(0, 2)),
          int.parse(arrivalTime.substring(3, 5)),
          int.parse(arrivalTime.substring(6, 8)));
      final diff = arrival.difference(now).inMinutes;
      return diff < 0 ? null : diff;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F6FD),
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              'https://pngimg.com/d/totoro_PNG16.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text('Totoro Bus Arrivals', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Color(0xFF7AC7C4),
        elevation: 0,
      ),
      body: FutureBuilder<List<BusArrival>>(
        future: _futureArrivals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text('Failed to load bus arrivals.', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text(snapshot.error.toString(), style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bus arrivals found.'));
          }
          final arrivals = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: arrivals.length,
              itemBuilder: (context, index) {
                final bus = arrivals[index];
                final mins = bus.arrivalTimes.map(_minutesLeft).where((m) => m != null).toList();
                return Card(
                  color: Color(0xFFB2EBF2),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: Image.network(
                      'https://pngimg.com/d/totoro_PNG16.png',
                      height: 40,
                    ),
                    title: Text('Service ${bus.serviceNo}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    subtitle: mins.isEmpty
                        ? Text('No upcoming buses', style: TextStyle(color: Colors.grey))
                        : Row(
                            children: mins.map((m) => Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Chip(
                                label: Text('$m min', style: TextStyle(fontWeight: FontWeight.bold)),
                                backgroundColor: Color(0xFF7AC7C4),
                              ),
                            )).toList(),
                          ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
