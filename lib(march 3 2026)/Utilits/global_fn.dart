import 'package:shared_preferences/shared_preferences.dart';

Future<String?> fnGetBaseUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? BaseUrl = prefs.getString('BaseUrl');
  return BaseUrl;
}