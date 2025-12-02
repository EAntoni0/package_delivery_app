import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_delivery_app/pages/details.dart';
import 'package:package_delivery_app/services/database.dart';
import 'package:package_delivery_app/services/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //controlador para el campo de busqueda de envios por Id
  TextEditingController trackController = TextEditingController();

  searchPackage() async {
    if (trackController.text.isNotEmpty) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      // Llamar a la base de datos
      QuerySnapshot querySnapshot = await DatabaseMethods().getOrderByTrackId(uid, trackController.text);

      if (querySnapshot.docs.isNotEmpty) {
        // si el id de pedido coincide con lo que puso el usuario lo tomamos
        DocumentSnapshot ds = querySnapshot.docs[0];
        
        // Navegamos a detalles. 
        // Pasamos secondsPassed: 0 porque venimos del Home, la pantalla de detalles calculará el estado.
        Navigator.push(context, MaterialPageRoute(builder: (context) => Details(ds: ds, secondsPassed: 0)));
      } else {
        // Si no existe el ID
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Tracking number not found! Check your ID."),
        ));
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 40.0, bottom: 20.0), // Agregué margen inferior
          child: Column(
            children: [
              // HEADER DE UBICACIÓN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xff6053f8), size: 30.0),
                          const SizedBox(width: 5.0),
                          Text(
                            "Current Location",
                            style: AppWidget.SimpleTextfeildStyle(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      Text("City Avenue, New York",
                          style: AppWidget.HeadLineTextfeildStyle(20.0)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // CAJA AZUL GRANDE (TRACKING)
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                // Eliminé la altura fija para evitar errores en pantallas pequeñas
                padding: const EdgeInsets.only(bottom: 20.0), 
                decoration: BoxDecoration(
                  color: const Color(0xff6053f8),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30.0),
                    Text(
                      "Track your shipment",
                      style: AppWidget.WhiteTextfeildStyle(22.0),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      "Please enter your tracking number",
                      style: AppWidget.differentshadetWhiteTextfeildStyle(),
                    ),
                    const SizedBox(height: 30.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: trackController,
                        // Esto hace que el teclado muestre "Buscar" o "Ir" en lugar de "Enter"
                        textInputAction: TextInputAction.search, 
                        onSubmitted: (value) => searchPackage(), // Buscar al dar Enter

                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter track number",
                          hintStyle: AppWidget.HeadLineTextfeildStyle(18),
                          prefixIcon: const Icon(Icons.track_changes, color: Colors.red),
                          
                          suffixIcon: GestureDetector(
                            onTap: () {
                              searchPackage();
                            },
                            child: const Icon(Icons.search, color: Color(0xff6053f8)),
                          )

                        ),
                        style: const TextStyle(color: Colors.black, fontSize: 20.0),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // Nota: Asegúrate de tener esta imagen o dará error
                    Image.asset("lib/images/home.png", height: 120), 
                  ],
                ),
              ),
              const SizedBox(height: 30.0),

              // OPCIÓN 1: ORDER DELIVERY
              _buildOptionCard(
                context: context,
                imagePath: "lib/images/fast-delivery.png",
                title: "Order a delivery",
                description: "We'll pick it up and deliver it across town quickly and securely.",
              ),
              
              const SizedBox(height: 20.0),

              // OPCIÓN 2: TRACK DELIVERY
              _buildOptionCard(
                context: context,
                imagePath: "lib/images/parcel.png",
                title: "Track a delivery",
                description: "We'll pick it up and deliver it across town quickly and securely.",
              ),

              const SizedBox(height: 20.0),

              // OPCIÓN 3: HISTORY
              _buildOptionCard(
                context: context,
                imagePath: "lib/images/delivery-bike.png",
                title: "Delivery History",
                description: "Check your delivery history anytime to view details.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para no repetir código y evitar errores de desbordamiento
  Widget _buildOptionCard({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        elevation: 2.0,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black38, width: 2.0),
          ),
          child: Row(
            children: [
              Image.asset(imagePath, height: 80, width: 80, fit: BoxFit.cover),
              const SizedBox(width: 15.0),
              // Expanded es la CLAVE para evitar el error de "RenderFlex overflowed"
              Expanded( 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppWidget.HeadLineTextfeildStyle(20.0)),
                    const SizedBox(height: 5.0),
                    Text(
                      description,
                      style: AppWidget.slowSimpleTextfeildStyle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}