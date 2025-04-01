import 'package:flutter/material.dart';
import 'event_service.dart';
import 'location_service.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:hive/hive.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  String? errorMsg;

  late Box<String> favoritesBox;
  List<String> get favoriteEventIds => favoritesBox.values.toList();


  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Music', 'Sports', 'Arts', 'Tech'];

  @override
  void initState() {
    super.initState();
    favoritesBox = Hive.box<String>('favoritesBox');
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final position = await LocationService.getLocation();
      final result = await EventService.fetchEvents(
        position.latitude,
        position.longitude,
      );
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

  List<Map<String, dynamic>> get filteredEvents {
    return events.where((event) {
      final name = event['name'].toString().toLowerCase();
      final category =
          event['classifications']?[0]?['segment']?['name']?.toLowerCase() ??
          'other';
      return (selectedCategory == 'All' ||
              category == selectedCategory.toLowerCase()) &&
          name.contains(searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get favoriteEvents {
    return events.where((e) => favoriteEventIds.contains(e['id'])).toList();
  }

  void toggleFavorite(String eventId) {
    setState(() {
      if (favoriteEventIds.contains(eventId)) {
        favoriteEventIds.remove(eventId);
      } else {
        favoriteEventIds.add(eventId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Nearby Events'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Consumer<ThemeProvider>(
            builder:
                (context, themeProvider, _) => Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                  activeColor: Colors.white,
                ),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : RefreshIndicator(
                onRefresh: loadEvents,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔍 Search
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search events...',
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => setState(() => searchQuery = val),
                        ),

                        SizedBox(height: 12),

                        // 🔘 Category Chips
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children:
                                categories.map((cat) {
                                  final isSelected = selectedCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(cat),
                                      selected: isSelected,
                                      onSelected:
                                          (_) => setState(
                                            () => selectedCategory = cat,
                                          ),
                                      selectedColor: Colors.deepPurple,
                                      backgroundColor: Colors.grey.shade200,
                                      labelStyle: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        SizedBox(height: 24),

                        // ❤️ Favorites Horizontal List
                        if (favoriteEvents.isNotEmpty) ...[
                          Text(
                            "Your Favorites",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 170,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: favoriteEvents.length,
                              itemBuilder: (context, index) {
                                final event = favoriteEvents[index];
                                final imageUrl =
                                    event['images']?[0]?['url'] ?? '';
                                return GestureDetector(
                                  onTap:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/details',
                                        arguments: event,
                                      ),
                                  child: Container(
                                    width: 140,
                                    margin: EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Theme.of(context).cardColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Image.network(
                                            imageUrl,
                                            height: 100,
                                            width: 140,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            event['name'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 24),
                        ],

                        // 📆 Upcoming Events
                        Text(
                          "Upcoming Events",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),

                        if (filteredEvents.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No events found for "$selectedCategory"',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children:
                                filteredEvents.map((event) {
                                  final venue =
                                      event['_embedded']?['venues']?[0]?['name'] ??
                                      'Unknown';
                                  final date =
                                      event['dates']['start']['localDate'] ??
                                      'TBA';
                                  final time =
                                      event['dates']['start']['localTime'] ??
                                      'TBA';
                                  final imageUrl =
                                      event['images']?[0]?['url'] ?? '';
                                  final isFavorited = favoriteEventIds.contains(
                                    event['id'],
                                  );

                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(12),
                                      leading:
                                          imageUrl.isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                              : Icon(Icons.image_not_supported),
                                      title: Text(
                                        event['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple[800],
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: 4),
                                              Text(date),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: 4),
                                              Text(time),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  venue,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          isFavorited
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              isFavorited
                                                  ? Colors.red
                                                  : Colors.grey,
                                        ),
                                        onPressed:
                                            () => toggleFavorite(event['id']),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/details',
                                          arguments: event,
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
