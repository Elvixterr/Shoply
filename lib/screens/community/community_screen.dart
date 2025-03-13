// ignore_for_file: empty_catches, duplicate_ignore, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CommunityScreen extends StatefulWidget {
  final String userId;

  const CommunityScreen({super.key, required this.userId});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Map<String, dynamic>> communityLists = [];
  String searchQuery = '';
  String? selectedMarket;
  double? minTotal;
  double? maxTotal;
  List<String> availableMarkets = []; 

  @override
  void initState() {
    super.initState();
    _fetchCommunityLists();
    _fetchMarkets(); // Cargar mercados 
  }

  Future<void> _fetchCommunityLists() async {
    try {
      final communitySnapshot =
          await FirebaseFirestore.instance.collection('CommunityLists').get();

      List<Map<String, dynamic>> lists = [];
      for (var doc in communitySnapshot.docs) {
        if (!doc.data().containsKey('list-Id') ||
            !doc.data().containsKey('user-Id') ||
            !doc.data().containsKey('total')) {
          continue;
        }

        final listId = doc['list-Id'];
        final userId = doc['user-Id'];
        final total = doc['total'];
        String market = 'No Market';

        if (listId.isEmpty || userId.isEmpty) {
          continue;
        }

        try {
          final marketSnapshot = await FirebaseFirestore.instance
              .collection('Account')
              .doc(userId)
              .collection('List')
              .doc(listId)
              .collection('Market')
              .get();

          if (marketSnapshot.docs.isNotEmpty) {
            market = marketSnapshot.docs.first.data()['name'] ?? 'Unknown Market';
          }
        // ignore: empty_catches
        } catch (e) {
        }

        final userDoc =
            await FirebaseFirestore.instance.collection('Account').doc(userId).get();

        if (!userDoc.exists) {
          continue;
        }

        final listDoc = await FirebaseFirestore.instance
            .collection('Account')
            .doc(userId)
            .collection('List')
            .doc(listId)
            .get();

        if (!listDoc.exists) {
          continue;
        }

        lists.add({
          'listId': listId,
          'userId': userId,
          'listName': listDoc['list_name'] ?? 'Unnamed List',
          'username': userDoc['username'] ?? 'Unknown User',
          'total': total,
          'market': market,
        });
      }

      setState(() {
        communityLists = lists;
      });
    } catch (e) {
    }
  }

