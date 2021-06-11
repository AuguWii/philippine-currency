import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class ClassifyV1 extends StatefulWidget {
  const ClassifyV1({Key? key}) : super(key: key);

  @override
  _ClassifyV1State createState() => _ClassifyV1State();
}

class _ClassifyV1State extends State<ClassifyV1> {
  FlutterTts flutterTts = FlutterTts();
  File? _image;
  final picker = ImagePicker();

  bool _outputLoaded = false;
  bool _outputTTS = false;
  String result = '';
  String _name = "";
  late ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    loadModelFiles();
  }

  //TO-DO load model files
  //--------------------------------------------
  loadModelFiles() async {
    Tflite.close();
    String? res = await Tflite.loadModel(
        model: "assets/lite_model_87.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
    print(res);
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        doImageClassification();
      } else {
        print('No image selected.');
      }
    });
  }

  //run inference and show results
  doImageClassification() async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
        path: _image!.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // 255.0  defaults to 1.0
        numResults: 1, // defaults to 5
        threshold: 2.5, // defaults to 0.1
        asynch: true // defaults to true
        );
    print(recognitions!.length.toString());

    setState(() {
      result = "";
      _outputLoaded = false;
      _outputTTS = false;
    });
    int endTime = DateTime.now().millisecondsSinceEpoch;

    print("Inference took ${endTime - startTime}ms");
    for (var output in recognitions) {
      setState(() {
        print(output.toString());
        _name = output["label"];
        result += output["label"] +
            " " +
            (output["confidence"] as double).toStringAsFixed(2) +
            "\n";

        _outputLoaded = true;
        _outputTTS = true;
      });
    }
  }

  @override
  void dispose() {
    //TO DO: implement dispose
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0.0,
        title: const Text(
          'Philippine Currency',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 2,
            wordSpacing: 2,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: MediaQuery.of(context).size.height * .80,
              width: MediaQuery.of(context).size.width,
              child: _image != null
                  ? GestureDetector(
                      onDoubleTap: () => getImage(),
                      child: Column(
                        children: [
                          Image.file(_image!),
                          // Center(
                          //   child: _outputTTS ? outputTTS() : outputTTSerror(),
                          // ),
                          _outputLoaded
                              ? Text(
                                  ' $_name ',
                                  style: const TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              : const Text(
                                  'Can\'t recognize the image. Try again.',
                                  style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onDoubleTap: () => getImage(),
                      child: Container(
                        color: Colors.amber.shade400,
                        child: const Center(
                          child: Text(
                            'Double Tap the Screen to Capture an Image',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 70.0, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        color: Colors.grey.shade400,
        height: MediaQuery.of(context).size.height * 0.08,
        width: MediaQuery.of(context).size.width,
        child: IconButton(
          icon: const Icon(
            Icons.camera_alt_outlined,
            size: 50,
          ),
          onPressed: () => getImage(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  outputTTS() {
    flutterTts.speak('You have $_name');
    flutterTts.setSpeechRate(0.8);
  }

  outputTTSerror() {
    flutterTts.speak('Can not recognize the image. Try Again');
    flutterTts.setSpeechRate(0.8);
  }
}
