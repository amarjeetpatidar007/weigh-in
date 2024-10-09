# Weight Tracker App

## Overview
The Weight Tracker App allows users to record and track their weight over time. Users can set notifications to remind them to record their weight daily, view a list of their recorded weights, and manage their notification preferences. 

## Features
- **User Setup**: On the first run, users can set their name and choose a time for daily notifications.
- **Weight Recording**: Users can record their weight each day.
- **Notification System**: Daily local notifications remind users to record their weight at the specified time.
- **Scrollable Weight List**: Displays recorded weights along with any missed days.
- **Local Data Storage**: All data is saved locally using Sqflite for efficient retrieval and management.
- **State Management**: Utilizes the Provider package for effective state management throughout the app.

## Technologies Used
- Flutter
- Dart
- Sqflite (for local database)
- Provider (for state management)
- Flutter Local Notifications (for scheduling notifications)
- 
### Prerequisites
- Flutter SDK
- Dart SDK

