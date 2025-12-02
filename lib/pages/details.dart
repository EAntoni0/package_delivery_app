import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_delivery_app/services/widget_support.dart';

class Details extends StatefulWidget {
  final DocumentSnapshot ds;
  // Recibimos los segundos pasados para saber cómo dibujar la línea
  final int secondsPassed; 

  const Details({super.key, required this.ds, required this.secondsPassed});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  // Copiamos la misma configuración de pasos para que coincida
  final List<Map<String, dynamic>> simulationSteps = [
    {'time': 0, 'status': 'Driver assigned', 'icon': Icons.assignment_ind_outlined},
    {'time': 8, 'status': 'Driver on the way to pick up', 'icon': Icons.directions_car_outlined},
    {'time': 16, 'status': 'Driver arrived at pick up', 'icon': Icons.storefront_outlined},
    {'time': 20, 'status': 'Package collected', 'icon': Icons.inventory_2_outlined},
    {'time': 30, 'status': 'On the way to destination', 'icon': Icons.local_shipping_outlined},
    {'time': 40, 'status': 'Delivered', 'icon': Icons.home_work_outlined},
  ];

  // Función para obtener el estado actual en texto basado en el tiempo
  String getCurrentStatus() {
    if (widget.ds["Status"] == "Delivered") return "Delivered";
    
    for (int i = simulationSteps.length - 1; i >= 0; i--) {
      if (widget.secondsPassed >= simulationSteps[i]['time']) {
        return simulationSteps[i]['status'];
      }
    }
    return "Pending";
  }

  @override
  Widget build(BuildContext context) {
    String currentStatus = getCurrentStatus();
    bool isDelivered = widget.ds["Status"] == "Delivered";

    return Scaffold(
      backgroundColor: const Color(0xff6053f8),
      appBar: AppBar(
        backgroundColor: const Color(0xff6053f8),
        elevation: 0,
        title: Text("Shipment Details", style: AppWidget.WhiteTextfeildStyle(26)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20.0),
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 1.0)),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),

                
                
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO: ID Y PRECIO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Order #${widget.ds["Id"]}", style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("\$${widget.ds["Price"]}", style: AppWidget.HeadLineTextfeildStyle(26)),
                ],
              ),
              const SizedBox(height: 10),
              
              // ESTADO ACTUAL DESTACADO
              Row(
                children: [
                  Text("Status: ", style:  AppWidget.LightTextfeildStyle()),
                  Text(
                    currentStatus, 
                    style: TextStyle(
                      color: isDelivered ? Colors.green : const Color(0xff6053f8), 
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    )
                  ),
                ],
              ),
              
              const Divider(thickness: 1.0, height: 30),

              // --- LÍNEA DE TIEMPO DETALLADA ---
              Text("Tracking History", style: AppWidget.SemiBoldTextfeildStyle()),
              const SizedBox(height: 20),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: simulationSteps.map((step) {
                  // Lógica para saber si este paso ya ocurrió
                  // Si el pedido ya está entregado (en BD), mostramos todo.
                  // Si no, usamos el tiempo que nos pasaron.
                  bool stepCompleted = isDelivered || widget.secondsPassed >= (step['time'] as int);
                  bool isLast = step['status'] == 'Delivered';

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(
                            // Check verde si completado, círculo gris si pendiente
                            stepCompleted ? Icons.check_circle : Icons.radio_button_unchecked, 
                            color: stepCompleted 
                                ? (isLast ? Colors.green : const Color(0xff6053f8)) 
                                : Colors.grey.shade300, 
                            size: 26
                          ),
                          // Línea conectora (no se dibuja en el último paso)
                          if (step['time'] != 40) 
                            Container(
                              height: 40, 
                              width: 2, 
                              color: stepCompleted ? const Color(0xff6053f8).withOpacity(0.5) : Colors.grey.shade200
                            )
                        ],
                      ),
                      const SizedBox(width: 15),
                      Icon(
                        step['icon'], 
                        size: 34, 
                        color: stepCompleted 
                            ? (isLast ? Colors.green : const Color(0xff6053f8)) 
                            : Colors.grey.shade400
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['status'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: stepCompleted ? FontWeight.bold : FontWeight.normal,
                                color: stepCompleted ? Colors.black87 : Colors.grey
                              ),
                            ),
                            if (stepCompleted)
                              Text(
                                "Completed", // Podrías poner una hora simulada aquí
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                              ),
                            const SizedBox(height: 25), // Espacio para alinear con la altura de la línea
                          ],
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),

              const Divider(thickness: 1.0, height: 30),

              // DETALLES DE DIRECCIÓN (Lo que ya tenías)
              Text("Delivery Details", style: AppWidget.SemiBoldTextfeildStyle()),
              const SizedBox(height: 10),
              _buildInfoCard(
                address: widget.ds["PickUp"],
                name: widget.ds.data().toString().contains("PickUpName") ? widget.ds["PickUpName"] : "N/A",
                phone: widget.ds.data().toString().contains("PickUpPhone") ? widget.ds["PickUpPhone"] : "N/A",
                icon: Icons.location_on,
                color: const Color(0xff6053f8),
                title: "Pick Up",
              ),

              const SizedBox(height: 10),
              _buildInfoCard(
                address: widget.ds["DropOff"],
                name: widget.ds.data().toString().contains("DropOffName") ? widget.ds["DropOffName"] : "N/A",
                phone: widget.ds.data().toString().contains("DropOffPhone") ? widget.ds["DropOffPhone"] : "N/A",
                icon: Icons.flag,
                color: Colors.orange,
                title: "Drop Off"
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String address, required String name, required String phone, required IconData icon, required Color color, required String title}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFececf8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Icon(icon, color: color, size: 30)
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(address, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(name, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(phone, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}