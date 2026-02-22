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
import 'dart:math';
// BackendService bService = BackendService(mainTable);

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

List<String> tables = ["bfstorage", "barcodefile"];

Future<void> main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainAppState()),
        ChangeNotifierProvider(
          create: (_) => ConvertToDecimal(),
        ), // Add it here
      ],
      child: const MainApp(),
    ),
  );
}

class BarcodeFileStorage {
  int id;
  List<BarcodeFile> bFile;
  String dTime;
  BarcodeFileStorage({
    required this.id,
    required this.bFile,
    required this.dTime,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'bFile': bFile.map((b) => b.toJson()).toList(),
    'dTime': dTime,
  };
  factory BarcodeFileStorage.fromJson(Map<String, dynamic> json) =>
      BarcodeFileStorage(
        id: json['id'],
        bFile: (json['bFile'] as List)
            .map((b) => BarcodeFile.fromJson(b))
            .toList(),
        dTime: json['dTime'],
      );
}

//Used to store and use information about the product's barcode and the quantity of the product
class BarcodeFile {
  int id;
  final String barcode;
  double quantity;
  int binNumber;
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
      binNumber: int.tryParse(parts[3]) ?? 0,
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
    binNumber: json['binNumber'],
  );
}

//Defines the initial state of the application
class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainAppState(),
      child: MaterialApp(
        title: "Scanner365",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          scaffoldBackgroundColor: Colors.black,
        ),
        home: HomePage(),
      ),
    );
  }
}

//Handles overall functionality of the application
class MainAppState extends ChangeNotifier {
  MainAppState() {
    loadFromDisk();
  }
  List<BarcodeFile> fileStorage = [];
  List<BarcodeFileStorage> bFStorage = [];
  List<BarcodeFile> _backUp = [];
  DateTime now = DateTime.now();
  late String t = DateFormat('hh:mm:ss').format(now);
  int i = 0;
  int iM = 0;
  void addToFile(String result, double quantity, int binNumber) {
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

  void addToFileStorage(List<BarcodeFile> bFile) {
    late String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int eIndex = bFStorage.indexWhere((record) => record.dTime == date);
    if (eIndex != -1) {
      bFStorage[eIndex].bFile = List.from(bFile);
    } else {
      iM++;
      bFStorage.add(
        BarcodeFileStorage(id: iM, bFile: List.from(bFile), dTime: date),
      );
    }
    saveToDisk();
    notifyListeners();
  }

  Future<void> parseAndLoadFile(BarcodeFileStorage record) async {
    fileStorage.clear();
    fileStorage.addAll(record.bFile);
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

  void updateQuantity(int index, double quantity) {
    fileStorage[index].quantity = quantity;
    notifyListeners();
  }

  void updateBinNumber(int index, int binNumber) {
    fileStorage[index].binNumber = binNumber;
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
      int count = 0;
      final Directory dir = await getTemporaryDirectory();
      File f = File("${dir.path}/bText$count.txt");
      if (await f.exists()) {
        count++;
        f = File("${dir.path}/bText$count.txt");
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

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(fileStorage.map((b) => b.toJson()).toList());
    await prefs.setString('history_data', encoded);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('history_data');
    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);
      fileStorage = decoded.map((b) => BarcodeFile.fromJson(b)).toList();
      notifyListeners();
    }
  }
}

//Main page where there application begins
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _MyHomePageState();
}

