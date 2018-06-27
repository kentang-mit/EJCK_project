import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'push_que.dart';
import 'themes.dart';

void main() => runApp(new MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: kDarkGalleryTheme.data,
      home: new BottomNavigationInst(),
    );
  }
}

class  BottomNavigationInst extends StatefulWidget {
  @override
  _BottomNavigationState createState() => new _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigationInst>
{
  String new_class;

  Future<void> pushQueue(String classnum) async{
    await pushQue(classnum);
    setState((){});
  }

  Future<void> popQueue() async{
    await popQue();
    setState((){});
  }

  Widget build(BuildContext context) {
  return new Scaffold(
    appBar: AppBar(title: new Text("发书排队系统")),

    body: 
    Padding(
    padding: EdgeInsets.all(16.0),
    child:Column(
        children: <Widget>[
          Center(
            child: Text('欢迎使用发书排队系统！',
            style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:22.0)),
          ),
          Padding(padding: EdgeInsets.all(8.0),),
          Align(alignment: Alignment.topLeft,
          child: Text('班级如下：',
            style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:22.0)),
          ),
          Padding(padding: EdgeInsets.all(6.0),),
          Flexible(
            child: new FutureBuilder<QueList>(
              future: fetchQue(),
                builder: (context,snapshot){
                  if (snapshot.hasData) {
                    // return new Text(snapshot.data.code);
                    return ListView.builder(
                      itemBuilder: (BuildContext context, int index)=>new ListTile(
                        title: new Text(snapshot.data.classes[index],
                        style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:22.0))
                      ),
                      itemCount: snapshot.data.count,
                    );
                  } else if (snapshot.hasError) {
                    return new Text("${snapshot.error}");
                  }
                },
            )
          ),

          Padding(padding:EdgeInsets.all(12.0)),
          TextField(
            style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:22.0),
            decoration: InputDecoration(
              labelStyle: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:22.0),
              labelText: 'Input',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (String inp){new_class=inp;},
          ),
          Padding(padding:EdgeInsets.all(12.0)),
          Row(
            children: [
              Padding(padding:EdgeInsets.symmetric(horizontal: 16.0)),
              FlatButton(
                child: Text('加入队列',
                style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:22.0)),
                onPressed: (){pushQueue(new_class);},
              ),
              Padding(padding:EdgeInsets.symmetric(horizontal: 20.0)),
              FlatButton(
                child: Text('发书完成',
                style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:22.0)),
                onPressed: (){popQueue();},
              ),
            ],
          ),
        ],
    ),
    ),
    );
  }
}

