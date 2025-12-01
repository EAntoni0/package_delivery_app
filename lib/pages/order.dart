import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_delivery_app/services/database.dart';
import 'package:package_delivery_app/services/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Stream? orderStream;

  // Carga los datos al iniciar la pantalla
  getontheload() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    orderStream = DatabaseMethods().getOrders(uid);
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  // WIDGET PARA CADA TARJETA DE PEDIDO
  Widget allOrders() {
    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xff6053f8)),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    ds["PickUp"], // Datos de Firebase
                                    style: AppWidget.SemiBoldTextfeildStyle(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Línea vertical simulada (Timeline simple)
                            Container(
                              margin: const EdgeInsets.only(left: 11.0),
                              height: 30,
                              width: 2,
                              color: Colors.grey,
                            ),

                            Row(
                              children: [
                                const Icon(Icons.flag, color: Colors.orange),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    ds["DropOff"], // Datos de Firebase
                                    style: AppWidget.SemiBoldTextfeildStyle(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Status:", style: AppWidget.LightTextfeildStyle()),
                                Text(
                                  ds["Status"], 
                                  style: const TextStyle(
                                    color: Color(0xff6053f8), 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                  )
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff6053f8), // Fondo morado del header
      appBar: AppBar(
        backgroundColor: const Color(0xff6053f8),
        title: Center(
          child: Text("Order page", style: AppWidget.WhiteTextfeildStyle(24.0)),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10.0),
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white, // Fondo blanco redondeado
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // BOTONES DE PESTAÑAS (Simulación visual)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton("Current Orders", true),
                _buildTabButton("Past Orders", false),
              ],
            ),
            const SizedBox(height: 30.0),
            // LISTA DE PEDIDOS
            Expanded(child: allOrders()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFFececf8),
          borderRadius: BorderRadius.circular(10),
          border: isActive ? Border.all(color: const Color(0xff6053f8), width: 2) : null
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.black38,
          ),
        ),
      ),
    );
  }
}