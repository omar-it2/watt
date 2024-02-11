import 'package:get/get_connect.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';

import '../models/user_model.dart';


class LoginService extends GetConnect {
  final String loginUrl = 'https://reqres.in/api/login';


  Future<ResponseModel?> fetchLogin(UserModel model) async {
    final response = await post(loginUrl, model.toJson());

    if (response.statusCode == HttpStatus.ok) {
      return ResponseModel.fromJson(response.body);
    } else {
      return null;
    }
  }


}