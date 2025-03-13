import 'package:flutter/material.dart';

class AddListScreen extends StatefulWidget {
  final Function(String, Color) addListCallback;
  final String? initialName;
  final Color? initialColor;

  const AddListScreen({
    super.key,
    required this.addListCallback,
    this.initialName,
    this.initialColor,
  });

  @override
  _AddListScreenState createState() => _AddListScreenState();
}

class _AddListScreenState extends State<AddListScreen> {
  late TextEditingController _nameController;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    selectedColor = widget.initialColor ?? Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialName != null ? "Edit List" : "Add New List"),
        actions: [
          TextButton(
            onPressed: () {
              final listName = _nameController.text.trim();
              if (listName.isNotEmpty) {
                widget.addListCallback(listName, selectedColor);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("List name cannot be empty."),
                  ),
                );
              }
            },
            child: const Text(
              "Done",
              style: TextStyle(
                color: Colors.purple, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: "List Name"),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: List.generate(
                Colors.primaries.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = Colors.primaries[index];
                    });
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.primaries[index],
                    child: selectedColor == Colors.primaries[index]
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

