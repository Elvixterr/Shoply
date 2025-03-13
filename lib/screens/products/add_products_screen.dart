// ignore_for_file: empty_catches, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoply/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoply/screens/products/search_products_screen.dart';
import 'package:shoply/screens/products/view_products_screen.dart';

class AddProductsScreen extends StatefulWidget {
  final String listName;
  final String listId;
  final String userId;

  const AddProductsScreen({
    super.key,
    required this.listName,
    required this.listId,
    required this.userId,
  });

  @override
  _AddProductsScreenState createState() => _AddProductsScreenState();
}

class _AddProductsScreenState extends State<AddProductsScreen> {
  List<Map<String, dynamic>> products = [];
  List<String> markets = []; // Lista de nombres de mercados
  String? selectedMarket; // Mercado seleccionado

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchMarkets();
    _fetchSelectedMarket();
  }

  Future<void> _fetchProducts() async {
    try {
      final items = await getListItems(widget.userId, widget.listId);
      setState(() {
        products = items.map((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'note': item['note'],
            'price': item['price'],
            'quantity': item['quantity'],
          };
        }).toList();
      });
    } catch (e) {}
  }

  Future<void> _fetchMarkets() async {
    try {
      final querySnapshot = await BaseDeDatos.collection('Markets').get();
      final marketNames =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        markets = marketNames;
      });
    } catch (e) {}
  }

  Future<void> _fetchSelectedMarket() async {
    try {
      final marketDoc = await BaseDeDatos
          .collection('Account')
          .doc(widget.userId)
          .collection('List')
          .doc(widget.listId)
          .collection('Market')
          .doc('SelectedMarket')
          .get();

      if (marketDoc.exists) {
        setState(() {
          selectedMarket = marketDoc.data()?['name'];
        });
      }
    } catch (e) {}
  }

  Future<void> _updateMarket(String marketName) async {
    try {
      final marketRef = BaseDeDatos
          .collection('Account')
          .doc(widget.userId)
          .collection('List')
          .doc(widget.listId)
          .collection('Market')
          .doc('SelectedMarket');

      await marketRef.set({'name': marketName}, SetOptions(merge: true));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update market.')),
      );
    }
  }

Future<void> _addProduct(Map<String, dynamic> product) async {
  // Asegurarse de que quantity y price sean numéricos
  final int? quantity = int.tryParse(product['quantity'].toString());
  final double? price = double.tryParse(product['price'].toString());

  if (product['name'] == null || product['name'].toString().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product name cannot be empty.')),
    );
    return;
  }

  try {
    await addItemToList(widget.userId, widget.listId, {
      'item_name': product['name'],
      'item_note': product['note'],
      'item_price': price,
      'item_quantity': quantity,
    });
    setState(() {
      products.add(product);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to add product.')),
    );
  }
}


  void _searchProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchProductsScreen(
          onProductSelected: (name, quantity, price, note) {
            _addProduct({
              'name': name,
              'quantity': quantity,
              'price': price,
              'note': note,
            });
          },
        ),
      ),
    );
  }

  void _createProduct() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Center(
                  child: Text(
                    "Create a New Product",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 109, 11, 189),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle:
                        const TextStyle(color: Color.fromARGB(255, 109, 11, 189)),
                    prefixIcon: const Icon(Icons.edit,
                        color: Color.fromARGB(255, 109, 11, 189)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 109, 11, 189)),
                          prefixIcon: const Icon(Icons.format_list_numbered,
                              color: Color.fromARGB(255, 109, 11, 189)),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 109, 11, 189)),
                          prefixIcon: const Icon(Icons.attach_money,
                              color: Color.fromARGB(255, 109, 11, 189)),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    labelStyle:
                        const TextStyle(color: Color.fromARGB(255, 109, 11, 189)),
                    prefixIcon: const Icon(Icons.note,
                        color: Color.fromARGB(255, 109, 11, 189)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      final String name = nameController.text.trim();
                      final String note = noteController.text.trim();
                      final int quantity =
                          int.tryParse(quantityController.text.trim()) ?? 0;
                      final double price =
                          double.tryParse(priceController.text.trim()) ?? 0.0;

                      if (name.isNotEmpty) {
                        _addProduct({
                          'name': name,
                          'quantity': quantity,
                          'price': price,
                          'note': note,
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product name cannot be empty.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 109, 11, 189),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      'Add Product',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.listName,
              style: const TextStyle(
                  fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewProductsScreen(
                    listName: widget.listName,
                    marketName: selectedMarket,
                    products: products.map((product) {
                      return {
                        'name': product['name']?.toString() ?? '',
                        'quantity': product['quantity']?.toString() ?? '',
                        'price': product['price']?.toString() ?? '',
                        'note': product['note']?.toString() ?? '',
                      };
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedMarket,
                  items: markets.map((market) {
                    return DropdownMenuItem(
                      value: market,
                      child: Text(market),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMarket = value;
                    });
                    if (value != null) {
                      _updateMarket(value);
                    }
                  },
                  hint: const Text("Select Market"),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color.fromARGB(255, 0, 0, 0)),
                  style:
                      const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  underline: Container(
                    height: 2,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text(
                        'No products added yet!',
                        style:
                            TextStyle(fontSize: 18.0, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4.0,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ListTile(
                            leading: const Icon(Icons.shopping_cart),
                            title: Text(products[index]['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Quantity: ${products[index]['quantity']}'),
                                Text(
                                    'Price: ${products[index]['price']}'),
                                if (products[index]['note'] != null &&
                                    products[index]['note'].isNotEmpty)
                                  Text('Note: ${products[index]['note']}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () async {
                                try {
                                  await deleteItemFromList(
                                      widget.userId,
                                      widget.listId,
                                      products[index]['id']);
                                  setState(() {
                                    products.removeAt(index);
                                  });
                                } catch (e) {}
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: _createProduct,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  "Create Product",
                  style:
                      TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _searchProducts,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                "Search Products",
                style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
