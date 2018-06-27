import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> popQue() async {
  String url = 'http://101.132.153.104:8888/api/pop_queue';
  print("pop start!");
  await http.post(url)
      .then((response) {
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    print("!END!");
    // print(json.decode(response.body));
  });
}

Future<QueList> fetchQue() async{
    final response = await http.get('http://101.132.153.104:8888/api/get_all_queue');
    final responsejson = json.decode(response.body);
    print("Response body: ${response.body}");
    print("!END!");
    return QueList.fromJson(responsejson);
  }
  
Future<void> pushQue(String classnum) async {
  String url = 'http://101.132.153.104:8888/api/push_queue';
  print("async start!");
  await http.post(url, body: json.encode({"class": classnum}))
      .then((response) {
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    print("!END!");
    print(json.decode(response.body));
  });
}



class QueList {
  // final String code;
  final List<dynamic> classes ;
  final int count;
  QueList({this.classes,this.count});
  factory QueList.fromJson(Map<String, dynamic> json) {
    return QueList(
      classes: json["classes"],
      count:json["num"]
    );
  }
}
