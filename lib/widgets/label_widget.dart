import 'package:flutter/material.dart';
import 'package:test_app/models/item.dart';
import 'package:barcode_widget/barcode_widget.dart';

class LabelWidget extends StatelessWidget {
  final Item item;

  LabelWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5 * 96.0, // 5 inches in pixels (assuming 96 DPI)
      height: 3 * 96.0, // 3 inches in pixels (assuming 96 DPI)
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER # ${item.orderNr}',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              BarcodeWidget(
                barcode: Barcode.code128(), // Barcode type and settings
                data: item.itemNumber, // Data to encode
                width: 200,
                height: 50,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('ITEM # ${item.itemNumber}', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('DESCRIPTION ${item.itemDescription}', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('COLOR', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('PLANT DATE 1985-00-99', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('/999 QTY', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('/________ BOXES', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
