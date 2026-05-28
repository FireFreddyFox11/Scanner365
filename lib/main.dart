///<-----------------------------------------------Developer information----------------------------------------------->
/// Author: Ashraf Noor-Mahomed
/// Project: Scanner365
/// Version: N/A
/// Email: ash1101001@gmail.com
/// Phone: 081 517 6969 (Whatsapp and Landline)
// ignore_for_file: use_build_context_synchronously
// ignore_for_file: avoid_print

library;

//Packages required for the app to work
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch365_scanner/pages/mainApp/HomePage.dart';
import 'pages/ApiServices/BackendServices.dart';

final BackendServices bService = BackendServices();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final mainAppState = MainAppState();
  await mainAppState.loadFromDisk();
  try {
    await bService.initializeDatabase();
  } on Exception catch (e) {
    print(e);
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MainAppState>.value(value: mainAppState),
    ],
      child: const MainApp(),
    ),
  );
}

//Used to store and use information about the product's barcode and the quantity of the product
class BarcodeFile {
  int id;
  final String barcode;
  double quantity;
  final String binNumber;
  BarcodeFile({
    required this.id,
    required this.barcode,
    required this.quantity,
    required this.binNumber,
  });
  factory BarcodeFile.fromString(String line) {
    // Split the text line by your delimiter (comma, tab, etc.)
    final parts = line.split(',');
    return BarcodeFile(
      id: int.tryParse(parts[0]) ?? 1,
      barcode: parts[1],
      quantity: double.tryParse(parts[2]) ?? 0.0,
      binNumber: parts[3],
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'barcode': barcode,
    'quantity': quantity,
    'binNumber': binNumber,
  };
  factory BarcodeFile.fromJson(Map<String, dynamic> json) => BarcodeFile(
    id: json['id'],
    barcode: json['barcode'],
    quantity: json['quantity'],
    binNumber: json['binNumber']?.toString() ?? '',
  );
}

//Defines the initial state of the application and the theme of the app
class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Scanner365",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomePage(),
    );
  }
}

//Handles overall functionality of the application
class MainAppState extends ChangeNotifier {
  List<BarcodeFile> fileStorage = [];
  List<BarcodeFile> _backUp = [];
  final Map<BarcodeFormat, bool> formatMap = {
    BarcodeFormat.code128: true,
    BarcodeFormat.code39: true,
    BarcodeFormat.code93: true,
    BarcodeFormat.ean13: true,
    BarcodeFormat.ean8: true,
    BarcodeFormat.upcA: true,
    BarcodeFormat.upcE: true,
  };
  DateTime now = DateTime.now();
  int count = 0;
  late String t = DateFormat('hh:mm:ss').format(now);
  int i = 0;
  int iM = 0;
  void addToFile(String result, double quantity, String binNumber) {
    i++;
    fileStorage.add(
      BarcodeFile(
        id: i,
        barcode: result,
        quantity: quantity,
        binNumber: binNumber,
      ),
    );
    saveToDisk();
    notifyListeners();
  }

  int thresholdValue = 0;
  DetectionSpeed dSpeed = DetectionSpeed.normal;

  bool _binEnabled = false;
  bool _isSwitchedOn = false;
  bool _code128Enabled = true;
  bool _code39Enabled = true;
  bool _code93Enabled = true;
  bool _ean13Enabled = true;
  bool _ean8Enabled = true;
  bool _upcAEnabled = true;
  bool _upcEEnabled = true;
  
  bool get binEnabled => _binEnabled;
  bool get switchedOn => _isSwitchedOn;
  bool get code128Enabled => _code128Enabled;
  bool get code39Enabled => _code39Enabled;
  bool get code93Enabled => _code93Enabled;
  bool get ean13Enabled => _ean13Enabled;
  bool get ean8Enabled => _ean8Enabled;
  bool get upcAEnabled => _upcAEnabled;
  bool get upcEEnabled => _upcEEnabled;

  void setThresholdValue(int value) {
    thresholdValue = value;
    notifyListeners();
  }

  List<BarcodeFormat> get activeFormats => formatMap.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

  void updateFormatMap(bool value, BarcodeFormat format) {
    formatMap[format] = value;
    notifyListeners();   
  }

  void toggleACode128() {
    _code128Enabled = !_code128Enabled;
    updateFormatMap(_code128Enabled, BarcodeFormat.code128);
  }

  void toggleACode39() {
    _code39Enabled = !_code39Enabled;
    updateFormatMap(_code39Enabled, BarcodeFormat.code39);
  }

  void toggleACode93() {
    _code93Enabled = !_code93Enabled;
    updateFormatMap(_code93Enabled, BarcodeFormat.code93);
  }

  void toggleAEan13() {
    _ean13Enabled = !_ean13Enabled;
    updateFormatMap(_ean13Enabled, BarcodeFormat.ean13);
  }

