import 'package:flutter/material.dart';
import 'themes.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
const _padding = EdgeInsets.all(16.0);


class BookQueue extends StatefulWidget{
  const BookQueue();
  @override
  _BookQueueState createState() => _BookQueueState();
}

class _BookQueueState extends State<BookQueue>{
  List<ListTile> _bookqueue = [];
  int thenum;

  void _fetchQueue() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String curClass = prefs.get('classnum')??"";
    if(curClass=="") return;
    final response = await http.get('http://101.132.153.104:8888/api/get_queue?class=$curClass');
    final responsejson = json.decode(response.body);
    thenum = responsejson['num'];
    _bookqueue = [];
    for(int i = 0; i < responsejson['classes'].length; i++){
      _bookqueue.add(
        ListTile(
          title:Text(
          responsejson['classes'][i],
          style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:24.0),
          ),
        )
      );
    }
  }

  @override
  Future<void> didChangeDependencies()async{
    if(_bookqueue.isEmpty){
      await _fetchQueue();
    }
  }


  @override
  Widget build(BuildContext context){
    int predictedTime = thenum * 5;
    _fetchQueue();
    return new MaterialApp(
      theme: kDarkGalleryTheme.data,
      home: new Container(
        child: Padding(
          padding: _padding,
          child:
          Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[
            Center(
              child:Row(
                children:[
                  Icon(
                    Icons.people,
                  ),
                  Padding(padding: EdgeInsets.all(16.0),),
                  Text(
                    "当前你班排在第 $thenum 位",
                    style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:24.0),
                  ),
                ],
              ),
            ),

            Padding(padding: EdgeInsets.symmetric(vertical: 16.0),),
            Center(
              child:Row(
                children:[
                  Icon(
                    Icons.alarm,
                  ),
                  Padding(padding: EdgeInsets.all(16.0),),
                  Text(
                    "预计时间： $predictedTime 分钟",
                    style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:24.0),
                  ),
                ],
              ),
            ),

            Padding(padding: EdgeInsets.symmetric(vertical: 16.0),),
            Center(
              child:Row(
                children:[
                  Icon(
                    Icons.info,
                  ),
                  Padding(padding: EdgeInsets.all(16.0),),
                  Text(
                    "等待列表：",
                    style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:24.0),
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
            ExpansionTile(
              title: Text(
                thenum>1?'展开查看':'无需等待',
                style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:20.0),
              ),
              children: _bookqueue
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 16.0),),
            FlatButton(
              onPressed: (){
                setState((){});
              },
              child: 
              Text(
                '刷新',
                style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:20.0),
              ),
            ),

          ],
        ),
      ),
      ),
    );
  }
}

