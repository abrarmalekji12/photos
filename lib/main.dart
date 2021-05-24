// @dart=2.9
import 'dart:io';

// import 'package:firebase_ml_vision/firebase_ml_vision.dart' ;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// import 'package:mlkit/mlkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photos/home.dart';

List<String> imagePaths = [];
GlobalKey dismissKey = GlobalKey();
List<DateTime> dateTimeList = [];
Map<String, ImageCategory> categories = {};
Map<String, GestureDetector> images = {};
Map<String, List<String>> datetime = {};
double width, height;
const months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "June",
  "July",
  "Aug",
  "Sept",
  "Oct",
  "Nov",
  "Dec",
];
const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
int processed=0;
bool clicked = false;
File clickedImage;
AnimationController animationController;
int animPer = 0;
bool clickedStarted = false;
bool loaded = false;

int processing=0;

List<File> remaining=[];

final num maxLimit=5;
void main() => runApp(new MaterialApp(
  routes: {
'/' : (context) => Home(),
    'show':(context)=> MyApp()
},
));

class ImageCategory {
  int type, numOfFaces;

  ImageCategory(this.type, this.numOfFaces);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Gallery',
        key: GlobalKey(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // FirebaseVisionFaceDetector   faceDetector;
  // FirebaseVisionTextDetector textDetector;
  FaceDetector faceDetector;
  TextRecognizer textRecognizer;
  MethodChannel channel;

  // VisionFaceDetectorOptions options;


  @override
  void initState() {
    super.initState();
// channel=new MethodChannel("file");
    if (!loaded) {
      FaceDetectorOptions options = FaceDetectorOptions(
          enableClassification: true,
          enableContours: false,
          mode: FaceDetectorMode.accurate,
          minFaceSize:0.3,
          enableLandmarks: false,
          enableTracking: false);
      faceDetector = FirebaseVision.instance.faceDetector(options);
      // options=VisionFaceDetectorOptions(landmarkType: VisionFaceDetectorLandmark.None,classificationType: VisionFaceDetectorClassification.None,isTrackingEnabled: false,modeType: VisionFaceDetectorMode.Accurate);
      // faceDetector=FirebaseVisionFaceDetector.instance;
      // textDetector=FirebaseVisionTextDetector.instance;
      textRecognizer = FirebaseVision.instance.textRecognizer();
      animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 40), value: 1.0);
      animationController.addListener(() {
        setState(() {});
      });
      Future(() => loadImages());
    }
  }

  Future<void> loadImages() async {
    print("loading");
    loaded = true;
    // Map<dynamic,dynamic> images= await FlutterGallaryPlugin.getAllImages;
    // setState(() {
    //   this.allImage = images['URIList'] as List;
    //   this.allNameList = images['DISPLAY_NAME'] as List;
    // });
    if (!await Permission.storage.isGranted) {
      var pr = await Permission.storage.request();
      if (!pr.isGranted) return;
    }
    Directory d = Directory("/storage/emulated/0/WhatsApp/Media/WhatsApp Images/");//Pictures/
    // for(var d in dlist)
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
            FileImage fileImage = FileImage(file);
            if (fileImage.file.existsSync()) {
              categories[path] = ImageCategory(-1, -1);

              // final visionImage=FirebaseVisionImage.fromFile(file);

              // final  metadata=FirebaseVisionImageMetadata();
              // faceDetector.detectFromBinary(value)
              // final value = await faceDetector.detectFromPath(file.path, options);

              Image img = Image(
                image: fileImage,
                alignment: Alignment.center,
                filterQuality: FilterQuality.low,
                fit: BoxFit.cover,
                width: dw(24),
                height: dw(24),
              );

              setState(() {
                // var tempKey = GlobalKey();
                GestureDetector container = GestureDetector(
                    onTap: () {
                      // setState(() {
                      //   clickedImage=file;
                      //   animPer=0;
                      //   clicked=true;
                      //   clickedStarted=false;
                      // });
                      clickedImage = file;
                      //   animPer=0;
                      clicked = true;
                      animationController.forward(from: 28.0 / 100.0);
                    },
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        child: img,
                        clipBehavior: Clip.hardEdge,
                      ),
                      color: Color(0xff2f2f2f),
                      width: dw(24.5),
                      height: dw(24.5),
                      alignment: Alignment.center,
                    ));
                DateTime dateTime = file.lastModifiedSync();
                String key =
                    "${dateTime.day}-${dateTime.month}-${dateTime.year}";
                images[path] = container;
                if (!datetime.containsKey(key)) {
                  datetime[key] = [path];
                  var index = -1;
                  for (int i = 0; i < dateTimeList.length; i++) {
                    if (dateTimeList[i].isBefore(dateTime)) {
                      index = i;
                      break;
                    }
                  }
                  if (index != -1) {
                    dateTimeList.insert(index, dateTime);
                  }
                    else
                    dateTimeList.add(dateTime);
                } else {
                  datetime[key].add(path);
                }
                imagePaths.add(file.path);
              });
