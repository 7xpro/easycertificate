class CanvasField {
  final String id;
  final String name;
  double x;
  double y;
  bool placed;

  CanvasField({
    required this.id,
    required this.name,
    this.x = 0,
    this.y = 0,
    this.placed = false,
  });

  CanvasField copyWith({double? x, double? y, bool? placed}) {
    return CanvasField(
      id: id,
      name: name,
      x: x ?? this.x,
      y: y ?? this.y,
      placed: placed ?? this.placed,
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "x": x,
        "y": y,
      };
}