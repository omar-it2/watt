import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/connection.dart';
import 'dailog.dart';

class BaseConnectivityWidget extends StatefulWidget {
  final Widget child;

  const BaseConnectivityWidget({Key? key, required this.child})
      : super(key: key);

  @override
  State<BaseConnectivityWidget> createState() => _BaseConnectivityWidgetState();
}

class _BaseConnectivityWidgetState extends State<BaseConnectivityWidget> {


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectivityController>();
    return Obx(() {
      if (controller.connectionType != MConnectivityResult.none) {
        return widget.child;
      }
      else {
        return const NoConnectionWidget();
      }
    });

  }
}
