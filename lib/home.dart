import 'dart:io';
import 'dart:ui';
// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';


Map<String,int> imageCount={};
class Home extends StatefulWidget{
  @override
  HomeState createState() {
  return HomeState();
  }

}

class HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Directory d=new Directory("/");
    d.list(recursive: true).listen(
        (event) async {
          var path = event.path;
          if ((path.endsWith(".jpg") ||
              path.endsWith(".png") ||
              path.endsWith(".jpeg") ||
              path.endsWith(".bmp") ||
              path.endsWith(".ico"))) {
            int t = path.lastIndexOf("/");
            if (t >= 0) {
              if (path.substring(t + 1).startsWith(".")) return;
            }
            final File file = new File(path);
            if (file.existsSync()) {
              var key = getFileName(file.parent);
              if (imageCount.containsKey(key)) {
                imageCount[key] = imageCount[key]! + 1;
              }
              else
                imageCount[key] = 1;

              setState(() {

              });
            }
            }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    var directories=imageCount.keys.toList();
    return Scaffold(
       appBar: AppBar(
         title: Text("Choose Image Folder"),
       ),
        body: Container(
      color: Color(0xff494949),
      child: ListView.builder(itemBuilder: (context,i){
        return Container(
          decoration: BoxDecoration(
            color: Color(0xff2f2f2f),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(directories[i],style: TextStyle(
                color: Colors.white,
                  fontSize: 23,
                  fontFamily: "arial"
                ),

                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(" ${imageCount[directories[i]]} photos",style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontFamily: "arial"
                ),
              )
              )
            ],
          ),
        );
      },
      itemCount: directories.length,
      ),
    )
        ,
      )
    ;
  }

}

String getFileName(var file) => file.path.substring(file.path.lastIndexOf("/")+1);