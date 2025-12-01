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

  //controladores para capturar lo que ingresa el usuario
  TextEditingController pickupController = TextEditingController();
  TextEditingController dropoffController = TextEditingController();

  //funcion para subir los datos
  uploadItem() async {
    if(pickupController.text != "" && dropoffController.text != ""){
      //obtener Id del usuario que tiene iniciado sesion en el momento actual
      String uid = FirebaseAuth.instance.currentUser!.uid;

      //mapa de datos
      Map<String, dynamic> packageInfoMap = {
        "PickUp": pickupController.text,
        "DropOff": dropoffController.text,
        "Id": randomAlphaNumeric(10), //con esto se genera un id aleatorio
        "Status": "Pending", 
        "Date": DateTime.now().toString(),
      };

      //para guardar en firebase
      await DatabaseMethods().addPackageDetails(packageInfoMap, uid).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Package Order Placed Successfully!")));      
        // Limpiar campos despues de subir los datos
        pickupController.clear();
        dropoffController.clear();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff6053f8),
      body: Container(
        margin: EdgeInsets.only(top: 60.0),
        child: Column(
          children: [
            Center(child: Text("Add Package",
            style: AppWidget.WhiteTextfeildStyle(24.0))),
            SizedBox(height: 20.0),
            Expanded(
              child: Container
                (
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Image.asset('lib/images/delivery-truck.png', height: 180, width: 180, fit: BoxFit.cover)),
                        SizedBox(height: 20.0),
                        Text("Add Location", style: AppWidget.HeadLineTextfeildStyle(22.0)),
                        SizedBox(height: 20.0),
                        Text("Pick Up", style: AppWidget.normalTextfeildStyle(20.0),),
                        SizedBox(height: 5.0),
                        Container(
                          padding: EdgeInsets.only(left: 100.0),
                          margin: EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(color: Color(0xFFececf8), borderRadius: BorderRadius.circular(10.0)),
                          child: TextField(

                            //controlador del formulario de lugar de recogida
                            controller: pickupController,

                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Pick Up Location",
                              hintStyle: AppWidget.SimpleTextfeildStyle(),
                            ),
                          ),
                        ),
                        Text("Drop Off", style: AppWidget.normalTextfeildStyle(20.0),),
                        SizedBox(height: 5.0),
                        Container(
                          padding: EdgeInsets.only(left: 100.0),
                          margin: EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(color: Color(0xFFececf8), borderRadius: BorderRadius.circular(10.0)),
                          child: TextField(

                            // controlador para el formulario de lugra de entrega
                            controller: dropoffController,

                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Drop Off Location",
                              hintStyle: AppWidget.SimpleTextfeildStyle(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Center(
                          child: Container(
                            height: 60.0,
                            width: MediaQuery.of(context).size.width/1.9,
                            decoration: BoxDecoration(
                              color: Color(0xff6053f8),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Text(
                                "Submit Location", style: AppWidget.WhiteTextfeildStyle(18.0)
                                )
                              ),
                          ),
                        ),
                        SizedBox(height: 40.0),
                        Container(
                          margin: EdgeInsets.only(right: 20.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45, width: 2.0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //SizedBox(height: 20.0),
                              Text("Pick-up details", style: AppWidget.normalTextfeildStyle(24.0),),
                              SizedBox(height: 10.0),
                              Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.location_on, color: Color(0xff6053f8),),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Enter pick-up Address",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black26),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.person, color: Color(0xff6053f8),),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Enter User Name",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black26),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.phone, color: Color(0xff6053f8),),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Enter Phone Number",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black26),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.0),
                        Container(
                          margin: EdgeInsets.only(right: 20.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45, width: 2.0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //SizedBox(height: 20.0),
                              Text("Drop-off details", style: AppWidget.normalTextfeildStyle(24.0),),
                              SizedBox(height: 10.0),
                              Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.location_on, color: Color(0xff6053f8),),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Enter drop-off Address",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black26),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.person, color: Color(0xff6053f8),),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Enter User Name",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black26),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.phone, color: Color(0xff6053f8),),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Enter Phone Number",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black26),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0),
                          margin: EdgeInsets.only(right: 20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45, width: 2.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text("Total price", style: AppWidget.normalTextfeildStyle(18),),
                                  Text("\$80", style: AppWidget.HeadLineTextfeildStyle(28.0),),
                                ],
                              ),
                              //SizedBox(width: 50.0),
                            
                              GestureDetector(
                                onTap: (){
                                  uploadItem();
                                },
                                child: Container(
                                  height: 60.0,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Color(0xff6053f8),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child:Center(
                                    child: Text(
                                      "Place Order ", style: AppWidget.WhiteTextfeildStyle(20.0),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                          
                        ),
                        SizedBox(height: 80.0)

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
}