import 'package:get/get.dart';
import '../services/database_helper.dart';
import '../services/preference_service.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';

class AuthController extends GetxController {
  final RxString username = ''.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    checkLogin();
    super.onInit();
  }

  Future<void> checkLogin() async {
    final loggedIn = await PreferenceService.instance.isLoggedIn();
    isLoggedIn.value = loggedIn;
    if (loggedIn) {
      final user = await PreferenceService.instance.getUsername();
      username.value = user ?? '';
    }
  }

  Future<bool> login(String user, String pass) async {
    final account = await DatabaseHelper.instance.login(user, pass);
    if (account != null) {
      await PreferenceService.instance.setLoginSession(account.username);
      username.value = account.username;
      isLoggedIn.value = true;
      Get.offAll(() => const MainNavigationScreen());
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await PreferenceService.instance.logout();
    username.value = '';
    isLoggedIn.value = false;
    Get.offAll(() => const LoginScreen());
  }
}
