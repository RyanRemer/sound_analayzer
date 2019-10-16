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
      home: RecorderPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class RecorderPage extends StatefulWidget {
  RecorderPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RecorderPageState createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  FlutterSound flutterSound = new FlutterSound();
  Stream _dbPeakStream;

  /// get a sample every [sampleRate] seconds
  final double sampleRate = 0.6;
  final bool saveFile = false;

  /// builds a simple interface with the following parts
  /// [StreamBuilder] streams the current amplitude and displays a text representation
  /// [IconButton] a microphone icon that toggles if the microphone is recording
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: _dbPeakStream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                double test = 0.0;
                if (snapshot.hasError)
                  return Text(
                    snapshot.error,
                    style: TextStyle(color: Colors.red),
                  );
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text("0 db");
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return Text(snapshot.data.toStringAsFixed(3) + " db");
                  default:
                    return Text("");
                }
              },
            ),
            IconButton(
                icon: Icon(
                  Icons.mic,
                ),
                iconSize: 48.0,
                onPressed: () {
                  if (flutterSound.isRecording) {
                    stopRecording();
                  } else {
                    startRecording();
                  }
                }),
          ],
        ),
      ),
    );
  }

  /// Starts recording from the device's microphone
  /// [flutterSound] is a library that allows us to listen to sample the dB levels
  /// [RecorderWav] is a libaray that allows us to start recording the microphone to save into a wave file
  Future startRecording() async {
    await flutterSound.startRecorder(null);
    flutterSound.setDbLevelEnabled(true);
    flutterSound.setDbPeakLevelUpdate(sampleRate);
    setState(() {
      _dbPeakStream = flutterSound.onRecorderDbPeakChanged;
    });

    RecorderWav.startRecorder();
  }

  /// Stops recording from the device's microphone
  /// [flutterSound] is a library to measure the current
  /// [RecorderWav]
  Future stopRecording() async {
    flutterSound.stopRecorder();
    setState(() {
      _dbPeakStream = null;
    });

    String filepath = await RecorderWav.StopRecorder();
    if (saveFile) {
      print("Filepath: " + filepath);
    } else {
      RecorderWav.removeRecorderFile(filepath);
    }
  }

  /// force [flutterSound] to unsubscribe
  @override
  void dispose() {
    flutterSound.stopRecorder();
    super.dispose();
  }
}