Future<void> _fetchMarkets() async {
  try {
    final marketsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('Market')
        .get();

    setState(() {
      availableMarkets = ['All']; 
      availableMarkets.addAll(marketsSnapshot.docs
          .map((doc) => doc['name'] as String)
          .toSet()
          .toList());
    });
  } catch (e) {
    print('Error fetching markets: $e');
  }
}

  List<Map<String, dynamic>> get filteredLists {
    return communityLists.where((list) {
      final matchesSearchQuery = searchQuery.isEmpty ||
          list['listName'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesMarket = selectedMarket == null ||
          selectedMarket!.isEmpty ||
          list['market'] == selectedMarket;
      final matchesMinTotal = minTotal == null || list['total'] >= minTotal!;
      final matchesMaxTotal = maxTotal == null || list['total'] <= maxTotal!;

      return matchesSearchQuery && matchesMarket && matchesMinTotal && matchesMaxTotal;
    }).toList();
  }

Future<void> _addListToPersonal(String sourceUserId, String sourceListId) async {
  try {
    final sourceListDoc = FirebaseFirestore.instance
        .collection('Account')
        .doc(sourceUserId)
        .collection('List')
        .doc(sourceListId);

    final sourceListSnapshot = await sourceListDoc.get();
    if (!sourceListSnapshot.exists) {
      throw Exception("La lista original no existe.");
    }

    final newListRef = FirebaseFirestore.instance
        .collection('Account')
        .doc(widget.userId)
        .collection('List')
        .doc(); 

    await newListRef.set({
      'list_name': sourceListSnapshot['list_name'],
      'list_color': sourceListSnapshot['list_color'],
      'created_at': FieldValue.serverTimestamp(),
    });

    // Clonar la subcolección `items`
    final itemsSnapshot = await sourceListDoc.collection('items').get();
    for (var itemDoc in itemsSnapshot.docs) {
      await newListRef.collection('items').add(itemDoc.data());
    }

    // Clonar la subcolección `Market`
    final marketSnapshot = await sourceListDoc.collection('Market').get();
    for (var marketDoc in marketSnapshot.docs) {
    await newListRef.collection('Market').doc('SelectedMarket').set(marketDoc.data());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('List added to your personal lists!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to add the list. Please try again.')),
    );
  }
}


  void _showListDetails(Map<String, dynamic> list) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: FutureBuilder(
            future: _fetchListDetails(list['userId'], list['listId']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final listDetails = snapshot.data as Map<String, dynamic>;
              return Padding(
                padding: EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      list['listName'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                          'Shared by: ${list['username']}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                    const SizedBox(height: 8),
                    Text(
                          'Market: ${list['market']}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                    const SizedBox(height: 16),
                    TabBar(
                      indicatorColor: Colors.purple,
                      tabs: const [
                        Tab(icon: Icon(Icons.shopping_cart), text: 'Products'),
                        Tab(icon: Icon(Icons.comment), text: 'Comments'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildProductsTab(listDetails['products']),
                          _buildCommentsTab(list['listId']),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchListDetails(
      String userId, String listId) async {
    try {
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection('Account')
          .doc(userId)
          .collection('List')
          .doc(listId)
          .collection('items')
          .get();

      final products = itemsSnapshot.docs.map((doc) {
        return {
          'name': doc['item_name'],
          'quantity': int.tryParse(doc['item_quantity'].toString()) ?? 0,
          'price': double.tryParse(doc['item_price'].toString()) ?? 0.0,
        };
      }).toList();

      return {'products': products};
    } catch (e) {
      return {'products': []};
    }
  }

  Widget _buildProductsTab(List<Map<String, dynamic>> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[100],
            child: const Icon(Icons.shopping_cart, color: Colors.green),
          ),
          title: Text(product['name']),
          subtitle: Text(
              'Quantity: ${product['quantity']} - \$${(product['quantity'] * product['price']).toStringAsFixed(2)}'),
        );
      },
    );
  }

  Widget _buildCommentsTab(String listId) {
  final TextEditingController commentController = TextEditingController();

  return Column(
    children: [
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('CommunityLists')
              .doc(listId)
              .collection('comments')
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data!.docs.map((doc) {
              return {
                'username': doc['username'] ?? 'Unknown User',
                'comment': doc['comment'] ?? 'No comment provided',
                'timestamp': (doc['timestamp'] as Timestamp?)?.toDate(),
                'userId': doc['userId'] ?? '',
              };
            }).toList();

            return ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return FutureBuilder<String?>(
                  future: _fetchUserProfileImage(comment['userId']),
                  builder: (context, snapshot) {
                    final imageProvider = snapshot.hasData && snapshot.data != null
                        ? _getProfileImage(snapshot.data!)
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple[200],
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? Text(
                                  comment['username']!.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        title: Text(
                          comment['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4.0),
                            Text(
                              comment['comment'],
                              style: const TextStyle(fontSize: 14.0),
                            ),
                            const SizedBox(height: 6.0),
                            if (comment['timestamp'] != null)
                              Text(
                                _formatTimestamp(comment['timestamp']),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: () {
                final comment = commentController.text.trim();
                if (comment.isNotEmpty) {
                  _addComment(listId, comment);
                  commentController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comment cannot be empty'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    ],
  );
}

Future<String?> _fetchUserProfileImage(String userId) async {
  try {
    final userDoc = await FirebaseFirestore.instance.collection('Account').doc(userId).get();
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc['picture']; 
    }
    return null;
  } catch (e) {
    return null;
  }
}

ImageProvider<Object>? _getProfileImage(String? base64Image) {
  if (base64Image == null || base64Image.isEmpty) {
    return null; 
  }
  try {
    final bytes = base64Decode(base64Image);
    return MemoryImage(bytes);
  } catch (e) {
    return null;
  }
}


String _formatTimestamp(DateTime? timestamp) {
  if (timestamp == null) return 'Unknown Date';
  return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
}



void _addComment(String listId, String comment) async {
  final username = await _fetchCurrentUsername(widget.userId);
  final userId = widget.userId;

  if (username.isEmpty || comment.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Comment cannot be empty, or error fetching user details.'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('CommunityLists')
        .doc(listId)
        .collection('comments')
        .add({
      'username': username,
      'userId': userId,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(), 
    });

    setState(() {}); // Actualizar la interfaz 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment added successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error adding comment. Please try again.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

  Future<String> _fetchCurrentUsername(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Account')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['username'] ?? 'Unknown User';
      }
    } catch (e) {
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final filteredLists = communityLists
        .where((list) => list['listName']
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
    return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search community lists...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.purple.shade50,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.purple),
              onPressed: () => _showAdvancedSearch(context),
            ),
          ],
        ),
      ),
      Expanded(
        child: filteredLists.isEmpty
            ? const Center(
                child: Text(
                  'No lists found!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                itemCount: filteredLists.length,
                itemBuilder: (context, index) {
                  final list = filteredLists[index];
                  return Slidable(
                    key: Key(list['listId']),
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) =>
                              _addListToPersonal(list['userId'], list['listId']),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.add,
                        ),
                      ],
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 4.0,
                      child: InkWell(
                        onTap: () => _showListDetails(list),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list['listName'],
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Shared by: ${list['username']}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Market: ${list['market']}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blueGrey[600],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Total: \$${list['total'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    ],
  );
}

void _showAdvancedSearch(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      String sortOrder = "ascending"; // Controla el orden del precio

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.purple.shade50,
            title: const Text(
              'Advanced Search',
              style: TextStyle(color: Colors.purple),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Supermarket',
                      labelStyle: const TextStyle(color: Colors.purple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.purple.shade300),
                      ),
                    ),
                    value: selectedMarket,
                    items: availableMarkets
                        .map((market) => DropdownMenuItem(
                              value: market,
                              child: Text(market),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedMarket = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sort by Total Price:",
                    style: TextStyle(color: Colors.purple, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setDialogState(() {
                            sortOrder = "ascending";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sortOrder == "ascending"
                              ? Colors.purple
                              : Colors.grey.shade300,
                          foregroundColor: sortOrder == "ascending"
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: const Text('Ascending'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setDialogState(() {
                            sortOrder = "descending";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sortOrder == "descending"
                              ? Colors.purple
                              : Colors.grey.shade300,
                          foregroundColor: sortOrder == "descending"
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: const Text('Descending'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _applyFilters(sortOrder); // Realiza la consulta con el orden especificado
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _applyFilters(String sortOrder) async {
  try {
    Query filteredQuery = FirebaseFirestore.instance.collection('CommunityLists');

    // Si hay un mercado seleccionado y no es 'All', aplica el filtro del mercado
    if (selectedMarket != null && selectedMarket != 'All') {
      filteredQuery = filteredQuery.where('market', isEqualTo: selectedMarket);
    }

    filteredQuery = filteredQuery.orderBy('total', descending: sortOrder == "descending");

    final querySnapshot = await filteredQuery.get();

    List<Map<String, dynamic>> filteredLists = [];
    for (var doc in querySnapshot.docs) {
      final listId = doc['list-Id'];
      final userId = doc['user-Id'];
      final listTotal = doc['total'];
      final market = doc['market'];

      final userDoc = await FirebaseFirestore.instance
          .collection('Account')
          .doc(userId)
          .get();

      final listDoc = await FirebaseFirestore.instance
          .collection('Account')
          .doc(userId)
          .collection('List')
          .doc(listId)
          .get();

      if (userDoc.exists && listDoc.exists) {
        filteredLists.add({
          'listId': listId,
          'userId': userId,
          'listName': listDoc['list_name'] ?? 'Unnamed List',
          'username': userDoc['username'] ?? 'Unknown User',
          'total': listTotal,
          'market': market,
        });
      }
    }

    setState(() {
      communityLists = filteredLists;
    });
  } catch (e) {
    print('Firestore Query Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error fetching filtered results.')),
    );
  }
}



}

