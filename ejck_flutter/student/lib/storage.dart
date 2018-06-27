import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Storage> fetchStorage() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.remove('token');
  var classnum = (prefs.getString('classnum') ?? "");
  var token = prefs.getString('token') ?? "";
  print("This is token: "+token);
  String name;
  if(token == ""){
    return new Storage("未登录");
  }
  else{
    try{
      final response = await http.get('https://api.sjtu.edu.cn/v1/me/profile?access_token=$token');
      final responsejson = json.decode(response.body);
      final _json = responsejson['entities'][0];
      name = _json['name'];
      print(name);
      if(classnum == ''){
        name = name + "（未设置班级）";
      }
      else{
        name = name + "（$classnum）";
      }
    }catch(e){
      print(e);
      return new Storage("登陆过期");
    }
    return new Storage(name);
  }
  // print(clasnum);
  

}

class Storage{
  final String classnum;
  Storage(String cla):classnum=cla;
  // Storage({this.classnum});
}

void setClassnum(clnum) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('classnum', clnum);
}



void setToken(token) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<String> getToken() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = (prefs.getString('token')??'');
  return token;
}