import 'dart:math';

import 'package:collection/collection.dart';
import 'package:image/image.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
// import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

//tflite type

abstract class Classifier {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  var logger = Logger();
  late List<int> _inputShape;
  late List<int> _outputShape;
  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;
  // TensorType _outputType = TensorType.uint8;
  final String _labelsFileName = 'assets/dict.txt';
  //final int _labelsLength = 6;
  var _probabilityProcessor;
  late List<String> labels;

  String get modelName => 'assets/model.tflite';
  NormalizeOp get preProcessNormalizeOp;
  NormalizeOp get postProcessNormalizeOp;

  Classifier({int numThreads = 0}) {
    _interpreterOptions = InterpreterOptions();

    _interpreterOptions.threads = numThreads;
    loadModel();
    loadLabels();
  }

  Future<void> loadModel() async {
    print('Loading model...');
    try {
      interpreter = await Interpreter.fromAsset(
        'assets/model.tflite',
        options: _interpreterOptions,
      );
      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      // _outputType = interpreter.getOutputTensor(0).type;
      _outputBuffer = TensorBufferUint8(_outputShape); //TensorBufferFloat32
      _probabilityProcessor = TensorProcessorBuilder().add(postProcessNormalizeOp).build();
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  Future<void> loadLabels() async {
    labels = await FileUtil.loadLabels(_labelsFileName);
    if (labels.length != 0) {
      print('Labels loaded successfully');
    } else {
      print('Unable to load labels');
    }
  }

  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(
          ResizeOp(
            _inputShape[1],
            _inputShape[2],
            ResizeMethod.NEAREST_NEIGHBOUR,
          ),
        )
        .add(preProcessNormalizeOp)
        .build()
        .process(_inputImage);
  }

  Category predict(Image image) {
    if (interpreter == null) {
      throw StateError('Cannot run inference, Interpreter is null');
    }
    _inputImage = TensorImage.fromImage(image);
    _inputImage = _preProcess();
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    Map<String, double> labeledProb = TensorLabel.fromList(
      labels,
      _probabilityProcessor.process(_outputBuffer),
    ).getMapWithFloatValue();
    final prediction = getTopProbability(labeledProb);
    return Category(prediction.key, prediction.value);
  }

  void close() {
    interpreter.close();
  }
}

MapEntry<String, double> getTopProbability(Map<String, double> labeledProb) {
  var pq = PriorityQueue<MapEntry<String, double>>(compare);
  pq.addAll(labeledProb.entries);
  return pq.first;
}

int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
  if (e1.value > e2.value) {
    return -1;
  } else if (e1.value == e2.value) {
    return 0;
  } else {
    return 1;
  }
}
