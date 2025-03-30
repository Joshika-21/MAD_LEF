import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> event =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final url = event['url'];
    final venue = event['_embedded']?['venues']?[0]?['name'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: Text(event['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${event['dates']['start']['localDate']}", style: TextStyle(fontSize: 18)),
            Text("Time: ${event['dates']['start']['localTime'] ?? 'TBA'}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Venue: $venue", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Text('Buy Tickets / View Online'),
            )
          ],
        ),
      ),
    );
  }
}
