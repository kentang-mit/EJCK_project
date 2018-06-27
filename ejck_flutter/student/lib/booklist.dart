import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'bookitem.dart';
import 'themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Book{
  final String author;
  final String authors;
  final int bid;
  final String course;
  final String detailInformation;
  final int edition;
  final String name;
  final double price;
  final int totalNum;
  final String publisher;

  Book({this.author, this.authors, this.bid, this.course, 
  this.detailInformation, this.edition, this.name, this.price, this.totalNum,
  this.publisher});

  factory Book.fromJson(Map<String, dynamic> json){
    return new Book(
      author: json['author'],
      authors: json['authors'],
      bid: json['bid'],
      course: json['course'],
      detailInformation: json['detailInformation'],
      edition: json['edition'],
      name: json['name'],
      price: double.parse(json['price']),
      totalNum: json['num'],
      publisher: json['publisher'],
    );
  }
}
class Booklist extends StatefulWidget{
  const Booklist();
  @override
  _BooklistState createState() => _BooklistState();
}

class _BooklistState extends State<Booklist>{

  List<BookItem> _bookItems = <BookItem>[];

  @override
  Future<void> didChangeDependencies()async{
    if(_bookItems.isEmpty){
      await _fetchBooks();
    }
  }

  Future<void> _fetchBooks() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String curClass = prefs.get('classnum')??"";
    if(curClass=="") return;

    final response = await http.get('http://101.132.153.104:8888/api/get_class_books?class=$curClass');
    final responsejson = json.decode(response.body);
    for(int i = 0; i < responsejson.length; i++){
      //books.add(Book.fromJson(responsejson[i]));
      Book curbook = Book.fromJson(responsejson[i]);
      var curitem = BookItem(
        name: curbook.name,
        totalNum: curbook.totalNum,
        authors: curbook.authors,
        course: curbook.course,
        edition: curbook.edition,
        publisher: curbook.publisher,
        price: curbook.price
      );
      _bookItems.add(curitem); 
    }
    //return Book.fromJson(responsejson[1]);
  }

  Widget _buildBookItems(){
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) => _bookItems[index],
      itemCount: _bookItems.length,
    );
  }

  @override
  Widget build(BuildContext context){
    final listview = Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: _buildBookItems(),
    );

    return new MaterialApp(
      title: 'Book List',
      theme: kDarkGalleryTheme.data,
      home: new Scaffold(
        body: listview,
      ),
    );
  }
}