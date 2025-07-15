class AppConstants {
  static const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://xvms.irishidev.com',
  );
}
