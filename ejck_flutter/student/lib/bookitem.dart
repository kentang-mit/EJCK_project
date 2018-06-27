import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'bookdetail.dart';

final _rowHeight = 100.0;
final _borderRadius = BorderRadius.circular(_rowHeight / 2);

class BookItem extends StatelessWidget{
  final String name;
  final int totalNum;
  final String authors;
  final String course;
  final int edition;
  final String publisher;
  final double price;

  const BookItem({
    @required this.name,
    @required this.totalNum,
    @required this.authors,
    @required this.course,
    @required this.edition,
    @required this.publisher,
    @required this.price,
  });

  void _navigateToDetail(context){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context){
        return Scaffold(
         
          body: BookDetail(
            name: name,
            totalNum: totalNum,
            authors: authors,
            publisher: publisher,
            edition: edition,
            price: price,

          ),
        );
      } 
      )
    );
  }
  @override
  Widget build(BuildContext context){
    return Material(
      color: Colors.transparent,
      child: Container(
        height: _rowHeight,
        child: InkWell(
          borderRadius: _borderRadius,
          highlightColor: Colors.blue,
          splashColor: Colors.blue,
          onTap: (){
            _navigateToDetail(context);
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.book,
                  ),
                ),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:[
                      Text(
                        (name.length>8?name.substring(0,8)+'...':name)+'\n'+'总数：$totalNum本',
                        style: Theme.of(context).textTheme.title,
                        overflow: TextOverflow.fade,
                    ),],
                  ),
                ),
                
              ]
              ),
            ),
          ),
      ),
    );
  }
}