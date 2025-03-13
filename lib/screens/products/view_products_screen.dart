import 'package:flutter/material.dart';

class ViewProductsScreen extends StatelessWidget {
  final String listName;
  final String? marketName; // Nuevo parámetro opcional
  final List<Map<String, String>> products;

  const ViewProductsScreen({
    super.key,
    required this.listName,
    this.marketName, // Aceptar el market seleccionado
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              listName,
              style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (marketName != null) // Mostrar solo si hay un market seleccionado
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'MARKET: $marketName',
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            const SizedBox(height: 16.0),
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found!',
                        style: TextStyle(fontSize: 18.0, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          elevation: 4.0,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ListTile(
                            leading: const Icon(Icons.shopping_cart),
                            title: Text(product['name'] ?? 'Unknown'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantity: ${product['quantity']}'),
                                Text('Price: ${product['price']}'),
                                if (product['note'] != null && product['note']!.isNotEmpty)
                                  Text('Note: ${product['note']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