doDetectionWork(file);
              //   channel.invokeMethod("getCat",)
            }
          }
        }
      },
            onDone: () {
      },
      onError: (error) {
        print("error ${error.toString()}");
      },
      cancelOnError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    //  if(!clickedStarted) {
    //    animationController.forward(from: 28.0/100.0);
    // clickedStarted=true;
    //  }

    Container container = Container(
      child: ListView.builder(
          itemCount: dateTimeList.length,
          itemBuilder: (context, i) {

            DateTime dateTime = dateTimeList[i];
            List<GestureDetector> oneFace = [],
                groupFace = [],
                docs = [],
            smiley=[],
                other = [],
            searching=[]
            ;
            var time = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
            for (var dt in datetime[time]) {
              final c = categories[dt];
              if (c.type == 1) {
                smiley.add(images[dt]);
              }
              else if (c.type == 2) {
                if (c.numOfFaces == 1)
                  oneFace.add(images[dt]);
                else
                  groupFace.add(images[dt]);
              } else if (c.type == 3)
                docs.add(images[dt]);
              else if (c.type == 4)
                other.add(images[dt]);
              else {
                searching.add(images[dt]);
                doDetectionWork(File(dt));
              }
              }
            List<Widget> widgets = [];
            final labels = ["Smiley Portrait","Portrait", "Group", "Documents", "Other","Searching"];
            int j = 0;
            for (var cat in [smiley,oneFace, groupFace, docs, other,searching]) {
              if (cat.isNotEmpty) {
                // if(widgets.isNotEmpty)
                widgets.add(Divider(
                  height: 2,
                  color: Colors.white,
                ));
                widgets.add(Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      labels[j],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: "arial"),
                    ),
                  ),
                ));
                widgets.add(_buildGrid(cat));
              }
              j++;
            }
            return Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "${days[dateTimeList[i].weekday - 1]}, ${dateTimeList[i].day} ${months[dateTimeList[i].month - 1]}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: "arial",
                            fontWeight: FontWeight.w600)),
                  ),
                  Column(
                    children: widgets,
                  ),
                ],
              ),
            );
          }),
      color: Color(0xff221F1F),
    );
    Scaffold scaffold = Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Color(0xff2f2f2f),
        ),
        body: clicked
            ? Dismissible(
                direction: DismissDirection.down,
                resizeDuration: Duration(seconds: 0),
                movementDuration: Duration(milliseconds: 0),
                confirmDismiss: (bool) async {
                  setState(() {
                    clicked = false;
                  });
                  return true;
                },
                onDismissed: (dis) {},
                background: container,
                child: ScaleTransition(
                    scale: CurvedAnimation(
                        curve: Curves.bounceOut, parent: animationController),
                    child: Container(
                      width: dw(100),
                      height: dh(100),
                      color: Color(0xff2f2f2f),
                      child: Image.file(
                        clickedImage,
                        width: dw(100),
                        height: dh(100),
                        fit: BoxFit.cover,
                      ),
                    )),
                key: dismissKey,
              )
            : container);
    return scaffold;
  }

  Widget _buildGrid(List<GestureDetector> detector) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: true,
      shrinkWrap: true,
      padding: const EdgeInsets.all(4.0),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: detector.length,
      itemBuilder: (context, i) => detector[i],
    );
  }

  double dw(double per) => width * per / 100.0;

  double dh(double per) => height * per / 100.0;

 void  doDetectionWork(File file)  {
   if(categories[file.path].type!=-1)
     return;
   categories[file.path].type=0;
   if(processing>maxLimit) {
     remaining.add(file);
     return;
   }
   processing++;
    // print('happening');
    //
    // fimg.Image ifile=fimg.decodeImage(bytes);
    // if(ifile.width<50||ifile.height<50)
    // return;
    //await decodeImageFromList(value)
    //   final bytes = await file.readAsBytes();
    // fimg.Image fimage=fimg.decodeImage(bytes);
   // var meta= FirebaseVisionImageMetadata(size: Size(fimage.width.toDouble(),fimage.height.toDouble()));
   //    final visionImage = FirebaseVisionImage.fromBytes(bytes,meta);
      final visionImage=FirebaseVisionImage.fromFile(file);
      // final  metadata=FirebaseVisionImageMetadata();
      // faceDetector.detectFromBinary(value)
      // final value = await faceDetector.detectFromPath(file.path, options);
      if(visionImage!=null) {
        faceDetector.processImage(visionImage).then((value) {
          processing--;
          processed++;
          print('processed $processed');
          if (value !=null) {
            if (value.length >= 1) {
            setState(() {
              print('done ${file.path}  ${value[0].smilingProbability}');
              if (value.length==1&&value[0].smilingProbability != null &&
                  value[0].smilingProbability > 0.5)
                categories[file.path] = ImageCategory(1, value.length);
              else {
                categories[file.path] = ImageCategory(2, value.length);
              }
            });
            } else {

              // final detectedText= await textDetector.detectFromPath(file.path);
              //  if(detectedText!=null){
              // int tl=0;
              //    for(var a in detectedText)
              //   tl+=a.text.length;
              //       if(tl>30) {
              //         categories[file.path] = ImageCategory(2, tl);
              //         SchedulerBinding.instance.addPostFrameCallback((_) {
              //           setState(() {});
              //         });
              //       }
              //      }
              textRecognizer.processImage(visionImage).then((value) {

                setState(() {
                  if (value.text != null && value.text.length > 30) {
                    categories[file.path] =
                        ImageCategory(3, value.text.length);
                  }
                  else{
                    categories[file.path] = ImageCategory(4, -1);
                  }
                });
                // SchedulerBinding.instance.addPostFrameCallback((_) {
                //   setState(() {});
                // });
              }).onError((error, stackTrace) {
                setState(() {
                  categories[file.path] = ImageCategory(4, -1);
                });
              });
            }
          }

          while(processing<=maxLimit&&remaining.isNotEmpty)
            doDetectionWork(remaining.removeLast());
        })
            .onError((error, stackTrace) {
          processing--;
          setState(() {
              categories[file.path] = ImageCategory(4, -1);
          });
          while(processing<=maxLimit&&remaining.isNotEmpty)
            doDetectionWork(remaining.removeLast());
        });
      }
      else{
        setState(() {
          categories[file.path] = ImageCategory(4, -1);
        });
      }
  }
}
