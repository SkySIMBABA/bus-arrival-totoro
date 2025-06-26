import 'package:flutter/material.dart';
import '../services/lta_api_service.dart';
import '../models/bus_arrival.dart';

class BusDashboardPage extends StatefulWidget {
  @override
  _BusDashboardPageState createState() => _BusDashboardPageState();
}

class _BusDashboardPageState extends State<BusDashboardPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bus Arrivals')),
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
                return Card(
                  child: ListTile(
                    title: Text('Service ${bus.serviceNo}'),
                    subtitle: Text('Arrivals: ${bus.arrivalTimes.join(', ')}'),
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
