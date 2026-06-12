// ignore: file_names
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:touch365_scanner/main.dart';
import 'package:touch365_scanner/pages/mainApp/HistoryPage.dart';
import 'package:touch365_scanner/pages/mainApp/TempWelcomePage.dart';
import 'package:touch365_scanner/components/Buttons.dart';
import 'package:image_picker/image_picker.dart';

// ─── Scanner Dialog Widget ────────────────────────────────────────────────────

class _ScannerDialog extends StatefulWidget {
  final MainAppState appState; // ← controller param removed

  const _ScannerDialog({required this.appState});

  @override
  State<_ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<_ScannerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimController;
  late Animation<double> _scanAnimation;
  late MobileScannerController _controller; // ← owned here now

  String? lastConfirmedValue;
  int confidenceScore = 0;
  bool isClosing = false;

  @override
  void initState() {
    super.initState();

    // ← controller created here
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: widget.appState.activeFormats,
      facing: CameraFacing.back,
      torchEnabled: widget.appState.switchedOn,
      cameraResolution: const Size(1920, 1080),
      autoZoom: true,
      returnImage: true,
    );

    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    _controller.dispose(); // ← only disposed once, safely here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, null);
      },
      child: AlertDialog(
        backgroundColor: Colors.black,
        contentPadding: EdgeInsets.zero,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 400,
            width: double.maxFinite,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller, // ← _controller throughout
                  onDetect: (capture) {
                    if (isClosing) return;
                    final barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? currValue = barcodes.first.displayValue
                          ?.trim();
                      if (currValue != null && currValue.length > 4) {
                        if (currValue == lastConfirmedValue) {
                          confidenceScore++;
                        } else {
                          lastConfirmedValue = currValue;
                          confidenceScore = 1;
                        }
                        setState(() {});

                        if (confidenceScore >= widget.appState.thresholdValue &&
                            !isClosing) {
                          isClosing = true;
                          HapticFeedback.lightImpact();
                          Navigator.pop(context, currValue);
                        }
                      }
                    }
                  },
                ),
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, _) {
                    return Positioned(
                      top: _scanAnimation.value * 390,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.cyanAccent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Center(
                  child: Container(
                    height: double.maxFinite,
                    width: 450,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (confidenceScore > 0 && !isClosing)
                  Positioned(
                    bottom: 12,
                    left: 24,
                    right: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value:
                              confidenceScore / widget.appState.thresholdValue,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.cyanAccent,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _controller.toggleTorch(); // ← _controller
              widget.appState.toggleFlashLight();
              setState(() {});
            },
            style: TextButton.styleFrom(
              backgroundColor: widget.appState.switchedOn
                  ? Colors.green
                  : Colors.transparent,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.transparent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'FlashLight',
              style: TextStyle(
                color: widget.appState.switchedOn ? Colors.white : Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 80),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.transparent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Home Page ────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> with WidgetsBindingObserver {
  var selectedIndex = 0;
  String latestScanResult = "None";
  String message = "";
  bool isScanned = false;
  late var appState = context.read<MainAppState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> onItemTapped(int index) async {
    setState(() => selectedIndex = index);
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

  bool isCorrectBarcode() {
    return false;
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

  Future<String?> scanBarcode(BuildContext context) async {
    // ← no controller created or disposed here anymore
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ScannerDialog(appState: appState),
    );
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

  Future<bool> showVerificationDialog(String scannedValue) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Force them to explicitly confirm or reject
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.assignment_turned_in, color: Colors.green),
              SizedBox(width: 8),
              Text("Verify Scan Result"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detected Code:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  scannedValue,
                  style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(height: 12),
              const Text("Is this value correct?"),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                "No, Rescan",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                "Yes, Correct",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    bool shouldPickAgain = true;

    while (shouldPickAgain) {
      // 🎯 Take them straight to the native photo gallery view
      final XFile? mediaFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Keeps the resolution crisp for barcode parsing
      );

      // If the user backs out of the gallery, stop looping
      if (mediaFile == null) {
        shouldPickAgain = false;
        return;
      }

      final String filePath = mediaFile.path;
      final MobileScannerController controller = MobileScannerController(
        formats: appState.activeFormats,
      );

      try {
        final BarcodeCapture? capture = await controller.analyzeImage(filePath);

        if (capture != null && capture.barcodes.isNotEmpty) {
          final String? res = capture.barcodes.first.displayValue?.trim();

          if (res != null) {
            HapticFeedback.lightImpact();

            // ignore: use_build_context_synchronously
            bool isCorrect = await showVerificationDialog(res);

            if (isCorrect) {
              shouldPickAgain = false; // Break the loop!

              double? q = await showQuantityField();
              String? b = '';
              if (appState.binEnabled) b = await showBinField();

              handleScanResult(res, q, b);
              onItemTapped(1);
            } else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scan discarded. Reopening gallery...'),
                  duration: Duration(milliseconds: 1500),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No barcode detected. Please select a clearer image.',
              ),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        debugPrint("MobileScanner file analysis error: $e");
      } finally {
        controller.dispose();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        debugPrint("App has been paused");
      case AppLifecycleState.detached:
        debugPrint("App has been detached");
      case AppLifecycleState.resumed:
        debugPrint("App has been resumed");
      case AppLifecycleState.inactive:
        debugPrint("App is inactive");
      case AppLifecycleState.hidden:
        debugPrint("App is hidden");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      const TempWelcomePage(),
      const HistoryPage(),
    ];
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
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
                        onPressed: () => pickImage(),
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
                  onPressed: () async {
                    bool shouldScanAgain = true;

                    while (shouldScanAgain) {
                      // 1. Open the camera dialog view
                      // ignore: use_build_context_synchronously
                      String? scannedResult = await scanBarcode(context);

                      // If the user hits 'Cancel' or backs out, exit the loop entirely
                      if (scannedResult == null) {
                        shouldScanAgain = false;
                        break;
                      }

                      // 2. Intercept with the verification gate immediately
                      bool isCorrect = await showVerificationDialog(
                        scannedResult,
                      );

                      if (isCorrect) {
                        shouldScanAgain = false;
                        double? q = await showQuantityField();
                        String b = '';
                        if (appState.binEnabled) b = await showBinField();

                        handleScanResult(scannedResult, q, b);
                      }
                    }
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
