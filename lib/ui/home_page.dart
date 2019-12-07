

import 'dart:collection';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import '../images.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Queue<File> _imageQueue = new Queue<File>();
  Queue<List<String>> _labelsQueue = new Queue<List<String>>();

  File _image;
  List<String> _labels = <String>[];

  @override
  void initState() {
    super.initState();

    (() async {
      final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();

      await for (File photo in getAllPhotos()) {
        FirebaseVisionImage fbPhoto = FirebaseVisionImage.fromFile(photo);
        List<ImageLabel> labels = await labeler.processImage(fbPhoto);

        _labelsQueue.addFirst(labels.map((label) => label.text).toList());
        _imageQueue.addFirst(photo);
      }
    })();
  }

  _addImage() {
    if (_imageQueue.length > 0) {
      setState(() {
        _image = _imageQueue.removeLast();
        _labels = _labelsQueue.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the HomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      
      body:
        _image == null ?
          Center(
            child: const Text("Hit that button!")
            ) :
          Stack(
            children: <Widget>[
              Center(
                child: Image.file(_image),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 1.0, // gap between lines
                  children:
                    _labels
                      .map((label) => Chip(
                        elevation: 5.0,
                        label: Text(label)
                      ))
                      .toList(),
                )
              )
            ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        tooltip: 'Images',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
