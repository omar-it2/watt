import 'package:flutter/material.dart';


class NoConnectionWidget extends StatelessWidget {
  const NoConnectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: width / 2,
                width: width / 2,
                child: Icon(Icons.wifi_off)
              ),
              const SizedBox(height: 20,),
              Text("No Connection",
                style: Theme.of(context).textTheme.subtitle1!.apply(fontWeightDelta: 2),)
            ],
          ),
        ),
      ),
    );
  }
}
