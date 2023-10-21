import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRViewExample(),
    );
  }
}

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isDialogShowing = false; // Flag to track if a dialog is open

  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Eventrium Scanner")),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Barcode Type: ${describeEnum(result!.format)}')
                  : Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isDialogShowing) { // Check if a dialog is not already showing
        setState(() {
          result = scanData;
          if (result != null) {
            if (result!.code == "eventrium") {
              showGreenPopUp();
            } else {
              showUnauthorizedMessage();
            }
          }
        });
      }
    });
  }

  void showUnauthorizedMessage() {
    isDialogShowing = true; // Set the flag to indicate that a dialog is showing
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: Text(
            'Unauthorized Ticket',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'QR code is not an authorized ticket. Please ask the user to check again in their Eventrium ticket collection.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                isDialogShowing = false; // Reset the flag when the dialog is dismissed
              },
            ),
          ],
        );
      },
    );
  }

  void showGreenPopUp() {
    isDialogShowing = true; // Set the flag to indicate that a dialog is showing
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          title: Text(
            'Ticket verified',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Please authorize transaction with your Pera Wallet',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                isDialogShowing = false; // Reset the flag when the dialog is dismissed
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
