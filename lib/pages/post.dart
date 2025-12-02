import 'dart:math'; // Importante para generar números aleatorios
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_delivery_app/services/database.dart';
import 'package:package_delivery_app/services/widget_support.dart';
import 'package:random_string/random_string.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // 1. CONTROLADORES DE BÚSQUEDA (Los de arriba)
  TextEditingController searchPickupController = TextEditingController();
  TextEditingController searchDropoffController = TextEditingController();

  // 2. CONTROLADORES DE DETALLE (Los de abajo - Formularios)
  TextEditingController pickupAddressController = TextEditingController();
  TextEditingController pickupNameController = TextEditingController();
  TextEditingController pickupPhoneController = TextEditingController();

  TextEditingController dropoffAddressController = TextEditingController();
  TextEditingController dropoffNameController = TextEditingController();
  TextEditingController dropoffPhoneController = TextEditingController();

  // Variables de estado
  String distanceText = "0 km";
  double totalPrice = 0.0;
  bool isLoading = false;

  // --- FUNCIÓN DE CÁLCULO SIMULADO ---
  Future<void> calculateDistanceAndPrice() async {
    // Validamos que haya escrito algo arriba
    if (searchPickupController.text.isEmpty || searchDropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter locations in the top fields first.")));
      return;
    }

    setState(() { isLoading = true; });

    // SIMULACIÓN: Esperamos 2 segundos para que parezca que la app "piensa"
    await Future.delayed(const Duration(seconds: 2));

    // GENERACIÓN ALEATORIA
    // Generamos una distancia entre 1 y 50 km
    int randomKm = Random().nextInt(50) + 1; 
    
    // Calculamos el precio: Base $10 + ($3 por km)
    double price = 10.0 + (randomKm * 3.0);

    setState(() {
      distanceText = "$randomKm km";
      totalPrice = double.parse(price.toStringAsFixed(2)); // Redondear
      
      // AUTO-RELLENO: Copiamos el texto de arriba a abajo
      pickupAddressController.text = searchPickupController.text;
      dropoffAddressController.text = searchDropoffController.text;
      
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Route Calculated Successfully! (Simulated)")));
  }

  // --- FUNCIÓN PARA SUBIR A FIREBASE ---
  uploadItem() async {
    if (totalPrice > 0 && pickupNameController.text != "" && dropoffNameController.text != "") {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      Map<String, dynamic> packageInfoMap = {
        "PickUp": pickupAddressController.text,
        "PickUpName": pickupNameController.text,
        "PickUpPhone": pickupPhoneController.text,
        
        "DropOff": dropoffAddressController.text,
        "DropOffName": dropoffNameController.text,
        "DropOffPhone": dropoffPhoneController.text,
        
        "Id": randomAlphaNumeric(10),
        "Status": "Pending",
        "Date": DateTime.now().toString(),
        "Price": totalPrice.toString(),
        "Distance": distanceText,
      };

      await DatabaseMethods().addPackageDetails(packageInfoMap, uid).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Package Order Placed Successfully!")));
        
        // Limpiar todo
        searchPickupController.clear();
        searchDropoffController.clear();
        pickupAddressController.clear();
        pickupNameController.clear();
        pickupPhoneController.clear();
        dropoffAddressController.clear();
        dropoffNameController.clear();
        dropoffPhoneController.clear();
        
        setState(() {
          totalPrice = 0.0;
          distanceText = "0 km";
        });
      });
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Please calculate price and fill user names!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff6053f8),
      body: Container(
        margin: const EdgeInsets.only(top: 60.0),
        child: Column(
          children: [
            Center(child: Text("Add Package", style: AppWidget.WhiteTextfeildStyle(26.0))),
            const SizedBox(height: 20.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      // IMAGEN
                      Center(child: Image.asset('lib/images/delivery-truck.png', height: 180, width: 180, fit: BoxFit.cover)),
                      
                      // -------------------------------------------------
                      // SECCIÓN 1: BÚSQUEDA Y CÁLCULO (ARRIBA)
                      // -------------------------------------------------
                      const SizedBox(height: 20.0),
                      Text("Add Location", style: AppWidget.HeadLineTextfeildStyle(24.0)),
                      const SizedBox(height: 20.0),
                      
                      Text("Pick Up (From)", style: AppWidget.normalTextfeildStyle(22.0)),
                      const SizedBox(height: 5.0),
                      _buildSimpleField(searchPickupController, "City, (e.g. Cancun)", Icons.search),

                      const SizedBox(height: 20.0),
                      Text("Drop Off (To)", style: AppWidget.normalTextfeildStyle(22.0)),
                      const SizedBox(height: 5.0),
                      _buildSimpleField(searchDropoffController, "City, (e.g. Merida)", Icons.search),

                      const SizedBox(height: 30.0),

                      // BOTÓN MEDIO: CALCULAR PRECIO (SIMULADO)
                      GestureDetector(
                        onTap: calculateDistanceAndPrice,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black, 
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Calculate Distance & Price", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40.0),
                      const Divider(thickness: 2), 

                      // -------------------------------------------------
                      // SECCIÓN 2: FORMULARIOS DETALLADOS (ABAJO)
                      // -------------------------------------------------
                      const SizedBox(height: 20.0),
                      Text("Pick-up details", style: AppWidget.normalTextfeildStyle(26.0)),
                      const SizedBox(height: 10.0),
                      
                      _buildDetailField(pickupAddressController, "Address", Icons.location_on),
                      const SizedBox(height: 10.0),
                      _buildDetailField(pickupNameController, "Sender Name", Icons.person),
                      const SizedBox(height: 10.0),
                      _buildDetailField(pickupPhoneController, "Sender Phone", Icons.phone,),
                      
                      const SizedBox(height: 20.0),
                      Text("Drop-off details", style: AppWidget.normalTextfeildStyle(26.0)),
                      const SizedBox(height: 10.0),
                      
                      _buildDetailField(dropoffAddressController, "Address (Auto-filled)", Icons.flag),
                      const SizedBox(height: 10.0),
                      _buildDetailField(dropoffNameController, "Receiver Name", Icons.person),
                      const SizedBox(height: 10.0),
                      _buildDetailField(dropoffPhoneController, "Receiver Phone", Icons.phone),

                      const SizedBox(height: 40.0),

                      // -------------------------------------------------
                      // SECCIÓN 3: PRECIO Y BOTÓN FINAL
                      // -------------------------------------------------
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black45, width: 2.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Distance: $distanceText", style: AppWidget.LightTextfeildStyle()),
                                Text("Total: \$$totalPrice", style: AppWidget.HeadLineTextfeildStyle(24.0)),
                              ],
                            ),
                            
                            // BOTÓN FINAL: PLACE ORDER
                            GestureDetector(
                              onTap: uploadItem,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                decoration: BoxDecoration(
                                  color: totalPrice == 0 ? Colors.grey : const Color(0xff6053f8),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  "Place Order",
                                  style: AppWidget.WhiteTextfeildStyle(20.0),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 80.0)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(color: const Color(0xFFececf8), borderRadius: BorderRadius.circular(10.0)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none, 
          prefixIcon: Icon(icon),
          hintText: hint,
          hintStyle: AppWidget.SimpleTextfeildStyle(),
        ),
      ),
    );
  }

  Widget _buildDetailField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10.0)
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: const Color(0xff6053f8)),
          hintText: hint,
          hintStyle: AppWidget.LightTextfeildStyle(),
        ),
      ),
    );
  }
}