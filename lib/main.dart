import 'dart:async';
import 'dart:ffi';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binary Flashlight',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BinaryFlashlightScreen(cameras: cameras),
    );
  }
}

class BinaryFlashlightScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const BinaryFlashlightScreen({Key? key, required this.cameras})
      : super(key: key);

  @override
  _BinaryFlashlightScreenState createState() => _BinaryFlashlightScreenState();
}

class _BinaryFlashlightScreenState extends State<BinaryFlashlightScreen> {
  late CameraController _controller;
  String _inputString = '';
  int _inputDelay = 1000;
  double _Mult = 1.0;
  Timer? _timer;
  int _index = 0;
  bool _Starter = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0], // Use the first available camera
      ResolutionPreset.low, // Choose a lower resolution for flashlight control
    );
    _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String encryptPassword(String password) {
    final Map<String, String> charMap = {
      'a': 'm',
      'b': 'n',
      'c': 'b',
      'd': 'v',
      'e': 'c',
      'f': 'x',
      'g': 'z',
      'h': 'l',
      'i': 'k',
      'j': 'j',
      'k': 'h',
      'l': 'g',
      'm': 'f',
      'n': 'd',
      'o': 's',
      'p': 'a',
      'q': 'p',
      'r': 'o',
      's': 'i',
      't': 'u',
      'u': 'y',
      'v': 't',
      'w': 'r',
      'x': 'e',
      'y': 'w',
      'z': 'q',
      'A': 'M',
      'B': 'N',
      'C': 'B',
      'D': 'V',
      'E': 'C',
      'F': 'X',
      'G': 'Z',
      'H': 'L',
      'I': 'K',
      'J': 'J',
      'K': 'H',
      'L': 'G',
      'M': 'F',
      'N': 'D',
      'O': 'S',
      'P': 'A',
      'Q': 'P',
      'R': 'O',
      'S': 'I',
      'T': 'U',
      'U': 'Y',
      'V': 'T',
      'W': 'R',
      'X': 'E',
      'Y': 'W',
      'Z': 'Q',
      '0': '9',
      '1': '8',
      '2': '7',
      '3': '6',
      '4': '5',
      '5': '4',
      '6': '3',
      '7': '2',
      '8': '1',
      '9': '0'
    };

    String encryptedPassword = password.split('').map((char) {
      return charMap[char] ??
          char; // Use the original character if not in the map
    }).join('');

    return encryptedPassword;
  }

  Future<void> _toggleFlashlight(bool on) async {
    try {
      if (on) {
        await _controller.setFlashMode(FlashMode.torch);
      } else {
        await _controller.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      print('Failed to toggle flashlight: $e');
    }
  }

  Future<void> delayedFunction(double value) async {
    await Future.delayed(Duration(milliseconds: value.toInt())); // Delay
  }

  String letterToBinary(String letter) {
    if (letter.length != 1) {
      throw ArgumentError('Input must be a single letter.');
    }

    // Get the ASCII value of the letter
    int asciiValue = letter.codeUnitAt(0);

    // Convert ASCII value to binary string
    String binaryString = asciiValue.toRadixString(2);

    // Pad the binary string with leading zeros to make it 8 characters long
    binaryString = binaryString.padLeft(8, '0');

    return '1$binaryString' '0'; //add 1 at the begging and 0 at the end
  }

  void _startFlashing() async {
    _Starter = true;
    int n = 0;
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    // print(letterToBinary(_inputString[n]));
    // _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
    while (n < _inputString.length) {
      if (_Starter) {
        String CharInBinary = letterToBinary(_inputString[n]);
        for (int i = 0; i < 10; i++) {
          if (CharInBinary[i] == '1') {
            _toggleFlashlight(true);
            await delayedFunction(_inputDelay.toDouble());
          } else {
            _toggleFlashlight(false);
            await delayedFunction(_inputDelay * _Mult);
          }
        }
        n++;
      } else {
        break;
      }
    }
  }
  // }

  void _stopFlashing() {
    if (_Starter) {
      _Starter = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('ULFG LIFI MINI_PROJECT'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter a string:',
              ),
              onChanged: (value) {
                setState(() {
                  _inputString = encryptPassword(value);
                });
              },
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter the speed in Millesecond(Default is 1000ms):',
              ),
              onChanged: (value) {
                setState(() {
                  _inputDelay = int.tryParse(value) ??
                      1000; //if value is null _inputDelay is 1000ms
                });
              },
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter the difference between bits(Default is x1):',
              ),
              onChanged: (value) {
                setState(() {
                  _Mult = double.tryParse(value) ?? 1.0; //if value it is x1
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _startFlashing();
              },
              child: Text('Start Flashing'),
            ),
            ElevatedButton(
              onPressed: () {
                _stopFlashing();
              },
              child: Text('Stop Flashing'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Made by Kassem Elhajj And Mohammad Karaki',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
