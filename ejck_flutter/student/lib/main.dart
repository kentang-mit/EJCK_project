import 'package:flutter/material.dart';
import 'booklist.dart';
import 'notification.dart';
import 'package:share/share.dart';
import 'storage.dart';
import 'dart:async';
import 'dart:convert';
import 'sjtu_auth.dart' as sjtua;
import 'const.dart';
import 'themes.dart';
import 'queue.dart';

void main() => runApp(new MyApp());

const Color _kFlutterBlue = const Color(0xFF003D75);

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

  int _currentIndex = 0;
  var titles = const ["回到主页","信息交流","查看教材","排队领书"];
  Widget build(BuildContext context) {
  return new Scaffold(
    appBar: AppBar(
      title: new Text(titles[_currentIndex]),
      //backgroundColor: _kFlutterBlue,
      ),
    body: new Stack(
      children: <Widget>[
        new Offstage(
          offstage: _currentIndex != 0,
          child: new TickerMode(
            enabled: _currentIndex == 0,
            child: new MaterialApp(
              theme: kDarkGalleryTheme.data,
              home:
                Scaffold(
                  body: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(16.0),),
                      Center(
                        child: Text('欢迎来到教材助手！',
                        style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:24.0)),
                      ),
                      Padding(padding: EdgeInsets.all(32.0),),
                      Row(
                        children:[
                            Padding(padding: EdgeInsets.all(25.0)),
                            FlatButton(child:
                            Column( 
                              children:[
                                Icon(
                                  Icons.home,
                                  size: 80.0,
                                ),
                                Text(
                                  '回到主页',
                                  style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:20.0)
                                ),
                              ]
                            ),
                            onPressed: (){
                            },
                            ),

                          Padding(padding: EdgeInsets.all(25.0)),
                            FlatButton(child:
                            Column( 
                              children:[
                                Icon(
                                  Icons.info,
                                  size: 80.0,
                                ),
                                Text(
                                  '信息交流',
                                  style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:20.0)
                                ),
                              ]
                            ),
                            onPressed: (){
                              _currentIndex = 1;
                              setState((){});
                            },
                            ),

                        ]
                      ),
                      Padding(padding: EdgeInsets.all(40.0),),
                      Row(
                        children:[
                            Padding(padding: EdgeInsets.all(25.0)),
                            FlatButton(child:
                            Column( 
                              children:[
                                Icon(
                                  Icons.search,
                                  size: 80.0,
                                ),
                                Text(
                                  '查看教材',
                                  style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:20.0)
                                ),
                              ]
                            ),
                            onPressed: (){
                              _currentIndex = 2;
                              setState((){});
                            },
                            ),

                          Padding(padding: EdgeInsets.all(25.0)),
                            FlatButton(child:
                            Column( 
                              children:[
                                Icon(
                                  Icons.alarm,
                                  size: 80.0,
                                ),
                                Text(
                                  '排队领书',
                                  style: kDarkGalleryTheme.data.textTheme.title.copyWith(color:Colors.white,fontSize:20.0)
                                ),
                              ]
                            ),
                            onPressed: (){
                              _currentIndex = 3;
                              setState((){});
                            }, 
                          ),  
                        ]),
                      ],
                    ),
                )
              )
          ),
        ),
        new Offstage(
          offstage: _currentIndex != 1,
          child: new TickerMode(
            enabled: _currentIndex == 1,
            child: new MaterialApp(home: Notilist(),)
          ),
        ),
        new Offstage(
          offstage: _currentIndex != 2,
          child: new TickerMode(
            enabled: _currentIndex == 2,
            child: new MaterialApp(home: Booklist(),)
          ),
        ),
        new Offstage(
          offstage: _currentIndex != 3,
          child: new TickerMode(
            enabled: _currentIndex == 3,
            child: new MaterialApp(home: BookQueue(),)
          ),
        ),
      ],
    ),
    bottomNavigationBar: new BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (int index) { 
        setState((){ this._currentIndex = index; }); 
        },
      items: <BottomNavigationBarItem>[
        new BottomNavigationBarItem(
          icon: new Icon(Icons.home),
          title: new Text("回到主页"),
        ),
        new BottomNavigationBarItem(
          icon: new Icon(Icons.info),
          title: new Text("信息交流"),
        ),
        new BottomNavigationBarItem(
          icon: new Icon(Icons.search),
          title: new Text("查看教材"),
        ),
        new BottomNavigationBarItem(
          icon: new Icon(Icons.alarm),
          title: new Text("排队领书"),
        ),
      ],
    ),
    drawer: new DrawerPage(),
    );
  }
}

class DrawerPage extends StatefulWidget {
  @override
  DrawerInst createState() => new DrawerInst();
}


class  DrawerInst extends State<DrawerPage> {
  @override
  String ClassNum;
  Widget build(BuildContext context)  {
   
    return new Drawer(

        child: new ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            new DrawerHeader(
              child: new FutureBuilder<Storage>(
                future: fetchStorage(),
                builder: (context,snapshot){
                  if (snapshot.hasData) {
                    return new Text(
                      snapshot.data.classnum,
                      style: Theme.of(context).textTheme.title
                    );
                  } else{
                    return new Text(
                      "请稍等……"
                    );
                  }
                },
                ),
              decoration: new BoxDecoration(
                color: _kFlutterBlue,
              ),
            ),
            new ListTile(
              title: new Text(
                'jAccount登陆',
                style:Theme.of(context).textTheme.subhead
                ),
              onTap: () {
                Navigator.pop(context);
                String appId = constants.APP_ID;
                String appSecret = constants.APP_SECRET;
                sjtua.getToken(appId, appSecret).then((token)
                {
                  setToken(token.access);
                  print(token.access);
                });
              },
            ),
            new ExpansionTile(
              title: new Text("设置班级",style:Theme.of(context).textTheme.subhead),
              children: <Widget> [
                new Classnumbox(),
              ]

            ),
            new ListTile(
              title: new Text('分享选书链接',style:Theme.of(context).textTheme.subhead),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Share.share('请选择教材 https://example.com');
                Navigator.pop(context);
              },
            ),
            
          ],
        ),
      );
  }
}


class Classnumbox extends StatefulWidget {
  @override
  createState() => new ClassnumboxState();
}
class ClassnumboxState extends State<Classnumbox> { 
  final TextEditingController _textController = new TextEditingController();
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget> [
        new Flexible(
          child: new TextField(
            controller: _textController,
            onSubmitted: _handleSubmitted,
            decoration: new InputDecoration.collapsed(hintText: '新班级号如F1603022'),
          )
        ),
        new Container(
          margin: new EdgeInsets.symmetric(horizontal: 4.0),
          child: new IconButton(
            icon: new Icon(Icons.confirmation_number),
            onPressed: () => _handleSubmitted(_textController.text)
          ),
        )
      ]
    );
  }
  void _handleSubmitted(String text) {
    setClassnum(_textController.text);
    Navigator.pop(context);
  }
}