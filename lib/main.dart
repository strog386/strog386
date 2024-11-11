import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:test_app/services/database_service.dart';
import 'package:test_app/widgets/label_widget.dart';
import 'package:test_app/models/item.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Label Printer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LabelScreen(),
    );
  }
}

class LabelScreen extends StatefulWidget {
  @override
  _LabelScreenState createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  final TextEditingController orderNrController = TextEditingController();
  Future<List<Item>>? items;
  final DatabaseService databaseService = DatabaseService('http://localhost:3000');

  Future<void> fetchData(int orderNr) async {
    try {
      List<Item> data = await databaseService.fetchData(orderNr);
      setState(() {
        items = Future.value(data);
      });
      print('Data loaded successfully');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load data');
    }
  }

  Future<void> scanBarcode() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BarcodeScannerScreen()));
    if (result != null) {
      int orderNr = int.parse(result);
      fetchData(orderNr);
    }
  }

  Future<void> printLabels(List<Item> items) async {
  final pdf = pw.Document();

  const double widthInches = 5.0;
  const double heightInches = 3.0;
  final pageWidth = widthInches * PdfPageFormat.inch; // 3 inches in points
  final pageHeight = heightInches * PdfPageFormat.inch; // 5 inches in points

  for (var item in items) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, pageHeight),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(12), // Increase padding for spacing
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Order number and barcode
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'ORDER # ${item.orderNr}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: item.itemNumber,
                      width: 100, // Adjusted for clear readability
                      height: 30,  // Increased height for clarity
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),

                // Item number
                pw.Text(
                  'ITEM # ${item.itemNumber}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                pw.SizedBox(height: 8),

                // Description
                pw.Center(
                child: pw.Column(
                  children: [
                pw.Text(
                  'DESCRIPTION: ${item.itemDescription}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 4),

                // Additional information section
                pw.Text(
                  'COLOR: __________',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 4),

                pw.Text(
                  'PLANT DATE: 1985-00-99',  // Example date placeholder
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
                ),
                ),
                pw.Spacer(),

                // Bottom row for QTY and Boxes
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '/999 QTY',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(
                      '/________ BOXES',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Send to printer
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Label Printer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: orderNrController,
              decoration: InputDecoration(
                labelText: 'Enter Order Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  int orderNr = int.parse(orderNrController.text);
                  fetchData(orderNr);
                },
                child: Text('Fetch Data'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  if (items != null) {
                    List<Item> itemList = await items!;
                    printLabels(itemList);
                  }
                },
                child: Text('Print Labels'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: scanBarcode,
                child: Text('Scan Barcode'),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Item>>(
              future: items,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return Center(child: Text('No items found for this Order Number.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return LabelWidget(item: snapshot.data![index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BarcodeScannerScreen extends StatelessWidget {
  final MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode'),
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (barcode, args) {
          if (barcode.rawValue != null) {
            final String code = barcode.rawValue!;
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}
