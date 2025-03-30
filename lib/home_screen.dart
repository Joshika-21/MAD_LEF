import 'package:flutter/material.dart';
import 'event_service.dart';
import 'location_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final position = await LocationService.getLocation();
      final result = await EventService.fetchEvents(position.latitude, position.longitude);
      setState(() {
        events = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Events')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMsg != null
              ? Center(child: Text('Error: $errorMsg'))
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event['name']),
                      subtitle: Text(event['dates']['start']['localDate'] ?? 'No date'),
                      onTap: () {
                        Navigator.pushNamed(context, '/details', arguments: event);
                      },
                    );
                  },
                ),
    );
  }
}
