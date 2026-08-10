// ignore: file_names
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch365_scanner/main.dart';
import 'package:touch365_scanner/components/Buttons.dart';
import 'package:touch365_scanner/pages/mainApp/SettingPage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<StatefulWidget> createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  final TextEditingController binText = TextEditingController();

  Future<void> modifyQuantity(int i, double nV) async {
    final item = context.read<MainAppState>().fileStorage[i];
    setState(() {
      item.quantity = nV;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MainAppState>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "File Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (appState.fileStorage.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      "List is empty",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: context.watch<MainAppState>().fileStorage.length,
                    itemBuilder: (context, index) {
                      var lstHist = context
                          .watch<MainAppState>()
                          .fileStorage[index];
                      return Card(
                        elevation: 5,
                        color: Colors.green,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 5.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${index + 1}. ${lstHist.barcode}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: Column(
                                          children: [
                                            Text(
                                              'Qty. ${lstHist.quantity.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            if (appState.binEnabled)
                                              Text(
                                                "Bin No. ${lstHist.binNumber}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          final shouldDelete =
                                              await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Are you sure?',
                                                  ),
                                                  content: const Text(
                                                    "You cannot undo this action!",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                          if (shouldDelete == true) {
                                            appState.deleteRecord(
                                              index,
                                              appState.fileStorage,
                                            );
                                          }
                                        },
                                      ),
                                    ],
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
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.2,
            maxChildSize: 0.4,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_upward),
                      const Text(
                        "Options",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        // Adds system bottom gesture bar height dynamically
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 8.0,
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize
                                  .min, // Prevents Column from expanding infinitely
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildButton(
                                        () => appState.downloadFile(
                                          context,
                                          appState.fileStorage,
                                        ),
                                        const Icon(Icons.download),
                                        const Text(
                                          "Download",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: buildButton(
                                        () async {
                                          final bool result = await appState
                                              .shareInfo(
                                                appState.fileStorage,
                                                2,
                                              );
                                          if (result && mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Information shared",
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                        const Icon(Icons.share),
                                        const Text(
                                          "Share",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildButton(
                                        () async {
                                          final deleteEverything =
                                              await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Delete everything?',
                                                      ),
                                                      content: const Text(
                                                        'This cannot be undone.',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              ),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              ),
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                          if (deleteEverything == true) {
                                            appState.clearEverything(
                                              appState.fileStorage,
                                            );
                                            appState.deleteBFFromDisk();
                                          }
                                        },
                                        const Icon(Icons.delete),
                                        const Text(
                                          "Delete All",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Consumer<MainAppState>(
                                        builder: (context, state, _) =>
                                            buildButton(
                                              () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const Settings(),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.settings,
                                                color: Colors.white,
                                              ), // Fixed Icon(null)
                                              const Text(
                                                "Settings",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Colors.green,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
