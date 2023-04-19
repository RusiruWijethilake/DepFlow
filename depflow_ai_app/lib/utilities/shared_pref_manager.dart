import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefManager {

  Future<void> saveAccessToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    print("Saved Refresh Token: ${prefs.getString('refreshToken')}");
    prefs.setString('refreshToken', refreshToken);
  }

  Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    print("Retrieved Refresh Token: ${prefs.getString('refreshToken')}");
    return prefs.getString('refreshToken') ?? '';
  }
}