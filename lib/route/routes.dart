import 'package:get/get.dart';
import '../auth_screen/login_screen.dart';
import '../auth_screen/signup_screen.dart';
import '../home/home_screen.dart';
import '../onBoarding_screen/splash_screen.dart';


class MyRouters {
  static var route = [
    GetPage(name: '/', page: () => const SplashScreen()),

    GetPage(name: SignupScreen.route, page: () => SignupScreen()),
    GetPage(name: LoginScreen.route, page: () => LoginScreen()),
    GetPage(name: TodoScreen.route, page: () => TodoScreen()),

  ];
}
