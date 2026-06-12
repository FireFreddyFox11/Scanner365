// ignore: file_names
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:touch365_scanner/components/Buttons.dart";
import "package:touch365_scanner/components/CheckBox.dart";
import "package:touch365_scanner/main.dart";

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MainAppState>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Enable Code 128",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CheckBox(
                    value: appState.code128Enabled,
                    onChanged: (value) {
                      appState.toggleACode128();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${appState.code93Enabled ? 'Enabled' : 'Disabled'} Code 93",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CheckBox(
                    value: appState.code93Enabled,
                    onChanged: (value) {
                      appState.toggleACode93();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${appState.code39Enabled ? 'Enabled' : 'Disabled'} Code 39",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CheckBox(
                    value: appState.code39Enabled,
                    onChanged: (value) {
                      appState.toggleACode39();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${appState.ean13Enabled ? 'Enabled' : 'Disabled'} EAN-13",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CheckBox(
                    value: appState.ean13Enabled,
                    onChanged: (value) {
                      appState.toggleAEan13();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${appState.ean8Enabled ? 'Enabled' : 'Disabled'} EAN-8",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CheckBox(
                    value: appState.ean8Enabled,
                    onChanged: (value) {
                      appState.toggleAEan8();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${appState.upcAEnabled ? 'Enabled' : 'Disabled'} UPC-A",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CheckBox(
                    value: appState.upcAEnabled,
                    onChanged: (value) {
                      appState.toggleAUpcA();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${appState.upcEEnabled ? 'Enabled' : 'Disabled'} UPC-E",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CheckBox(
                    value: appState.upcEEnabled,
                    onChanged: (value) {
                      appState.toggleAUpcE();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Consumer<MainAppState>(
                      builder: (context, state, _) => buildButton(
                        () => appState.toggleBinNumber(),
                        Icon(
                          state.binEnabled ? Icons.toggle_on : Icons.toggle_off,
                          color: Colors.white,
                        ),
                        const Text(
                          "Toggle Bin",
                          style: TextStyle(color: Colors.white),
                        ),
                        state.binEnabled ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Threshold Value: ",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => setState(() => appState.thresholdValue--),
                  ),
                  Text(
                    '${appState.thresholdValue % 4}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => appState.thresholdValue++),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
