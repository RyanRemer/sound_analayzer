import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:recorder_wav/recorder_wav.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSound flutterSound = new FlutterSound();
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _recorderSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Text("Start Recording"),
            onPressed: () async {
              RecorderWav();
              String result = await flutterSound.startRecorder(null);
              flutterSound.setDbLevelEnabled(true);
              flutterSound.setDbPeakLevelUpdate(0.1);

              RecorderWav.startRecorder();

              print("Recording to: " + result);
              _dbPeakSubscription =
                  flutterSound.onRecorderDbPeakChanged.listen((double value) {
                print(value);
              });
            },
          ),
          RaisedButton(
            child: Text("Stop Recording"),
            onPressed: () async {
              String result = await flutterSound.stopRecorder();
              String wavFile = await RecorderWav.StopRecorder();

              print("Filepath: " + wavFile);

              print("Stopped: " + result);

              if (_recorderSubscription != null) {
                _recorderSubscription.cancel();
                _recorderSubscription = null;
              }
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterSound.stopRecorder();
    super.dispose();
  }
}
