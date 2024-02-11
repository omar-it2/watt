
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testforwatt/screen/login.dart';
import 'package:testforwatt/screen/startLocations.dart';

import '../authentication/auhentication.dart';

class OnBoard extends StatelessWidget {
  const OnBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationManager _authManager = Get.find();

    return Obx(() {
      return _authManager.isLogged.value ? StartLocation() : LogIn();
    });
  }
}