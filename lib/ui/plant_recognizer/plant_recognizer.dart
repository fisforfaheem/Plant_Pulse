import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:plantpulse/app_theme.dart';
import 'package:plantpulse/ui/plant_recognizer/classifier/classifier.dart';

const _labelsFileName = 'assets/dict.txt';
const _modelFileName = 'model.tflite';

class PlantRecognizer extends StatefulWidget {
  const PlantRecognizer({super.key, required String pageTitle});

  @override
  State<PlantRecognizer> createState() => _PlantRecognizerState();
}

enum _ResultStatus {
  notStarted,
  notFound,
  found,
}

class _PlantRecognizerState extends State<PlantRecognizer> {
  bool _isAnalyzing = false;
  final picker = ImagePicker();
  File? _selectedImageFile;

  // Result
  _ResultStatus _resultStatus = _ResultStatus.notStarted;
  String _plantLabel = ''; // Name of Error Message
  double _accuracy = 0.0;

  late Classifier _classifier;

  @override
  void initState() {
    super.initState();
    _loadClassifier();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadClassifier() async {
    final classifier = await Classifier.loadWith(
      labelsFileName: _labelsFileName,
      modelFileName: _modelFileName,
    );
    _classifier = classifier!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Spacer(),
            Container(
              height: 224.0,
              width: MediaQuery.of(context).size.width * .75,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.appTheme.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
              ),
              child: Center(
                child: _selectedImageFile == null
                    ? Text(
                        'No image selected',
                        textAlign: TextAlign.center,
                        style: AppTheme.appTheme.textTheme.bodyMedium,
                      )
                    : Image.file(
                        _selectedImageFile!,
                        height: 224.0,
                        width: 225.0,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            Container(
              height: 90.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildButton(
                      Icon(Icons.add_a_photo_outlined), () => _onPickPhoto(ImageSource.camera)),
                  _buildButton(Icon(Icons.image_outlined), () => _onPickPhoto(ImageSource.gallery)),
                  _buildButton(
                    Icon(Icons.image_not_supported_outlined),
                    () => setState(() => _selectedImageFile = null),
                  ),
                ],
              ),
            ),
            Container(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 23.0,
                      right: 23.0,
                      top: 15.0,
                      bottom: 18.0,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0XFFFFF176),
                                const Color(0XFF69F0AE),
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topRight: Radius.circular(68.0),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AppTheme.appTheme.canvasColor.withOpacity(0.6),
                                offset: Offset(1.1, 1.1),
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 16.0,
                              bottom: 16.0,
                              left: 16.0,
                              right: 16.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * .70,
                                  child: Text(_plantLabel,
                                      textAlign: TextAlign.left,
                                      style: AppTheme.appTheme.textTheme.titleLarge),
                                ),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.9,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(18),
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6.0,
                                            left: 6.0,
                                            top: 12,
                                            bottom: 12,
                                          ),
                                          child: Text(
                                            'Confidence: ${_accuracy.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              letterSpacing: 0.18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: FractionallySizedBox(
                                    widthFactor: 0.8,
                                    child: Text("Action will be here",
                                        textAlign: TextAlign.left,
                                        style: AppTheme.appTheme.textTheme.titleLarge!
                                            .copyWith(color: Theme.of(context).canvasColor)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    right: 20.0,
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: 0.9,
                                    child: Text(
                                      'Treatment will be here',
                                      textAlign: TextAlign.left,
                                      style: AppTheme.appTheme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    right: 17.5,
                    height: 80,
                    width: 80,
                    child: Image.asset('assets/images/treatment.png'),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(Icon icon, VoidCallback callback) {
    return ClipOval(
      child: Material(
        color: Colors.white,
        child: InkWell(
          splashColor: Colors.lightGreenAccent[100],
          child: SizedBox(
            width: 56,
            height: 56,
            child: icon,
          ),
          onTap: callback,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Plant Identifier',
      style: AppTheme.appTheme.textTheme.titleLarge!.copyWith(color: Colors.orangeAccent),
      textAlign: TextAlign.center,
    );
  }

  void _onPickPhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);
    _selectedImageFile = imageFile;

    _analyzeImage(imageFile);
  }

  void _analyzeImage(File image) {
    _plantLabel = '';
    _accuracy = 0;
    _isAnalyzing = true;
    setState(() {});

    final imageInput = img.decodeImage(image.readAsBytesSync())!;

    final resultCategory = _classifier.predict(imageInput);

    final result = resultCategory.score >= 0.8 ? _ResultStatus.found : _ResultStatus.notFound;
    final plantLabel = resultCategory.label;
    final accuracy = resultCategory.score;

    _resultStatus = result;
    _plantLabel = plantLabel;
    _accuracy = accuracy;
    _isAnalyzing = false;
    setState(() {});
  }

  Widget _buildResultView() {
    var title = '';

    if (_resultStatus == _ResultStatus.notFound) {
      title = 'Unknown';
    } else if (_resultStatus == _ResultStatus.found) {
      title = _plantLabel;
    } else {
      title = '';
    }

    //
    var accuracyLabel = '';
    if (_resultStatus == _ResultStatus.found) {
      accuracyLabel = 'Accuracy: ${(_accuracy * 100).toStringAsFixed(2)}%';
    }

    return Column(
      children: [
        Text(title,
            style: AppTheme.appTheme.textTheme.displaySmall!.copyWith(color: Colors.orangeAccent)),
        const SizedBox(height: 10),
        Text(accuracyLabel,
            style: AppTheme.appTheme.textTheme.titleLarge!.copyWith(color: Colors.green))
      ],
    );
  }
}
