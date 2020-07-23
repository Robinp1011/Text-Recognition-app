import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'userInfo.dart';
import 'output.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;

  bool isImageLoaded = false;





  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
    readText();
  }

  Future pickCamImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
    readText();
  }



  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    List<String> output = [];



    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
           output.add(line.text);
      }
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => outputPage(output, pickedImage)));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child:Column(
            children: <Widget>[

              new SizedBox(
                height: MediaQuery.of(context).size.height/15,
              ),
              Image.asset("assets/images/logo.jpeg", width: 75, height: 75,),

              new SizedBox(
                height: MediaQuery.of(context).size.height/4.8,
              ),
              GestureDetector(
                child: Container(


                  decoration:BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle
                  )  ,
                  // alignment: Alignment.bottomCenter,
                    height: 200,
                     width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[


                        FittedBox(child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Image.asset("assets/images/camera.png", width: MediaQuery.of(context).size.width/1.18, height: MediaQuery.of(context).size.height/3
                            ,color:  Colors.white,),
                        ),
                          fit: BoxFit.contain,
                        ),
                    ],
                  ),
                ),
                onTap: ()
                {
                  pickCamImage();
                },

              ),

              new SizedBox(
                height:  MediaQuery.of(context).size.height/14,
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.shade200,
                              offset: Offset(2, 4),
                              blurRadius: 5,
                              spreadRadius: 2)
                        ],
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.lightBlue[300], Colors.lightBlue[700]])),
                    child: Text(
                      'History',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),

                  onTap: ()
                  {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => outputPage2()));
                  },
                ),
              ),


            ],
          ),
        ));
  }
}


class outputPage extends StatefulWidget {
  @override

  List<String> output;
  File pickedImage;
  outputPage(List<String> output, File pickedImage)
  {
    this.output = output;
    this.pickedImage = pickedImage;
  }
  _outputPageState createState() => _outputPageState();
}

class _outputPageState extends State<outputPage> {
  @override
  String speakable;
  bool isVisible = true;
  final FlutterTts flutterTts = FlutterTts();

  String myimage;
  Random rando = new Random();
  String downloadUrl;
  // File sampleImage;

  DateTime _dateTime = DateTime.parse("${DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()} 00:00:00");

  speak(String str) async
  {
    setState(() {
      isVisible = false;
    });
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(str);
  }

  void initState()
  {
    super.initState();

    mid();
  }

  stopSpeaker() async
  {

    setState(() {
      isVisible = true;
    });
    await flutterTts.stop();
  }

  mid()
  {

    var kontan = StringBuffer();
    widget.output.forEach((item){
      kontan.writeln(item);
    });
    speakable = kontan.toString();
    speak(speakable);
    addImage();
  }


  Future addImage()  async
  {
    myimage = rando.nextInt(10000).toString();
    final StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child(myimage);

    downloadUrl="https://firebasestorage.googleapis.com/v0/b/las-prod-1.appspot.com/o/${myimage}?alt=media";
    final StorageUploadTask task =
    firebaseStorageRef.putFile(widget.pickedImage);



    setData();

  }

  setData()
  {

    //   print(userLocation);
    print("aaya");
    UserInfo user = new UserInfo(downloadUrl,speakable, _dateTime);


    try {
      print("employee ky ander");
      Firestore.instance
          .collection("tyremrf")
          .document("hVCGeC3hDCOoK3472PWi").collection("info").document()
          .setData(user.toJson());


    } catch (e) {
      print(e.toString());
    }

  }



  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            children: <Widget>[
              new SizedBox(
                height: MediaQuery.of(context).size.height/30,
              ),

              Container(
                  height: MediaQuery.of(context).size.height/2.4,
                  width: MediaQuery.of(context).size.width/1.5,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(widget.pickedImage), fit: BoxFit.cover))),

          SizedBox(
            height: 10,
          ),


          Container(
            height: MediaQuery.of(context).size.height/2.2,
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: widget.output.length,

                itemBuilder: (_, index)
                {
                  return  Center(child: new Text(widget.output[index]));

                }
            ),
          ),


              IconButton(
                icon: Icon(
                 isVisible?  Icons.volume_up: Icons.stop, size: 30,
                ),
                color: Colors.blue,
                onPressed: () {
                  if(isVisible)
                    {
                      mid();
                    }
                  else
                    {
                      stopSpeaker();
                    }
                },
              ),

         /*     RaisedButton(
                child: Text('Speak'),
                onPressed: ()
                {
                  mid();
                },
              ),        */
            ],
          ),
        ),
      ),
    );
  }
}
