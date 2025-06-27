# Totoro Bus Arrival App

A cute, modern Flutter app to check Singapore bus arrival times, inspired by Totoro! 🐾

![Totoro Banner](https://pngimg.com/d/totoro_PNG16.png)

## 🌐 Live Demo
**[Try the app online!](https://skysimbaba.github.io/bus-arrival-totoro/)**

## Features

- 🚌 See how many minutes left until the next buses arrive at your stop
- 🐻 Totoro-themed, 2025-style UI with adorable graphics
- 🌐 Works on web (shows mock data for demo)
- 📱 Live LTA API data on mobile and desktop (no CORS issues)
- 🔄 Pull-to-refresh for the latest arrivals
- 🚨 Friendly error handling and retry

## Screenshots
_Add your screenshots here!_

## How to Run

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart

### Web (Demo with Mock Data)
```sh
flutter run -d chrome
```

### Mobile/Desktop (Live Data)
```sh
flutter run -d windows   # or -d android, -d ios
```

> Note: The LTA API does not support CORS, so live data only works on mobile/desktop. Web uses mock data for a smooth demo.

## Deployment

This app is automatically deployed to GitHub Pages using GitHub Actions. Every push to the `main` branch triggers a new build and deployment.

### Manual Deployment
```sh
flutter build web
# The build output is in build/web/
```

## Project Structure
- `lib/bus_arrival_page.dart` — Main Totoro bus arrival UI
- `lib/services/lta_api_service.dart` — API and mock data logic
- `lib/models/bus_arrival.dart` — Bus arrival model

## Credits
- Totoro images: [pngimg.com](https://pngimg.com/d/totoro_PNG16.png)
- Bus data: [LTA DataMall](https://datamall.lta.gov.sg/)

## License
MIT (see LICENSE)

---
_Made with Flutter and Totoro spirit!_
