import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PdfUploadWidget extends StatefulWidget {
  const PdfUploadWidget({super.key});
  

  @override
  State<PdfUploadWidget> createState() => _PdfUploadWidgetState();
}

class _PdfUploadWidgetState extends State<PdfUploadWidget> {
  final _host = dotenv.env["HOST"];
  File? _selectedFile;
  bool _isUploading = false;
  String _statusMessage = '';

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // restricts picker to PDFs only
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _statusMessage = '';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    // Extra safety check in case picker allows override on some platforms
    if (!_selectedFile!.path.toLowerCase().endsWith('.pdf')) {
      setState(() => _statusMessage = 'Only PDF files are allowed.');
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = '';
    });

    try {
      final uri = Uri.parse('$_host/upload/template'); // e.g. Flask endpoint
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // this key must match request.files['file'] on Flask side
          _selectedFile!.path,
          contentType: MediaType('application', 'pdf'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        setState(() => _statusMessage = 'Upload successful!');
        // return Text(response);
          
        
      } else {
        setState(() => _statusMessage = 'Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _pickPdf,
          child: const Text('Select PDF'),
        ),
        if (_selectedFile != null)
          Text('Selected: ${_selectedFile!.path.split('/').last}'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadFile,
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Upload'),
        ),
        if (_statusMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(_statusMessage),
          ),
      ],
    );
  }
}