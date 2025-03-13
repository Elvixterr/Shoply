// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoply/services/firebase_service.dart';

class SearchProductsScreen extends StatefulWidget {
  final Function(String name, String quantity, String price, String note) onProductSelected;

  const SearchProductsScreen({super.key, required this.onProductSelected});

  @override
  _SearchProductsScreenState createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showCategories = false;
  final TextEditingController _searchController = TextEditingController();
  final List<String> selectedProductTitles = [];
  List<Map<String, dynamic>> popularProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        showCategories = _tabController.index == 1;
      });
    });

    _searchController.addListener(() {
      _searchProducts(_searchController.text);
    });

    _fetchPopularProducts(); // Cargar los productos populares al iniciar
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPopularProducts() async {
    try {
      final products = await getPopularProducts();
      setState(() {
        popularProducts = products;
      });
    } catch (e) {
      print("Error al cargar productos populares: $e");
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      // Si la barra de búsqueda está vacía, cargar productos populares
      _fetchPopularProducts();
      return;
    }

    try {
      final querySnapshot = await BaseDeDatos.collection('Products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff') 
          .get();

      setState(() {
        popularProducts = querySnapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'category': doc['category'],
          };
        }).toList();
      });
    } catch (e) {
      print("Error al buscar productos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search product',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    _fetchPopularProducts(); 
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16.0),
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.purple,
              unselectedLabelColor: Colors.purple,
              tabs: const [
                Tab(text: 'Popular'),
                Tab(text: 'Catalog'),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: showCategories ? _buildCategoryList() : _buildPopularProducts(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularProducts() {
    if (popularProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products found!',
          style: TextStyle(fontSize: 18.0, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: popularProducts.length,
      itemBuilder: (context, index) {
        final product = popularProducts[index];
        return _ProductItem(
          title: product['name'],
          category: product['category'],
          isSelected: selectedProductTitles.contains(product['name']),
          onProductSelected: widget.onProductSelected,
          onSelect: (String title) {
            setState(() {
              selectedProductTitles.add(title);
            });
          },
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return FutureBuilder<List<String>>(
      future: getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No categories found!', style: TextStyle(fontSize: 18.0, color: Colors.grey)),
          );
        }
        final categories = snapshot.data!;
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _CategoryItem(
              title: categories[index],
              onTap: () => _showProductsByCategory(categories[index]),
            );
          },
        );
      },
    );
  }

  void _showProductsByCategory(String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => _ProductsByCategorySheet(
        category: category,
        onProductSelected: widget.onProductSelected,
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final String title;
  final String category;
  final bool isSelected;
  final Function(String name, String quantity, String price, String note) onProductSelected;
  final Function(String) onSelect;

  const _ProductItem({
    required this.title,
    required this.category,
    required this.isSelected,
    required this.onProductSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.add,
        color: Colors.purple,
      ),
      title: Text(title),
      subtitle: Text('in $category'),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          builder: (context) => _ProductDetailSheet(
            title: title,
            category: category,
            onProductAdded: (qty, price, note) {
              onProductSelected(title, qty, price, note);
              onSelect(title);
            },
          ),
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CategoryItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple.withOpacity(0.2),
        child: const Icon(Icons.category, color: Colors.purple),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class _ProductDetailSheet extends StatefulWidget {
  final String title;
  final String category;
  final Function(String, String, String) onProductAdded;

  const _ProductDetailSheet({
    required this.title,
    required this.category,
    required this.onProductAdded,
  });

  @override
  _ProductDetailSheetState createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  int quantity = 1;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (quantity > 0) quantity--;
    });
  }

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(
      top: 0.1,
      left: 0.1,
      right: 0.1,
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 109, 11, 189),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onProductAdded(
                        quantity.toString(),
                        _priceController.text,
                        _noteController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("Done", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.category, color: Colors.green[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.category,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Qty', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 109, 11, 189))),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Color.fromARGB(255, 109, 11, 189)),
                    onPressed: _decrementQuantity,
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 109, 11, 189)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color.fromARGB(255, 109, 11, 189)),
                    onPressed: _incrementQuantity,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: TextField(
            controller: _priceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), // Permite solo números decimales
            ],
            decoration: const InputDecoration(
              labelText: 'Price',
              labelStyle: TextStyle(color: Color.fromARGB(255, 109, 11, 189)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 109, 11, 189)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note',
              labelStyle: TextStyle(color: Color.fromARGB(255, 109, 11, 189)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 109, 11, 189)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
}

class _ProductsByCategorySheet extends StatelessWidget {
  final String category;
  final Function(String name, String quantity, String price, String note) onProductSelected;

  const _ProductsByCategorySheet({
    required this.category,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 0.0,
          left: 0.1,
          right: 0.1,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity, // Asegura que el contenedor cubra toda la anchura
              decoration: const BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center( // Centra el texto dentro del contenedor
                  child: Text(
                    'Products in $category',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center, // Centra el texto horizontalmente
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getProductsByCategory(category), // Llamar a la función para obtener productos
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No products found!', style: TextStyle(fontSize: 18.0, color: Colors.grey)),
                  );
                }
                final products = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true, // Permite que la lista se ajuste al contenido
                  physics: const NeverScrollableScrollPhysics(), // Evita el desplazamiento dentro de la lista
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductItem(
                      title: product['name'],
                      category: product['category'],
                      isSelected: false,
                      onProductSelected: onProductSelected,
                      onSelect: (_) {},
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
