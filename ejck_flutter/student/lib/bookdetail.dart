import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'themes.dart';

const _padding = EdgeInsets.all(16.0);

class BookDetail extends StatelessWidget{
  final String name;
  final int totalNum;
  final double price;
  final String authors;
  final String publisher;
  final int edition;
  //final String detailInformation;

  const BookDetail({
    @required this.name,
    @required this.totalNum,
    @required this.price,
    @required this.authors,
    @required this.publisher,
    @required this.edition,
  }
  ): assert(name!=null),
    assert(totalNum!=null);

  @override
  Widget build(BuildContext context){
    final double totalPrice = price * totalNum;
    final information = Scaffold(
      body: Padding(
          padding: _padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              
              InputDecorator(
                child: Text(
                  "$name（第 $edition 版)",
                  style: Theme.of(context).textTheme.title,
                ),
                decoration: InputDecoration(
                  labelText: '书名',
                  labelStyle: Theme.of(context).textTheme.title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
              ),
              InputDecorator(
                child: Text(
                  authors??"",
                  style: Theme.of(context).textTheme.title,
                ),
                decoration: InputDecoration(
                  labelText: '作者',
                  labelStyle: Theme.of(context).textTheme.title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
              ),
             
              InputDecorator(
                child: Text(
                  publisher??"",
                  style: Theme.of(context).textTheme.title,
                ),
                decoration: InputDecoration(
                  labelText: "出版社",
                  labelStyle: Theme.of(context).textTheme.title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
              ),
              InputDecorator(
                child: Text(
                  "$price($totalPrice) 元",
                  style: Theme.of(context).textTheme.title,
                ),
                decoration: InputDecoration(
                  labelText: "单价(总价)",
                  labelStyle: Theme.of(context).textTheme.title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
              ),
              InputDecorator(
                child: Text(
                  "$totalNum 本",
                  style: Theme.of(context).textTheme.title,
                ),
                decoration: InputDecoration(
                  labelText: "总数",
                  labelStyle: Theme.of(context).textTheme.title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
              ),
              Padding(
                padding: _padding*1.5,
                child:
                FlatButton(
                  onPressed: ()=>Navigator.of(context).pop(true),
                  child: Text(
                    "点击返回",
                  ),
                ),
              ),

            ]  
          ),
        ),
        );

    return new MaterialApp(
      theme: kDarkGalleryTheme.data,
      home: new Scaffold(body:information),
    );
  }
}
