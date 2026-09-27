import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/CanvasField.dart';

class CertificateCanvas extends StatefulWidget {
  final String templateImageUrl;
  const CertificateCanvas({super.key, required this.templateImageUrl});

  @override
  State<CertificateCanvas> createState() => _CertificateCanvasState();
}

  class _CertificateCanvasState extends State<CertificateCanvas> {
  final GlobalKey _canvasKey = GlobalKey();
  final String? _host = dotenv.env["HOST"];

  // Start every field in the palette (placed = false).
  List<CanvasField> fields = [
    CanvasField(id: "name", name: "Name"),
    CanvasField(id: "date", name: "Date"),
    CanvasField(id: "course", name: "Course"),
  ];

  final List<List<CanvasField>> _undoStack = [];
  final List<List<CanvasField>> _redoStack = [];

  Size? canvasSize;

    List<CanvasField> _clone(List<CanvasField> list) =>
      List<CanvasField>.from(list.map<CanvasField>((f) => f.copyWith()));

  void _pushUndo() {
    _undoStack.add(_clone(fields));
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _redoStack.add(_clone(fields));
      fields = _undoStack.removeLast();
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _undoStack.add(_clone(fields));
      fields = _redoStack.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paletteFields = fields.where((f) => !f.placed).toList();
    final placedFields = fields.where((f) => f.placed).toList();

    return Column(
      children: [
        _buildPalette(paletteFields),
        const SizedBox(height: 12),
        Expanded(child: _buildCanvas(placedFields)),
        const SizedBox(height: 12),
        _buildToolbar(),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------- Palette (untouched fields) ----------

  Widget _buildPalette(List<CanvasField> paletteFields) {
    return SafeArea(child:  Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: paletteFields.isEmpty
          ? const Text(
              "",
              style: TextStyle(color: Colors.grey),
            )
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: paletteFields.map((field) {
                return Draggable<CanvasField>(
                  data: field,
                  feedback: _fieldChip(field, dragging: true),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _fieldChip(field),
                  ),
                  child: _fieldChip(field),
                );
              }).toList(),
            ),
    ),
    );
  }

  Widget _fieldChip(CanvasField field, {bool dragging = false}) {
    return Material(
      color: const Color.fromARGB(0, 192, 192, 192),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: dragging
              ? Colors.blue.withOpacity(0.9)
              : Colors.blue.withOpacity(0.7),
          borderRadius: BorderRadius.circular(6),
          boxShadow: dragging
              ? [const BoxShadow(color: Color.fromARGB(66, 128, 128, 128), blurRadius: 6)]
              : null,
        ),
        child: Text(field.name, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ---------- Canvas (placed fields) ----------

  Widget _buildCanvas(List<CanvasField> placedFields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        return DragTarget<CanvasField>(
          onAcceptWithDetails: (details) {
            final box =
                _canvasKey.currentContext!.findRenderObject() as RenderBox;
            final local = box.globalToLocal(details.offset);

            _pushUndo();
            setState(() {
              final field =
                  fields.firstWhere((f) => f.id == details.data.id);
              field.x = local.dx.clamp(0, canvasSize!.width - 20);
              field.y = local.dy.clamp(0, canvasSize!.height - 20);
              field.placed = true;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              key: _canvasKey,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.templateImageUrl),
                  fit: BoxFit.contain,
                ),
                border: Border.all(
                  color:
                      candidateData.isNotEmpty ? Colors.green : Colors.black,
                  width: candidateData.isNotEmpty ? 2 : 1,
                ),
              ),
              child: Stack(
                children: placedFields.map((field) {
                  return Positioned(
                    left: field.x,
                    top: field.y,
                    child: GestureDetector(
                      onPanStart: (_) => _pushUndo(),
                      onPanUpdate: (details) {
                        setState(() {
                          field.x = (field.x + details.delta.dx)
                              .clamp(0, canvasSize!.width - 20);
                          field.y = (field.y + details.delta.dy)
                              .clamp(0, canvasSize!.height - 20);
                        });
                      },
                      child: Container(
                       
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              field.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              
                              
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeFromCanvas(field),
                              child: const Icon(
                                Icons.close,
                                size:20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _removeFromCanvas(CanvasField field) {
    _pushUndo();
    setState(() {
      field.placed = false;
      field.x = 0;
      field.y = 0;
    });
  }

  // ---------- Toolbar ----------

  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _undoStack.isEmpty ? null : _undo,
          icon: const Icon(Icons.undo),
          tooltip: "Undo",
        ),
        IconButton(
          onPressed: _redoStack.isEmpty ? null : _redo,
          icon: const Icon(Icons.redo),
          tooltip: "Redo",
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _sendCoordinates,
          child: const Text("Save Field Positions"),
        ),
      ],
    );
  }

  // ---------- Send only placed fields ----------

  Future<void> _sendCoordinates() async {
    final placedFields = fields.where((f) => f.placed).toList();

    if (placedFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No fields placed to save.")),
    );
      return;
    }
    final payload = {
      "cordinates": {
        "fields": placedFields.map((f) => f.toJson()).toList(),
        "canvas_width": canvasSize?.width,
        "canvas_height": canvasSize?.height,
      }
    };

    debugPrint("Sending payload: ${jsonEncode(payload)}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saving positions...")),
    );
    
    final response = await http.post(
      Uri.parse("$_host/upload/cordinates"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Positions saved")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to save")));
    }
  }
}