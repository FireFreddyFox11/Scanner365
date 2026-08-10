import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:touch365_scanner/components/Buttons.dart';
import 'package:touch365_scanner/main.dart';
import 'package:touch365_scanner/pages/mainApp/HistoryPage.dart';
import 'package:touch365_scanner/pages/mainApp/TempWelcomePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> with WidgetsBindingObserver {
  int selectedIndex = 0;
  String latestScanResult = "None";
  late var appState = context.read<MainAppState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // MobileScanner variables
  late final MobileScannerController _scannerController;
  bool _isProcessingScan = false;
  bool _isCameraActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.ean13, BarcodeFormat.code128],
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessingScan || !_isCameraActive) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? scannedResult = barcodes.first.rawValue;
    if (scannedResult == null || scannedResult.isEmpty) return;

    setState(() {
      _isProcessingScan = true;
    });

    // Pause camera while processing prompt
    await _scannerController.stop();

    double q = await showQuantityField();
    String b = '';
    if (appState.binEnabled) {
      b = await showBinField();
    }

    await handleScanResult(scannedResult, q, b);

    // Resume scanner if camera is active
    if (_isCameraActive) {
      await _scannerController.start();
    }

    if (mounted) {
      setState(() {
        _isProcessingScan = false;
      });
    }
  }

  Future<void> onItemTapped(int index) async {
    setState(() => selectedIndex = index);
  }

  void _toggleCameraView() {
    setState(() {
      _isCameraActive = !_isCameraActive;
    });
    if (_isCameraActive) {
      _scannerController.start();
    } else {
      _scannerController.stop();
    }
  }

  Future<String> showBinField() async {
    String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController tController = TextEditingController();
        return AlertDialog(
          title: const Text("Enter Bin Number"),
          content: TextField(
            controller: tController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "0"),
          ),
          actions: [
            ElevatedButton(
              child: const Text("Confirm"),
              onPressed: () => Navigator.pop(context, tController.text),
            ),
          ],
        );
      },
    );
    return value ?? '';
  }

  Future<double> showQuantityField() async {
    double? value = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController tController = TextEditingController();
        return AlertDialog(
          title: const Text("Enter Quantity"),
          content: TextField(
            controller: tController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: "0.00"),
          ),
          actions: [
            ElevatedButton(
              child: const Text("Confirm"),
              onPressed: () {
                final double? enteredValue = double.tryParse(tController.text);
                Navigator.pop(context, enteredValue ?? 0.0);
              },
            ),
          ],
        );
      },
    );
    return value ?? 0.0;
  }

  Future<void> handleScanResult(
    String result,
    double quantity,
    String binNumber,
  ) async {
    setState(() {
      latestScanResult = result;
      selectedIndex = 1;
    });
    await appState.addToFile(result, quantity, binNumber);
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? mediaFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 4000,
      maxHeight: 4000,
    );

    if (mediaFile == null) return;

    if (!mounted) return;

    final BarcodeCapture? capture = await _scannerController.analyzeImage(
      mediaFile.path,
    );

    if (capture != null && capture.barcodes.isNotEmpty) {
      final String? scannedResult = capture.barcodes.first.rawValue;
      if (scannedResult != null && scannedResult.isNotEmpty) {
        double q = await showQuantityField();
        String b = '';
        if (appState.binEnabled) {
          b = await showBinField();
        }
        await handleScanResult(scannedResult, q, b);
        return;
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No valid barcode was found in the selected image.'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _scannerController.stop();
        debugPrint("Camera paused");
      case AppLifecycleState.resumed:
        if (_isCameraActive) {
          _scannerController.start();
        }
        debugPrint("Camera resumed");
      case AppLifecycleState.detached:
        debugPrint("App detached");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      const TempWelcomePage(),
      const HistoryPage(),
    ];

    return Scaffold(
      extendBody: true, // Allows camera feed to extend under the BottomAppBar
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.barcode_reader, color: Colors.white),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
      ),
      body: Stack(
        children: [
          // 1. Full-Length Screen Camera Feed
          if (_isCameraActive) ...[
            SizedBox.expand(
              child: MobileScanner(
                controller: _scannerController,
                onDetect: _onBarcodeDetected,
              ),
            ),
            // Scanner alignment crosshair frame
            Center(
              child: Container(
                width: 280,
                height: 140,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],

          // 2. Main Active View (Welcome / History) Overlay
          if (!_isCameraActive) widgetOptions.elementAt(selectedIndex),
        ],
      ),

      // 3. Bottom Bar with Rectangular Scan Button
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Media Button
              SingleChildScrollView(
                child: VertIconButton(
                  onPressed: () => pickImage(),
                  dIcon: Icons.storage,
                  text: "Media",
                  color: Colors.white,
                ),
              ),
              // Rectangular Scan Camera Button
              SingleChildScrollView(
                child: InkWell(
                  onTap: _toggleCameraView,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.transparent, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            _isCameraActive
                                ? Icons.camera_alt
                                : Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
                        ),                        
                      ],
                    ),
                  ),
                ),
              ),

              // History Button
              SingleChildScrollView(
                child: VertIconButton(
                  onPressed: () {
                    if (_isCameraActive) _toggleCameraView();
                    onItemTapped(1);
                  },
                  dIcon: Icons.file_copy,
                  text: "History",
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}