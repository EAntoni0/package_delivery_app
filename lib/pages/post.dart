import 'dart:math'; // Importante para generar números aleatorios
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

    // simular el efecto de loading de unos 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    // GENERACIÓN ALEATORIA
    // Generamos una distancia entre 15 y 80 km
    int randomKm = Random().nextInt(80) + 15; 
    
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
        content: Text("Route Calculated Successfully!")));
  }

  // Subir los datos a nuestra base de firebase
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


  void _showPaymentSheet() {
    // Validaciones antes de abrir el pago
    if (totalPrice == 0) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.orange, content: Text("Primero calcula el precio.")));
       return;
    }
    if (pickupNameController.text.isEmpty || dropoffNameController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.orange, content: Text("Por favor llena los nombres de contacto.")));
       return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        bool isPaying = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payment, color: Color(0xff6053f8)),
                        const SizedBox(width: 10),
                        Text("Método de Pago", style: AppWidget.HeadLineTextfeildStyle(20)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // simular targeta de credito
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.credit_card, color: Colors.white),
                              Text("VISA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text("**** **** **** 4242", style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("TITULAR", style: TextStyle(color: Colors.grey, fontSize: 10)),
                              const Text("EXPIRA", style: TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Erick Chan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text("12/25", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    Text("Total a Pagar", style: AppWidget.LightTextfeildStyle()),
                    Text("\$$totalPrice", style: AppWidget.HeadLineTextfeildStyle(26)),
                    const SizedBox(height: 30),

                    // BOTÓN DE "PAGAR AHORA"
                    GestureDetector(
                      onTap: () async {
                        // 1. Mostrar carga en el botón
                        setSheetState(() { isPaying = true; });
                        
                        // 2. Simular espera de red (2 segundos)
                        await Future.delayed(const Duration(seconds: 2));
                        
                        // 3. Cierra la hoja de pago
                        if(context.mounted) Navigator.pop(context);
                        
                        // 4. Guardar el pedido en la base de datos
                        uploadItem();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xff6053f8),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Center(
                          child: isPaying 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text("Pagar Ahora", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
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
                      // SECCIÓN 1: BÚSQUEDA Y CÁLCULO
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

                      // BOTÓN MEDIO: CALCULAR PRECIO
                      GestureDetector(
                        onTap: calculateDistanceAndPrice,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black, 
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.black, width: 1),

                          ),
                          child: Center(
                            child: isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Calculate Distance & Price", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40.0),
                      const Divider(thickness: 2), 

                      // -------------------------------------------------
                      // SECCIÓN 2: FORMULARIOS DETALLADOS
                      // -------------------------------------------------
                      const SizedBox(height: 20.0),
                      Text("Pick-up details", style: AppWidget.normalTextfeildStyle(26.0)),
                      const SizedBox(height: 10.0),
                      
                      // CAMPO: DIRECCIÓN PICKUP SE LLENAN SOLOS
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: TextField(
                          controller: pickupAddressController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.location_on, color: Color(0xff6053f8), size: 30,),
                            hintText: "Address",
                            hintStyle: AppWidget.LightTextfeildStyle(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // CAMPO: NOMBRE REMITENTE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: TextField(
                          controller: pickupNameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.person, color: Color(0xff6053f8), size: 30),
                            hintText: "Sender Name",
                            hintStyle: AppWidget.LightTextfeildStyle(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // CAMPO: TELÉFONO REMITENTE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: TextField(
                          controller: pickupPhoneController,
                          keyboardType: TextInputType.phone, // TECLADO NUMÉRICO
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.phone, color: Color(0xff6053f8), size: 30),
                            hintText: "Sender Phone",
                            hintStyle: AppWidget.LightTextfeildStyle(),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20.0),
                      Text("Drop-off details", style: AppWidget.normalTextfeildStyle(26.0)),
                      const SizedBox(height: 10.0),
                      
                      // CAMPO: DIRECCIÓN DROP-OFF (AUTO-FILLED)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: TextField(
                          controller: dropoffAddressController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.flag, color: Color(0xff6053f8), size: 30),
                            hintText: "Address",
                            hintStyle: AppWidget.LightTextfeildStyle(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // CAMPO: NOMBRE RECEPTOR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: TextField(
                          controller: dropoffNameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.person, color: Color(0xff6053f8), size: 30),
                            hintText: "Receiver Name",
                            hintStyle: AppWidget.LightTextfeildStyle(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // CAMPO: TELÉFONO RECEPTOR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: TextField(
                          controller: dropoffPhoneController,
                          keyboardType: TextInputType.phone, // TECLADO NUMÉRICO
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.phone, color: Color(0xff6053f8), size: 30),
                            hintText: "Receiver Phone",
                            hintStyle: AppWidget.LightTextfeildStyle(),
                          ),
                        ),
                      ),

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
                              onTap: () {
                                _showPaymentSheet();
                              },
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