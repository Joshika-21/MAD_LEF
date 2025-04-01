# local_events_finder

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

# 🎟️ Local Events Finder

**Local Events Finder** is a Flutter-based mobile application that helps users discover events happening around them based on their current location. Users can explore categories like Music, Sports, Arts, and Tech, save favorites, and buy tickets — all in one place!


## 🚀 Features

✅ **Search & Discover:**  
Browse a curated list of local events using the Ticketmaster API.

✅ **Category Filters:**  
Quickly find what you love — filter by Music, Sports, Arts, or Tech.

✅ **Favorites (Offline Support):**  
Mark events as favorites and store them locally using Hive.

✅ **Event Details Page:**  
View event images, time, venue, and a direct ticket purchase link.

✅ **Modern UI + Light/Dark Theme:**  
Sleek and responsive design with customizable theme toggle.

✅ **Authentication:**  
Sign in or Sign up securely using Firebase Authentication.

✅ **Responsive Layout:**  
Optimized for both Android emulators and real devices.


## 🛠️ Tech Stack

| Tech              | Purpose                                  |
|------------------|------------------------------------------|
| **Flutter**       | UI & Mobile Framework                    |
| **Dart**          | Language                                 |
| **Firebase Auth** | User login / registration                |
| **Ticketmaster API** | Event data provider                   |
| **Hive**          | Local data storage for favorites         |
| **Provider**      | State management (theme + favorites)     |


## 📦 Setup Instructions

### 🔧 Prerequisites
- Flutter SDK installed
- Firebase project set up
- Android Emulator or physical device

### 🔨 Run Locally

```bash
git clone https://github.com/your-username/local_events_finder.git
cd local_events_finder
flutter pub get
flutter run
