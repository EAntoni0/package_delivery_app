import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // Función para agregar datos del usuario a la base de datos
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users") // Nombre de la tabla
        .doc(id)             // Usamos el ID del usuario como nombre del documento
        .set(userInfoMap);
  }


  // funcion para guardar los detalles de un paquete
  Future addPackageDetails(Map<String, dynamic> packageInfoMap, String id) async {
    return await FirebaseFirestore.instance
                .collection("users")
                .doc(id)
                .collection("Orders")
                .add(packageInfoMap);
  }

  // funcion para recuperar los pedidos de el usuario 
  Stream<QuerySnapshot> getOrders(String id){
    return FirebaseFirestore.instance.collection("users")
            .doc(id)
            .collection("Orders")
            .snapshots();
  }


  // Función para actualizar el status del envio
  Future updateStatus(String id, String orderId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Orders")
        .doc(orderId)
        .update({"Status": "Delivered"});
  }


  // Buscar un pedido por su ID de rastreo (Track ID)
  Future<QuerySnapshot> getOrderByTrackId(String id, String trackId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Orders")
        .where("Id", isEqualTo: trackId) // Buscamos por el campo "Id" que generamos
        .get();
  }

  //funcion para obtener los datos del usuario actual

  Future<DocumentSnapshot> getUserDetail(String id) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).get();
  }

  //funcion para eliminar los datos del usuario
  Future deleteUser(String id) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).delete();
  }

}