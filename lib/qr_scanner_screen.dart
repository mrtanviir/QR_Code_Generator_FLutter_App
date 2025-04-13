import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool hasPermission = false;
  bool isFlashOn = false;

  late MobileScannerController scannerController;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController();
    _checkPermission();
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status.isGranted;
    });
  }

  Future<void> _processScannedData(String? data) async {
    if (data == null) return;

    scannerController.stop();

    String type = 'text';
    if (data.startsWith('BEGIN:VCARD')) {
      type = 'contact';
    } else if (data.startsWith('http://') || data.startsWith('https://')) {
      type = 'url';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder:
                (context, controller) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        "Scanned Result:",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: controller,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                data,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              SizedBox(height: 24),
                              if (type == 'url')
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // _launchURL(data);
                                  },
                                  label: Text("Open URL"),
                                  icon: Icon(Icons.open_in_new),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size.fromHeight(50),
                                  ),
                                ),
                              if (type == 'contact')
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // _savedContact(data);
                                  },
                                  label: Text("Save Contact "),
                                  icon: Icon(Icons.open_in_new),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size.fromHeight(50),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Share.share(data);
                              },
                              icon: Icon(Icons.share),
                              label: Text("Share"),
                            ),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                scannerController.start();
                              },
                              icon: Icon(Icons.share),
                              label: Text("Scan Again"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _saveContact(String vcardData) async {
    final lines = vcardData.split('\n');
    String? name, phone, email;
    for (var line in lines) {
      if (line.startsWith('FN:')) name = line.substring(3);
      if (line.startsWith('TEL:')) phone = line.substring(3);
      if (line.startsWith('EMAIL:')) email = line.substring(3);
    }

    final contact =
        contacts.Contact()
          ..name.first = name ?? ''
          ..phones = [contacts.Phone(phone ?? '')]
          ..emails = [contacts.Email(email ?? '')];

    try {
      await contact.insert();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Contact saved successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save contact')));
    }
  }

  @override
  Widget build(BuildContext context) {
    //if permission is not granted or denied
    if (!hasPermission) {
      return Scaffold(
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: Text("Scanner"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 350,
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(height: 16),
                        Text("Camera Permission is required"),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _checkPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Grant Permission"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      //if permission is granted, you can start scanning
      return Scaffold(
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: Text("Scan QR Code"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isFlashOn = !isFlashOn;
                  scannerController.toggleTorch();
                });
              },
              icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: scannerController,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                if (barcode.rawValue != null) {
                  final String code = barcode.rawValue!;
                  _processScannedData(code);
                }
              },
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text('Align QR Code within the frame',style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                  ),),
              ))
          ],
        ),
      );
    }
  }
}
