import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> event =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final url = event['url'];
    final venue = event['_embedded']?['venues']?[0]?['name'] ?? 'Unknown';
    final imageUrl = event['images']?[0]?['url'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (imageUrl.isNotEmpty) SizedBox(height: 16),
                  Text(
                    event['name'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Divider(height: 30, thickness: 1.2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Date: ${event['dates']['start']['localDate']}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined, color: Colors.grey[700]),
                      SizedBox(width: 8),
                      Text(
                        "Time: ${event['dates']['start']['localTime'] ?? 'TBA'}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey[700]),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Venue: $venue",
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(url);

                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open the ticket link'),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.open_in_new),
                      label: Text('Buy Tickets / View Online'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
