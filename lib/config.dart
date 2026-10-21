class AppConfig {
  // Nak tukar URL backend? Run macam ni ek:
  //   flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.10:3000
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
