import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[200],
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildDraggable('Text Field'),
          _buildDraggable('Dropdown'),
          _buildDraggable('Checkbox'),
          _buildDraggable('Radio Button'),
          _buildDraggable('Date Picker'),
        ],
      ),
    );
  }

  Widget _buildDraggable(String fieldType) {
    return Draggable<String>(
      data: fieldType,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(fieldType),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(fieldType),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(fieldType),
      ),
    );
  }
}
