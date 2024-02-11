class UserModel {
  String email;
  String password;

  UserModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
     Map<String, dynamic> data =  {};
    data['email'] = email;
    data['password'] = password;
    return data;
  }
}
class ResponseModel {
  String? token;
String? id;
  ResponseModel({ this.token,this.id});

 ResponseModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    id=json['id'];
  }
}