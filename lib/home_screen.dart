import 'package:flutter/material.dart';
import 'event_service.dart';
import 'location_service.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  String? errorMsg;

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Music', 'Sports', 'Arts', 'Tech'];

  @override
  void initState() {
    super.initState();
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
          event['classifications']?[0]?['segment']?['name']
              ?.toString()
              .toLowerCase() ??
          'other';
      final matchesSearch = name.contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' ||
          category == selectedCategory.toLowerCase();
          event['classifications']?[0]?['segment']?['name'] ?? 'Other';
      final matchesSearch = name.contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' || category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Events'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Consumer<ThemeProvider>(
            builder:
                (context, themeProvider, _) => Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                  activeColor: Colors.white,
                ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
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
              : errorMsg != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: $errorMsg',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: loadEvents,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        // Search Bar
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search events...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                        SizedBox(height: 12),

                        // Filter Chips
                        Wrap(
                          spacing: 8,
                          children:
                              categories.map((cat) {
                                return ChoiceChip(
                                  label: Text(cat),
                                  selected: selectedCategory == cat,
                                  onSelected: (_) {
                                    setState(() {
                                      selectedCategory = cat;
                                    });
                                  },
                                  selectedColor: Colors.deepPurple,
                                  labelStyle: TextStyle(
                                    color:
                                        selectedCategory == cat
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                );
                              }).toList(),
                        ),
                        SizedBox(height: 12),

                        // Content section (events or empty)
                        if (filteredEvents.isEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No events found for "$selectedCategory"',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple[800],
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: 6),
                                              Text(date),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: 6),
                                              Text(time),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: 6),
                                              Flexible(
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
                                      trailing: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 18,
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
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    // Search Bar
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search events...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),

                    // Filter Chips
                    Wrap(
                      spacing: 8,
                      children:
                          categories.map((cat) {
                            return ChoiceChip(
                              label: Text(cat),
                              selected: selectedCategory == cat,
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = cat;
                                });
                              },
                              selectedColor: Colors.deepPurple,
                              labelStyle: TextStyle(
                                color:
                                    selectedCategory == cat
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 12),

                    // Event Cards
                    ...filteredEvents.map((event) {
                      final venue =
                          event['_embedded']?['venues']?[0]?['name'] ??
                          'Unknown';
                      final date =
                          event['dates']['start']['localDate'] ?? 'TBA';
                      final time =
                          event['dates']['start']['localTime'] ?? 'TBA';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            event['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[800],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 6),
                                  Text(date),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 6),
                                  Text(time),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      venue,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
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
                  ],
                ),
              ),
    );
  }
}
