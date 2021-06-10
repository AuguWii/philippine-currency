import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class ClassifyV1 extends StatefulWidget {
  const ClassifyV1({Key? key}) : super(key: key);

  @override
  _ClassifyV1State createState() => _ClassifyV1State();
}

class _ClassifyV1State extends State<ClassifyV1> {
  //FlutterTts flutterTts = FlutterTts();
  File? _image;
  final picker = ImagePicker();

  bool outputLoaded = false;
  String result = '';
  String _name = "";
  late ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    loadModelFiles();
  }

  //TO-DO load model files
  loadModelFiles() async {
    Tflite.close();
    //String?
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

  //run inference and show results
  doImageClassification() async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
        path: _image!.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // 255.0  defaults to 1.0
        numResults: 1, // defaults to 5
        threshold: 0.3, // defaults to 0.1
        asynch: true // defaults to true
        );
    print(recognitions!.length.toString());

    setState(() {
      result = "";
    });
    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");

    for (var re in recognitions) {
      setState(() {
        outputLoaded = true;
        print(re.toString());
        _name = re["label"];
        result += re["label"] +
            " " +
            (re["confidence"] as double).toStringAsFixed(2) +
            "\n";
      });
    }
  }

  //load|capture an image from camera
  // _imgFromCamera() async {
  //   PickedFile? pickedFile =
  //       await imagePicker.getImage(source: ImageSource.camera);
  //   _image = File(pickedFile!.path);

  //   setState(() {
  //     _image;
  //     imageLoaded = true;
  //     doImageClassification();
  //   });
  // }

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

  // _imgFromGallery() async {
  //   PickedFile pickedFile =
  //   await imagePicker.getImage(source: ImageSource.gallery);
  //   _image = File(pickedFile.path);
  //   setState(() {
  //     _image;
  //     doImageClassification();
  //   });
  // }

  @override
  void dispose() {
    //TO DO: implement dispose
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0.0,
        title: const Text(
          'Philippine Currency',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 2,
            wordSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: MediaQuery.of(context).size.height * .65,
              width: MediaQuery.of(context).size.width,
              child: _image != null
                  ? GestureDetector(
                      onDoubleTap: () => getImage(),
                      child: Image.file(_image!),
                    )
                  : GestureDetector(
                      onDoubleTap: () => getImage(),
                      child: Container(
                        color: Colors.amber,
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
          const SizedBox(
            height: 5.0,
          ),
          Text(
            'Currency: $_name',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            color: Colors.grey,
            child: const Icon(
              CupertinoIcons.photo_camera,
              size: 70,
            ),
          )
        ],
      ),
    );
  }
}
