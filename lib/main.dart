import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, isHovered, adjacentHover) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: isHovered
                    ? 80
                    : adjacentHover
                        ? 60
                        : 48,
                width: isHovered
                    ? 80
                    : adjacentHover
                        ? 60
                        : 48,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:
                      Colors.primaries[icon.hashCode % Colors.primaries.length],
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isHovered ? 40 : 28,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item and hover state.
  final Widget Function(T, bool isHovered, bool adjacentHover) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          _items.length,
          (index) => Draggable<T>(
            data: _items[index],
            feedback: Material(
              color: Colors.transparent,
              child: widget.builder(_items[index], true, false),
            ),
            childWhenDragging: const SizedBox.shrink(),
            onDragEnd: (details) {
              setState(() => _hoveredIndex = null);
            },
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _hoveredIndex = index);
              },
              onExit: (_) {
                setState(() => _hoveredIndex = null);
              },
              child: DragTarget<T>(
                onAccept: (data) {
                  setState(() {
                    final currentIndex = _items.indexOf(data);
                    _items.removeAt(currentIndex);
                    _items.insert(index, data);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovered = _hoveredIndex == index;
                  final adjacentHover = _hoveredIndex != null &&
                      (index - _hoveredIndex!).abs() == 1;
                  return widget.builder(
                      _items[index], isHovered, adjacentHover);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
