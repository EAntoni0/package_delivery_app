import 'dart:async'; // Necesario para el Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_delivery_app/pages/details.dart';
import 'package:package_delivery_app/services/database.dart';
import 'package:package_delivery_app/services/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Stream? orderStream;
  bool currentOrder = true;

  getontheload() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      orderStream = DatabaseMethods().getOrders(user.uid);
      setState(() {});
    }
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allOrders() {
    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> allDocs = snapshot.data.docs;
        List<DocumentSnapshot> filteredDocs = [];

        if (currentOrder) {
          // Current: Mostramos los que NO son Delivered
          filteredDocs = allDocs.where((element) => element['Status'] != 'Delivered').toList();
        } else {
          // Past: Mostramos SOLO los Delivered
          filteredDocs = allDocs.where((element) => element['Status'] == 'Delivered').toList();
        }

        if (filteredDocs.isEmpty) {
          return Center(
              child: Text(currentOrder ? "No active orders" : "No delivery history",
                  style: AppWidget.LightTextfeildStyle()));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = filteredDocs[index];
            
            // Usamos nuestro nuevo Widget inteligente
            return OrderCard(ds: ds, isCurrent: currentOrder);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff6053f8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff6053f8),
        title: Center(child: Text("My Orders", style: AppWidget.WhiteTextfeildStyle(26.0))),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10.0),
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () { setState(() { currentOrder = true; }); },
                    child: Material(
                      elevation: currentOrder ? 5.0 : 0.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        decoration: BoxDecoration(
                          color: currentOrder ? Colors.white : const Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Image.asset("lib/images/currentorder.png", height: 70, width: 70, fit: BoxFit.cover),
                            const SizedBox(height: 10.0),
                            Text("Current Orders", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: currentOrder ? Colors.black : Colors.black38)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () { setState(() { currentOrder = false; }); },
                    child: Material(
                      elevation: !currentOrder ? 5.0 : 0.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        decoration: BoxDecoration(
                          color: !currentOrder ? Colors.white : const Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Image.asset("lib/images/delivery-man.png", height: 70, width: 70, fit: BoxFit.cover),
                            const SizedBox(height: 10.0),
                            Text("Past Orders", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: !currentOrder ? Colors.black : Colors.black38)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Expanded(child: allOrders()),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
//  WIDGET DE TARJETA CON LÍNEA DE TIEMPO ACUMULATIVA
// ---------------------------------------------------------
class OrderCard extends StatefulWidget {
  final DocumentSnapshot ds;
  final bool isCurrent;

  const OrderCard({super.key, required this.ds, required this.isCurrent});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  // Configuración de los pasos de la simulación
  final List<Map<String, dynamic>> simulationSteps = [
    {
      'time': 0, 
      'status': 'Driver assigned', 
      'icon': Icons.assignment_ind_outlined // Icono de conductor asignado
    },
    {
      'time': 8, 
      'status': 'Driver on the way to pick up', 
      'icon': Icons.directions_car_outlined // Icono de auto en camino
    },
    {
      'time': 16, 
      'status': 'Driver arrived at pick up', 
      'icon': Icons.storefront_outlined // Icono de tienda/lugar
    },
    {
      'time': 20, 
      'status': 'Package collected', 
      'icon': Icons.inventory_2_outlined // Icono de paquete recogido
    },
    {
      'time': 30, 
      'status': 'On the way to destination', 
      'icon': Icons.local_shipping_outlined // Icono de camión en ruta
    },
    {
      'time': 40, 
      'status': 'Delivered', 
      'icon': Icons.home_work_outlined // Icono de entrega finalizada
    },
  ];

  int secondsPassed = 0;
  Timer? _timer;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    // Si es orden actual y no está entregada, iniciamos el cronómetro
    if (widget.isCurrent && widget.ds["Status"] != "Delivered") {
      startSimulation();
    } else {
      // Si es historial, mostramos todo completo (simulamos que pasaron 999 segundos)
      secondsPassed = 999;
      finished = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startSimulation() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) async {
      if (mounted) {
        setState(() {
          secondsPassed++;
        });

        // --- MOMENTO DE LA VERDAD ---
        if (secondsPassed >= 40) {
          timer.cancel();
          setState(() {
            finished = true;
          });

          // 1. Obtener ID del usuario actual
          String uid = FirebaseAuth.instance.currentUser!.uid;
          
          // 2. Obtener ID del documento del pedido
          String orderId = widget.ds.id; 

          // 3. ACTUALIZAR FIREBASE A "Delivered"
          await DatabaseMethods().updateStatus(uid, orderId);
          
          // ¡Listo! Al actualizarse Firebase, el StreamBuilder del padre
          // detectará el cambio y moverá esta tarjeta a "Past Orders" automáticamente.
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _timer?.cancel();
        Navigator.push(context, MaterialPageRoute(builder: (context) => Details(
          ds: widget.ds, secondsPassed: secondsPassed,))
          ).then((_) {
            if(!finished && mounted) {
              startSimulation();
            }
          });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(15.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ENCABEZADO (ID y Estado General)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Order ID: ${widget.ds["Id"] ?? "..."}", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: finished ? Colors.green.withOpacity(0.1) : const Color(0xff6053f8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        finished ? "Delivered" : widget.ds["Status"], 
                        style: TextStyle(
                            color: finished ? Colors.green : const Color(0xff6053f8),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),

                // 2. DATOS FIJOS (Pick Up / Drop Off)
                // Mostramos siempre el origen y destino arriba para contexto
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.black54, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${widget.ds["PickUp"]}  ➔  ${widget.ds["DropOff"]}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
                const Divider(height: 20),

                // 3. LÍNEA DE TIEMPO 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: simulationSteps.map((step) {
                    // Solo mostramos este paso si el tiempo ya pasó
                    if (secondsPassed >= step['time']) {
                      bool isLast = step['status'] == 'Delivered';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0), // Espacio entre puntos
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // El punto y la línea vertical
                            Column(
                              children: [
                                Icon(
                                  Icons.check_circle, 
                                  color: isLast ? Colors.green : const Color(0xff6053f8), 
                                  size: 18
                                ),
                                // Dibujamos una linea pequeña si no es el último elemento mostrado
                                if (step['time'] != 40 && secondsPassed >= (step['time'] as int)) 
                                  Container(height: 15, width: 2, color: Colors.grey.shade300)
                              ],
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              step['icon'], // Usamos el icono del mapa
                              size: 22,
                              // Si es el último paso (Delivered), se pone verde, si no, gris oscuro
                              color: isLast ? Colors.green : Colors.grey.shade700, 
                            ),
                            const SizedBox(width: 12),
                            // El texto del estado
                            Expanded(
                              child: Text(
                                step['status'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                                  color: isLast ? Colors.green : Colors.black87
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink(); // Si no ha pasado el tiempo, no mostramos nada
                    }
                  }).toList(),
                ),
                
                const SizedBox(height: 10),
                
                // 4. PRECIO
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Total: ", style: AppWidget.LightTextfeildStyle()),
                    Text("\$${widget.ds.data().toString().contains("Price") ? widget.ds["Price"] : "0.0"}", style: AppWidget.HeadLineTextfeildStyle(18)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}