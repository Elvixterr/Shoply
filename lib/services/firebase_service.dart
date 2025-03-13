// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore BaseDeDatos = FirebaseFirestore.instance;

Future<Map<String, String>?> Login(String email, String password) async {
  try {
    // Referencia a la colección 'Account' en Firestore
    CollectionReference accountCollection = BaseDeDatos.collection('Account');

    // Realizar una consulta para buscar el email y el password
    QuerySnapshot querySnapshot = await accountCollection
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    // Verificar si la consulta encontró resultados
    if (querySnapshot.docs.isNotEmpty) {
      // Tomar el primer documento encontrado
      var doc = querySnapshot.docs.first;

      // Retornar el id, el email y el password del documento
      return {
        'userid': doc.id,
        'email': doc['email'],
        'password': doc['password'],
        'username': doc['username']
      };
    } else {
      // Si no hay coincidencias, retornar null
      return null;
    }
  } catch (e) {
    // Manejo de errores
    print("Error durante el login: $e");
    return null;
  }
}

Future<String> registerUser(
    {required String username, required String email, required String password}) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Verificar si el username ya está tomado
    final usernameExists = await firestore
        .collection('Account')
        .where('username', isEqualTo: username)
        .get();
    if (usernameExists.docs.isNotEmpty) {
      return 'Username is already taken';
    }

    // Verificar si el email ya está registrado
    final emailExists =
        await firestore.collection('Account').where('email', isEqualTo: email).get();
    if (emailExists.docs.isNotEmpty) {
      return 'Email is already registered';
    }

    // Agregar usuario a la base de datos
    await firestore.collection('Account').add({
      'username': username,
      'email': email,
      'password': password, // Puedes implementar un hash si lo deseas
      'picture': '', // Columna adicional vacía
    });

    return 'success';
  } catch (e) {
    print('Error registering user: $e');
    return 'Error registering user. Please try again.';
  }
}

Future<List<Map<String, dynamic>>> getUserLists(String userId) async {
  try {
    // Obtener listas del usuario desde Firestore
    QuerySnapshot querySnapshot = await BaseDeDatos
        .collection('Account')
        .doc(userId)
        .collection('List')
        .get();

    // Convertir las listas en un formato legible
    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['list_name'],
        'color': doc['list_color'], // Almacenar color como entero ARGB
      };
    }).toList();
  } catch (e) {
    print("Error al obtener listas: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> getListItems(
    String userId, String listId) async {
  try {
    // Obtener ítems de la lista específica
    QuerySnapshot querySnapshot = await BaseDeDatos
        .collection('Account')
        .doc(userId)
        .collection('List')
        .doc(listId)
        .collection('items')
        .get();

    // Convertir los ítems en un formato legible
    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['item_name'],
        'note': doc['item_note'],
        'price': doc['item_price'],
        'quantity': doc['item_quantity'],
      };
    }).toList();
  } catch (e) {
    print("Error al obtener ítems: $e");
    return [];
  }
}

Future<void> addItemToList(String userId, String listId,
    Map<String, dynamic> item) async {
  try {
    await BaseDeDatos
        .collection('Account')
        .doc(userId)
        .collection('List')
        .doc(listId)
        .collection('items')
        .add(item);
  } catch (e) {
    print("Error al agregar ítem: $e");
  }
}

Future<void> deleteItemFromList(String userId, String listId, String itemId) async {
  try {
    await BaseDeDatos
        .collection('Account')
        .doc(userId)
        .collection('List')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .delete();
  } catch (e) {
    print("Error al eliminar el ítem: $e");
  }
}

Future<DocumentReference> addListToUser(String userId, String listName, Color listColor) async {
  try {
    final docRef = FirebaseFirestore.instance
        .collection('Account')
        .doc(userId)
        .collection('List')
        .add({
      'list_name': listName,
      'list_color': listColor.value, // Guardar el color en formato ARGB
      'created_at': FieldValue.serverTimestamp(),
    });
    return docRef;
  } catch (e) {
    throw Exception("Error adding the list: $e");
  }
}


Future<void> deleteListFromUser(String userId, String listId) async {
  try {
    // Eliminar la lista de la subcolección 'List' del usuario
    await BaseDeDatos
        .collection('Account')
        .doc(userId)
        .collection('List')
        .doc(listId)
        .delete();
    print("Lista con ID $listId eliminada correctamente para el usuario $userId.");
  } catch (e) {
    print("Error al eliminar la lista: $e");
    rethrow; // Relanza el error para manejarlo en otros niveles si es necesario
  }
}

Future<List<Map<String, dynamic>>> getPopularProducts() async {
  try {
    // Obtener todos los productos de la colección "Products"
    QuerySnapshot querySnapshot = await BaseDeDatos.collection('Products').get();

    // Mapear los documentos a un formato legible
    return querySnapshot.docs.map((doc) {
      return {
        'name': doc['name'], // Nombre del producto
        'category': doc['category'], // Categoría del producto
      };
    }).toList();
  } catch (e) {
    print("Error al obtener productos populares: $e");
    return [];
  }
}

Future<List<String>> getCategories() async {
  try {
    QuerySnapshot querySnapshot = await BaseDeDatos.collection('Products').get();
    // Extraer todas las categorías únicas
    Set<String> categories = querySnapshot.docs
        .map((doc) => doc['category'] as String)
        .toSet();
    return categories.toList();
  } catch (e) {
    print("Error al obtener categorías: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
  try {
    QuerySnapshot querySnapshot = await BaseDeDatos
        .collection('Products')
        .where('category', isEqualTo: category)
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        'name': doc['name'],
        'category': doc['category'],
      };
    }).toList();
  } catch (e) {
    print("Error al obtener productos por categoría: $e");
    return [];
  }
}

Future<void> updateListInUser(String userId, String listId, String updatedName, Color listColor) async {
  try {
    final userRef = FirebaseFirestore.instance.collection('Account').doc(userId);
    final listRef = userRef.collection('List').doc(listId);
    await listRef.update({'list_name': updatedName, 'list_color': listColor.value});
    print("Color actualizado correctamente.");
  } catch (e) {
    print("Error al actualizar la lista: $e");
    throw Exception("Error updating the list");
  }
}












