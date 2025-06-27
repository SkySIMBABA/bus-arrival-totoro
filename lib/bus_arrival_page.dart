import 'package:flutter/material.dart';
import '../services/lta_api_service.dart';
import '../models/bus_arrival.dart';
import 'dart:async';
import 'dart:math';

class BusArrivalPage extends StatefulWidget {
  @override
  _BusArrivalPageState createState() => _BusArrivalPageState();
}

class _BusArrivalPageState extends State<BusArrivalPage>
    with TickerProviderStateMixin {
  late Future<List<BusArrival>> _futureArrivals;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _busStopController = TextEditingController();
  String _busStopCode = '83139';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _busStopController.text = _busStopCode;
    _futureArrivals = LtaApiService.fetchBusArrivals(busStopCode: _busStopCode);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _busStopController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _futureArrivals = LtaApiService.fetchBusArrivals(busStopCode: _busStopCode);
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _fetchArrivals() {
    if (_busStopController.text.isNotEmpty) {
      setState(() {
        _busStopCode = _busStopController.text;
        _futureArrivals = LtaApiService.fetchBusArrivals(busStopCode: _busStopCode);
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  int? _minutesLeft(String arrivalTime) {
    if (arrivalTime == 'N/A') return null;
    try {
      final now = DateTime.now();
      final arrival = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(arrivalTime.substring(0, 2)),
        int.parse(arrivalTime.substring(3, 5)),
        int.parse(arrivalTime.substring(6, 8)),
      );
      final diff = arrival.difference(now).inMinutes;
      return diff < 0 ? null : diff;
    } catch (_) {
      return null;
    }
  }

  Color _getChipColor(int minutes) {
    if (minutes <= 2) return Colors.red.shade400;
    if (minutes <= 5) return Colors.orange.shade400;
    return Colors.green.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildBusStopInput(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.directions_bus,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus Arrivals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SFProDisplay',
                  ),
                ),
                Text(
                  'Real-time updates',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontFamily: 'SFProDisplay',
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _refresh,
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusStopInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _busStopController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontFamily: 'SFProDisplay', fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter Bus Stop Number',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: _fetchArrivals,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Search', style: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: FutureBuilder<List<BusArrival>>(
        future: _futureArrivals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final arrivals = snapshot.data!;
          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: Color(0xFF667eea),
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: arrivals.length,
                itemBuilder: (context, index) {
                  return _buildBusCard(arrivals[index], index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading bus arrivals...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontFamily: 'SFProDisplay',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                fontFamily: 'SFProDisplay',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Failed to load bus arrivals',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'SFProDisplay',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SFProDisplay',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.directions_bus_outlined,
                color: Colors.blue.shade400,
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No buses found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                fontFamily: 'SFProDisplay',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'SFProDisplay',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusCard(BusArrival bus, int index) {
    final mins = bus.arrivalTimes
        .map(_minutesLeft)
        .where((m) => m != null)
        .cast<int>()
        .toList();

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 600 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service ${bus.serviceNo}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                            fontFamily: 'SFProDisplay',
                          ),
                        ),
                        Text(
                          '${mins.length} bus${mins.length != 1 ? 'es' : ''} arriving',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontFamily: 'SFProDisplay',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (mins.isNotEmpty) ...[
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: mins.map((m) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getChipColor(m).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getChipColor(m).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getChipColor(m),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '$m min',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getChipColor(m),
                              fontFamily: 'SFProDisplay',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.grey.shade500,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'No upcoming buses',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'SFProDisplay',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
