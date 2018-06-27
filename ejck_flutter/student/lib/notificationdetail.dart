import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

const _padding = EdgeInsets.all(24.0);

class NotiDetail extends StatelessWidget{
  final String title;
  final String content;
  //final double price;
  //final String author;
  //final String publisher;
  //final String detailInformation;

  const NotiDetail({
    @required this.title,
    @required this.content,
  }
  ): assert(title!=null),
    assert(content!=null);

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      body:
        Column(
          children:[ 
          Padding(
            padding: _padding,
            child: InputDecorator(
                child: Text(
                    title,
                    style: Theme.of(context).textTheme.title,
                  ),
                  decoration: InputDecoration(
                    labelText: '标题',
                    labelStyle: Theme.of(context).textTheme.title,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
          ),
          Padding(
            padding: _padding,
            child: InputDecorator(
                child: Text(
                    '教材科',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  decoration: InputDecoration(
                    labelText: '发布人',
                    labelStyle: Theme.of(context).textTheme.title,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: InputDecorator(
                child: Text(
                    content,
                    style: Theme.of(context).textTheme.title,
                  ),
                  decoration: InputDecoration(
                    labelText: '内容',
                    labelStyle: Theme.of(context).textTheme.title,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
          ),
          FlatButton(
            padding: _padding,
            onPressed: ()=>Navigator.of(context).pop(true),
            child: Text("返回信息列表"),  
          ),
          ],
          
        ),
    );
  }
}
