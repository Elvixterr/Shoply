import 'package:flutter/material.dart';

class TrashScreen extends StatelessWidget {
  final List<String> trashLists;

  const TrashScreen({super.key, required this.trashLists});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: trashLists.isEmpty
            ? const Center(
                child: Text('No deleted lists yet!',
                    style: TextStyle(fontSize: 18)),
              )
            : ListView.builder(
                itemCount: trashLists.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      title: Text(trashLists[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green),
                        onPressed: () {
                          // Restaurar la lista a la pantalla principal
                          // Aquí implementas la lógica para restaurar la lista
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
