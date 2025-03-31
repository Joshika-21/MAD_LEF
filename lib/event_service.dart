import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {
  static const String apiKey = '39ZsGws53POWAWqZ4o18STVQY1Z1edqz';

  static Future<List<Map<String, dynamic>>> fetchEvents(
    double lat,
    double lon,
  ) async {
    final url =
        'https://app.ticketmaster.com/discovery/v2/events.json?apikey=$apiKey&latlong=$lat,$lon&radius=25&unit=km';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final events = data['_embedded']?['events'] ?? [];
      return List<Map<String, dynamic>>.from(events);
    } else {
      throw Exception('Failed to fetch events');
    }
  }
}
