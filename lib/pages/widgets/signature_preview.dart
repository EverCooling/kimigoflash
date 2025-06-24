import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kimiflash/pages/widgets/signature_pad.dart';

class SignaturePreview extends StatefulWidget {
  const SignaturePreview({Key? key, this.onSignatureChanged}) : super(key: key);
  final ValueChanged<Uint8List?>? onSignatureChanged;

  @override
  State<SignaturePreview> createState() => _SignaturePreviewState();
}

class _SignaturePreviewState extends State<SignaturePreview> {
  Uint8List? _signatureBytes;

  void _showSignatureDialog(BuildContext context) async {
    final result = await showDialog<Uint8List>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300,
                child: SyncfusionSignaturePadWidget(
                  onSaved: (bytes) {
                    Navigator.of(context).pop(bytes);
                  },
                ),
              ),
              // const SizedBox(height: 16),
              // Text('请在上方签名'),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _signatureBytes = result;
      });
      widget.onSignatureChanged?.call(result); // 添加这行
    }
  }

  void _clearSignature() {
    setState(() {
      _signatureBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('客户签字板', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: () => _showSignatureDialog(context),
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: _signatureBytes == null
                ? Center(child: Text('点击此处签名', style: TextStyle(color: Colors.grey)))
                : Image.memory(_signatureBytes!),
          ),
        ),
        if (_signatureBytes != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _clearSignature,
                icon: Icon(Icons.delete_outline, color: Colors.red),
              ),
            ),
          )
      ],
    );
  }
}
