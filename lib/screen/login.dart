import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../models/login_model.dart';
import '../widgets/connectivitywidget.dart';


class LogIn extends StatefulWidget {
  LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoginModel _viewModel = Get.put(LoginModel());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return BaseConnectivityWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text(  "Login"),
        ),
        body: Form(
          key: _formKey,
          child:  Center(
            child: Container(
              width: MediaQuery.of(context).size.width*0.8,
              height:MediaQuery.of(context).size.height*0.8 ,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextFormField(decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),

                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.grey),
                    fillColor: Colors.grey.shade200,


                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                    controller: _emailController,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please enter Email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),

                    labelText: "password",
                    labelStyle: TextStyle(color: Colors.grey),
                    fillColor: Colors.grey.shade200,


                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                    controller: _passwordController,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please enter Password';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _viewModel.loginUser(_emailController.text, _passwordController.text);
                        }
                      },
                      child: Text("LogIn")),
                  Text("user can login is \nemail: eve.holt@reqres.in\npassword: cityslicka")

                ],
              ),
            ),
          ),

        ) ,
      ),
    );
  }




}
