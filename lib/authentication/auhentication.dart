
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthenticationManager extends GetxController  {
  final isLogged = false.obs;

  Future<void> logOut() async {
    isLogged.value = false;
    final userToken = GetStorage();
    await userToken.remove(ManagerKey.TOKEN.toString());
  }

  void login(String? token) async {
    isLogged.value = true;
    final userToken = GetStorage();
    await userToken.write(ManagerKey.TOKEN.toString(), token);
  }

  void checkLoginStatus() {
    final userToken = GetStorage();

    final token = userToken.read(ManagerKey.TOKEN.toString());
    if (token != null) {
      isLogged.value = true;
    }
  }
}
enum ManagerKey { TOKEN }