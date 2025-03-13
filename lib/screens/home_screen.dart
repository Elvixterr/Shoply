// ignore_for_file: empty_catches, use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shoply/screens/community/community_screen.dart';
import 'list/add_list_screen.dart';
import 'products/add_products_screen.dart';
import 'package:shoply/services/firebase_service.dart';
import 'package:shoply/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  final String password;
  final String id;
  final String username;

  const HomeScreen({
    super.key,
    required this.email,
    required this.password,
    required this.id,
    required this.username,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> shoppingLists = [];

  @override
  void initState() {
    super.initState();
    _fetchUserLists();
  }

  Future<void> _fetchUserLists() async {
  try {
    final lists = await getUserLists(widget.id);
    if (lists.isNotEmpty) {
      setState(() {
        shoppingLists = lists.map((list) {
          return {
            'id': list['id'] ?? '',
            'name': list['name'] ?? 'Unnamed List',
            'color': list.containsKey('color') ? Color(list['color']) : Colors.blue, // Convertir el valor ARGB
          };
        }).toList();
      });
    }
  } catch (e) {
  }
}

Future<void> _addList(String listName, Color listColor) async {
  try {
    // Subir el color en formato ARGB como un entero
    final docRef = await FirebaseFirestore.instance
        .collection('Account')
        .doc(widget.id)
        .collection('List')
        .add({
      'list_name': listName,
      'list_color': listColor.value, // Guardar el valor ARGB como entero
      'created_at': FieldValue.serverTimestamp(),
    });

    // Actualiza la lista localmente
    setState(() {
      shoppingLists.add({
        'id': docRef.id,
        'name': listName,
        'color': listColor, // Aquí mantenemos el objeto Color
      });
    });
  } catch (e) {
  }
}

Future<void> _confirmDeleteList(String listId, int index) async {
  final confirmation = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete List"),
        content: const Text("Are you sure you want to delete this list?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancelar
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirmar
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );

  if (confirmation == true) {
    await _deleteList(listId, index);
  }
}

 Future<void> _deleteList(String listId, int index) async {
  try {
    await deleteListFromUser(widget.id, listId);
    setState(() {
      shoppingLists.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('List deleted successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete the list. Please try again.')),
    );
  }
}
  Future<void> _shareListToCommunity(String listId, String listName) async {
  try {
    // Obtener los items de la lista
    final itemsSnapshot = await FirebaseFirestore.instance
        .collection('Account')
        .doc(widget.id)
        .collection('List')
        .doc(listId)
        .collection('items')
        .get();

    // Calcular el total
    double total = 0;
    for (var item in itemsSnapshot.docs) {
      final price = double.tryParse(item['item_price'].toString()) ?? 0.0;
      final quantity = int.tryParse(item['item_quantity'].toString()) ?? 0;
      total += price * quantity;
    }

    // Obtener el supermercado asociado a la lista
    final marketSnapshot = await FirebaseFirestore.instance
        .collection('Account')
        .doc(widget.id)
        .collection('List')
        .doc(listId)
        .collection('Market')
        .doc('SelectedMarket') // Asumiendo que este es el ID del documento del supermercado seleccionado
        .get();

    String? marketName;
    if (marketSnapshot.exists) {
      marketName = marketSnapshot['name']; // Extraer el nombre del supermercado
    }

    // Confirmación del usuario
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Share List"),
        content: Text(
          "Are you sure you want to share the list \"$listName\" to the community?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Share"),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      // Subir la lista a CommunityLists
      await FirebaseFirestore.instance.collection('CommunityLists').doc(listId).set({
        'list-Id': listId,
        'user-Id': widget.id,
        'listName': listName,
        'market': marketName ?? 'No Market', // Incluye el supermercado
        'total': total,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('List shared to community!')),
      );
    }
  } catch (e) {
  }
}



@override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: WillPopScope(
      onWillPop: () async => false, // Deshabilita el botón de retroceso
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Elimina la flecha de retroceso
          centerTitle: true,
          title: const Text(
            "WELCOME TO SHOPLY",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "My Lists"),
              Tab(text: "Community"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pantalla de listas personales con pull-to-refresh
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        // Llama a la función para obtener las listas actualizadas
                        await _fetchUserLists();
                      },
                      child: shoppingLists.isEmpty
                          ? const Center(
                              child: Text(
                                'No lists created yet!',
                                style: TextStyle(fontSize: 18.0, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: shoppingLists.length,
                              itemBuilder: (context, index) {
                                final list = shoppingLists[index];
                                return Slidable(
                                  key: Key(list['id']),
                                  endActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    extentRatio: 0.7,
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddListScreen(
                                                addListCallback: (updatedName, updatedColor) async {
                                                  await updateListInUser(
                                                    widget.id,
                                                    list['id'], // ID de la lista
                                                    updatedName, // Nombre actualizado
                                                    updatedColor
                                                  );
                                                  await _fetchUserLists();
                                                },
                                                initialName: list['name'], // Nombre actual
                                                initialColor: list['color'], // Color actual
                                              ),
                                            ),
                                          );
                                          await _fetchUserLists();
                                        },
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit,
                                      ),
                                      SlidableAction(
                                        onPressed: (context) =>
                                            _shareListToCommunity(list['id'], list['name']),
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        icon: Icons.share,
                                      ),
                                      SlidableAction(
                                        onPressed: (context) =>
                                            _confirmDeleteList(list['id'], index),
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    elevation: 4.0,
                                    margin: const EdgeInsets.only(bottom: 16.0),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: list['color'],
                                      ),
                                      title: Text(list['name']),
                                      subtitle: const Text('Tap to add products'),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddProductsScreen(
                                              listName: list['name'],
                                              listId: list['id'],
                                              userId: widget.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddListScreen(
                            addListCallback: (listName, listColor) async {
                              await _addList(listName, listColor);
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Add List', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            CommunityScreen(userId: widget.id),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          userId: widget.id,
                          username: widget.username,
                          email: widget.email,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.blue),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/settings',
                      arguments: {
                        'userId': widget.id,
                        'username': widget.username,
                        'email': widget.email,
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