//Used to implement the widget that is used to define the style and structure of the Home Page
class _MyHomePageState extends State<HomePage> with WidgetsBindingObserver {
  //The variables and functions are intended to be in this class. Advisable not to relocate
  var selectedIndex = 0;
  String latestScanResult = "None";
  String message = "";
  late var appState = context.read<MainAppState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  Future<void> onItemTapped(int index) async {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> _startAutoScan(String? res) async {
    if (!mounted) return;
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    res = await SimpleBarcodeScanner.scanBarcode(context, delayMillis: 1000);
    if (res != null && res != "-1") {
      handleScanResult(res);
      onItemTapped(1);
    }
  }

  Future<void> handleScanResult(String result) async {
    setState(() {
      latestScanResult = result;
      selectedIndex = 1;
    });
    appState.addToFile(result, 0, 0);
    appState.addToFileStorage(List.from(appState.fileStorage));
  }

  Future<void> pickFile() async {
    FilePickerResult? fpr = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );
    if (fpr != null && fpr.files.first.path != null) {
      String filePath = fpr.files.first.path!;

      final inputImage = InputImage.fromFilePath(filePath);
      final barcodeScanner = BarcodeScanner();

      try {
        final List<Barcode> barcodes = await barcodeScanner.processImage(
          inputImage,
        );
        if (barcodes.isNotEmpty) {
          String? res = barcodes.first.rawValue;
          if (res != null) {
            appState.addToFile(res, 0, 0);
            appState.addToFileStorage(List.from(appState.fileStorage));
            onItemTapped(1);
          }
        }
      } finally {
        barcodeScanner.close();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print("App has been paused");
      case AppLifecycleState.detached:
        print("App has been detached");
      case AppLifecycleState.resumed:
        print("App has been resumed");
      case AppLifecycleState.inactive:
        print("App is inactive");
      case AppLifecycleState.hidden:
        print("App is hidden");
    }
  }

  @override
  Widget build(BuildContext context) {
    late final List<Widget> widgetOptions = <Widget>[
      const TempWelcomePage(),
      const HistoryPage(),
    ];
    return Scaffold(
      // OUTER SCAFFOLD: This one handles the SnackBar
      body: Builder(
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.barcode_reader, color: Colors.white),
                  const SizedBox(width: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: 'Scanner ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: '365',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
            body: widgetOptions.elementAt(selectedIndex),
            bottomNavigationBar: BottomAppBar(
              color: Colors.green,
              child: IconTheme(
                data: IconThemeData(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SingleChildScrollView(
                      child: VertIconButton(
                        onPressed: () => pickFile(),
                        dIcon: Icons.storage,
                        text: "Media",
                        color: Colors.white,
                      ),
                    ),
                    SingleChildScrollView(
                      child: VertIconButton(
                        onPressed: () => onItemTapped(1),
                        dIcon: Icons.file_copy,
                        text: "History",
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: SizedBox(
                width: 210.0,
                child: FloatingActionButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Scan Started!"),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                          bottom: 100,
                          left: 20,
                          right: 20,
                        ),
                      ),
                    );
                    _startAutoScan(latestScanResult);
                  },
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.barcode_reader, color: Colors.white),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }
}

//Shortcut for creating an Icon Button used in the bottom navigation bar
class VertIconButton extends StatefulWidget {
  const VertIconButton({
    super.key,
    required this.onPressed,
    this.dIcon = Icons.file_copy_outlined,
    this.text = "0/",
    this.color = Colors.transparent,
  });
  final IconData dIcon;
  final String text;
  final VoidCallback onPressed;
  final Color color;

  @override
  State<StatefulWidget> createState() => _VertIconButton();
}

//Implementation of the shortcut
class _VertIconButton extends State<VertIconButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        alignment: Alignment.center,
        backgroundColor: Colors.green,
        shadowColor: Colors.transparent,
        iconColor: widget.color,
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(widget.dIcon),
          SizedBox(height: 5),
          Text(widget.text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

//Temporary welcome page for when the app first starts
class TempWelcomePage extends StatelessWidget {
  const TempWelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Scan products the easy way",
                style: TextStyle(color: Colors.white, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              Text(
                "Click Button Below to get started",
                style: TextStyle(color: Colors.white, fontSize: 32),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});
  @override
  State<StatefulWidget> createState() => _HistoryTab();
}

//Implementation of the History Page
class _HistoryTab extends State<HistoryTab> {
  final TextEditingController binText = TextEditingController();
  Future<void> modifyQuantity(int i, double nV) async {
    final item = context.read<MainAppState>().fileStorage[i];
    setState(() {
      item.quantity = nV;
    });
    // bService.modifyValue(item.id, nV);
  }

  Future<void> modifyBin(int i, int nV) async {
    final item = context.read<MainAppState>().fileStorage[i];
    setState(() {
      item.binNumber = nV;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cProvider = context.read<ConvertToDecimal>();
    var appState = context.watch<MainAppState>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("File Details"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          if (appState.fileStorage.isEmpty)
            const Expanded(
              child: Center(
                child: Text("List is empty", style: TextStyle(fontSize: 20)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: context.watch<MainAppState>().fileStorage.length,
                itemBuilder: (context, index) {
                  var lstHist = context.read<MainAppState>().fileStorage[index];
                  return Card(
                    elevation: 5,
                    color: Colors.green,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 7.5,
                      vertical: 7.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${lstHist.id}. ${lstHist.barcode}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: SizedBox(
                                  width: 160,
                                  child: SpinBox(
                                    min: 0,
                                    max: 100000,
                                    decimals: cProvider.precisionsList,
                                    step: cProvider.handleConversions,
                                    value: lstHist.quantity.toDouble(),
                                    iconColor: WidgetStateProperty.all<Color?>(
                                      Colors.white,
                                    ),
                                    onChanged: (value) =>
                                        appState.updateQuantity(index, value),
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: SizedBox(
                                  width: 160,
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: lstHist.binNumber.toString(),
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: "Bin #",
                                      labelStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                    onChanged: (value) {
                                      final val = int.tryParse(value);
                                      if (val != null) {
                                        appState.updateBinNumber(index, val);
                                      }
                                    },
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          // Wrap the padding in a Card, and the Card in a SafeArea
          SafeArea(
            top: true, // We only care about the bottom system bar here
            child: Card(
              margin: const EdgeInsets.all(12),
              color: Colors
                  .grey[100], // Darker card to pop against the black background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Constrains the column height
                        children: [
                          buildButton(
                            () => appState.downloadFile(
                              context,
                              appState.fileStorage,
                            ),
                            const Icon(Icons.download),
                            const Text(
                              "Download",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          buildButton(
                            () {
                              appState.clearEverything(appState.fileStorage);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Everything has been cleared",
                                  ),
                                  action: SnackBarAction(
                                    label: "Undo",
                                    onPressed: appState.undo,
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            },
                            const Icon(Icons.delete),
                            const Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildButton(
                            () async {
                              final bool result = await appState.shareInfo(
                                appState.fileStorage,
                                2,
                              );
                              if (result) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Information has been shared",
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            const Icon(Icons.share),
                            const Text(
                              "Save Info",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          buildButton(
                            () {
                              cProvider.setPrecision();
                              appState.changeConversion();
                            },
                            const Icon(Icons.add_rounded),
                            const Text(
                              "Converter",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<StatefulWidget> createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    if (context.watch<MainAppState>().bFStorage.isEmpty) {
      return const Center(
        child: Text(
          "No files have been loaded",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: context.watch<MainAppState>().bFStorage.length,
            itemBuilder: (context, index) {
              var bFStorageFile = context
                  .watch<MainAppState>()
                  .bFStorage[index];
              return InkWell(
                onTap: () async {
                  var appState = context.read<MainAppState>();
                  await appState.parseAndLoadFile(bFStorageFile);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryTab()),
                  );
                },
                child: Card(
                  color: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            "File ${index + 1}-Date: ${bFStorageFile.dTime}",
                          ),
                          subtitle: Text(
                            "Last recorded: "
                            "${DateTime.now().hour < 10 ? "0${DateTime.now().hour}" : DateTime.now().hour}:"
                            "${DateTime.now().minute < 10 ? "0${DateTime.now().minute}" : DateTime.now().minute}:"
                            "${DateTime.now().second < 10 ? "0${DateTime.now().second}" : DateTime.now().second}",
                          ),
                          style: ListTileStyle.list,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        /*
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {  },
            style: IconButton.styleFrom(
              backgroundColor: Color.fromARGB(175, 255, 228, 196),
              foregroundColor: Colors.black,
              elevation: 150,
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(6)),
              padding: const EdgeInsets.only(left: 155, right: 175, top: 12, bottom: 12),
              iconSize: 50
            )
          ),
        )
        */
      ],
    );
  }
}

class ConvertToDecimal extends ChangeNotifier {
  double _value = 1.0;
  int defaultDecimal = 0;
  final List<int> precisions = [0, 1, 2, 3];

  void setPrecision() {
    defaultDecimal = _decCalc();
    notifyListeners();
  }

  int _decCalc() {
    return (defaultDecimal + 1) % precisions.length;
  }

  double get getPrecision =>
      _decCalc() == 0 ? 1.0 : pow(10, -precisions[defaultDecimal]).toDouble();

  void updateValue(double newValue) {
    _value = newValue;
    notifyListeners();
  }

  double get value => _value;
  int get precisionsList => precisions[defaultDecimal];

  double get handleConversions {
    return pow(10, -precisionsList).toDouble();
  }
}

Widget buildButton(VoidCallback vcb, Icon i, Text t) {
  return ElevatedButton.icon(
    onPressed: vcb,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green[700],
      iconColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      fixedSize: Size(150, 40),
    ),
    icon: i,
    label: t,
  );
}

//Used to define the scanner used to scan the barcodes
//Note: Although not implemented it is a requirement so please do not remove
class ScannerPage extends StatelessWidget {
  final Function(String result) onScanResult;
  const ScannerPage({super.key, required this.onScanResult});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SimpleBarcodeScanner(
          scaleHeight: 600.00,
          scaleWidth: 400.00,
          onScanned: onScanResult,
          onBarcodeViewCreated: (_) {},
        ),
      ),
    );
  }
}

/*
class MediaPage extends StatefulWidget {
  const MediaPage({super.key});
  @override
  State<StatefulWidget> createState() => _MyMediaPage();
}

//Used to select and upload a picture to be scanned by the scanner
class _MyMediaPage extends State<MediaPage> {
  HomePage get appState => context.watch<HomePage>();
  String? latestScanResult = "None";
  void handleScanResult(String? request) {
    setState(() {
      latestScanResult = request;
      
    });
  } 
  @override
  Widget build(BuildContext context) {
    Future<void> pickFile() async {
      FilePickerResult? fpr = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg'],
      );
      if (fpr != null && fpr.files.first.path != null) {
        String filePath = fpr.files.first.path!;

        final inputImage = InputImage.fromFilePath(filePath);
        final barcodeScanner = BarcodeScanner();

        try {
          final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
          if (barcodes.isNotEmpty) {
            String? res = barcodes.first.rawValue;
            if (res != null) {
              context.read<MainAppState>().addToFile(res, 0);
            }
          }
        }
        finally {
          barcodeScanner.close();
        }
      }
    }
    return Center(
      child: ElevatedButton.icon(
        onPressed: pickFile,
        icon: Icon(Icons.upload, size: 20),
        label: Text(
          "Upload File",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color?>(Colors.green),
          iconColor: WidgetStateProperty.all<Color?>(Colors.white),
        ),
      ),
    );
  }
}
*/
