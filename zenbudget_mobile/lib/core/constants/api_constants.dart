class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:7000/api/v1';
  // 10.0.2.2 → Android emülatöründen localhost'a erişim adresi
  // Gerçek cihazda bilgisayarının IP'sini yaz: http://192.168.x.x:7000/api/v1

  static const String auth = '/auth';
  static const String transactions = '/transactions';
  static const String categories = '/categories';
  static const String budgets = '/budgets';
  static const String dashboard = '/dashboard/summary';
  static const String reports = '/reports';
}