  void toggleAEan8() {
    _ean8Enabled = !_ean8Enabled;
    updateFormatMap(_ean8Enabled, BarcodeFormat.ean8);
  }

  void toggleAUpcA() {
    _upcAEnabled = !_upcAEnabled;
    updateFormatMap(_upcAEnabled, BarcodeFormat.upcA);
  }
  void toggleAUpcE() {
    _upcEEnabled = !_upcEEnabled;
    updateFormatMap(_upcEEnabled, BarcodeFormat.upcE);
  }

  void toggleBinNumber() {
    _binEnabled = !_binEnabled;
    print('Feature toggled to: $_binEnabled');
    notifyListeners();
  }

  void toggleFlashLight() {
    _isSwitchedOn = !_isSwitchedOn;
    notifyListeners();
  }

  String get textContent {
    StringBuffer sb = StringBuffer();
    for (var b in fileStorage) {
      sb.writeln("${b.barcode},${b.quantity},${b.binNumber}");
    }
    return sb.toString();
  }

  void loadHistory(int index, BarcodeFile file) {
    fileStorage[index] = file;
    notifyListeners();
  }

  Future<File> getFile(List<BarcodeFile> storage, int deciFix) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final Directory dir = await getTemporaryDirectory();
    final File f = File("${dir.path}/bText_$timestamp.txt");

    final IOSink openFile = f.openWrite();
    for (var b in storage) {
      openFile.write(
        "${b.barcode},${b.quantity.toStringAsFixed(deciFix)},${b.binNumber}\n",
      );
    }
    await openFile.flush();
    await openFile.close();

    return f;
  }

  Future<bool> shareInfo(List<BarcodeFile> storage, int deciFix) async {
    final report = await getFile(storage, deciFix);
    final XFile file = XFile(report.path);
    final params = ShareParams(
      text: 'Quantity file',
      subject: 'File from Scanner365',
      files: [file],
    );
    final result = await SharePlus.instance.share(params);
    if (result.status == ShareResultStatus.success) {
      print("Success");
      return true;
    } else {
      print("Failed to share: $result");
      return false;
    }
  }

  Future<void> undo() async {
    fileStorage.addAll(_backUp);
    _backUp.clear();
    notifyListeners();
  }

  Future<void> deleteRecord(int index, List<BarcodeFile> storage) async {
    storage.removeAt(index);
    await saveFSToDisk();
    notifyListeners();
  }

  Future<void> clearEverything(List<BarcodeFile> storage) async {
    _backUp = List.from(storage);
    storage.clear();
    notifyListeners();
  }

  Future<void> downloadFile(
    BuildContext context,
    List<BarcodeFile> storage,
  ) async {
    if (storage.isEmpty) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("The File is empty and thus cannot be downloaded"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final Directory dir = await getTemporaryDirectory();
      File f = File("${dir.path}/bText${int.tryParse(timestamp)! % 10000}.txt");
      if (await f.exists()) {
        f = File("${dir.path}/bText${int.tryParse(timestamp)! % 10000}.txt");
      }
      final IOSink openFile = f.openWrite();
      for (var b in storage) {
        openFile.write("${b.barcode},${b.quantity},${b.binNumber}\n");
      }
      await openFile.flush();
      await openFile.close();

      final params = SaveFileDialogParams(sourceFilePath: f.path);
      final pathFinal = await FlutterFileDialog.saveFile(params: params);

      if (pathFinal != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("File saved to $pathFinal")));
      }
    } catch (e) {
      debugPrint("Error with file");
    }
  }

  void setItems(List<BarcodeFile> fetchedItems) {
    fileStorage = fetchedItems;
    notifyListeners();
  }

  Future<void> changeConversion() async {
    for (var item in fileStorage) {
      item.quantity = item.quantity.toInt().toDouble();
    }
    notifyListeners();
  }

  Future<void> saveFSToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(fileStorage.map((b) => b.toJson()).toList());
    await prefs.setString('history_data', encoded);
  }

  Future<void> saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String encoded = jsonEncode(fileStorage.map((b) => b.toJson()).toList());
      await prefs.setString('history_data', encoded);
      print('Saved ${fileStorage.length} items to disk');
    } catch (e) {
      print('Error saving to disk: $e');
    }
  }

  Future<void> loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString('history_data');
      if (data != null) {
        List<dynamic> decoded = jsonDecode(data);
        fileStorage = decoded.map((b) => BarcodeFile.fromJson(b)).toList();
        if (fileStorage.isNotEmpty) {
          i = fileStorage.map((b) => b.id).reduce((a, b) => a > b ? a : b);
        }
        print('Loaded ${fileStorage.length} items from disk');
      }
    } catch (e) {
      print('Error loading from disk: $e');
    }
    notifyListeners();
  }

  Future<void> deleteBFFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history_data');
    fileStorage.clear();
    i = 0;
    notifyListeners();
  }
}
