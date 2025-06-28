import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kimiflash/pages/widgets/signature_pad.dart';

class SignaturePreview extends StatefulWidget {
  const SignaturePreview({Key? key, this.onSignatureChanged}) : super(key: key);
  final ValueChanged<String?>? onSignatureChanged;

  @override
  State<SignaturePreview> createState() => _SignaturePreviewState();
}

class _SignaturePreviewState extends State<SignaturePreview> {
  String? _signatureUrl;

  void _showSignatureDialog(BuildContext context) async {
    final result = await showDialog<String>(
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
                  onUploadSuccess: (url) {
                    Navigator.of(context).pop(url);
                    print("输入结果===={$url}");
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
        _signatureUrl = result;
      });
      widget.onSignatureChanged?.call(_signatureUrl); // 添加这行
    }
  }

  void _clearSignature() {
    setState(() {
      _signatureUrl = null;
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
            child: _signatureUrl == null
                ? Center(child: Text('点击此处签名', style: TextStyle(color: Colors.grey)))
                : Image.network(_signatureUrl!),
          ),
        ),
        if (_signatureUrl != null)
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
