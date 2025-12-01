import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_delivery_app/pages/bottomnav.dart';
import 'package:package_delivery_app/pages/login.dart';
import 'package:package_delivery_app/services/widget_support.dart';
import 'package:package_delivery_app/services/database.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";

  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    if (password != "" && namecontroller.text != "" && mailcontroller.text != "") {
      try {
        // 1. CREAR EL USUARIO EN AUTH
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // 2. PREPARAR LOS DATOS PARA LA BASE DE DATOS
        // Usamos userCredential.user!.uid para obtener el ID único que creó Firebase
        Map<String, dynamic> userInfoMap = {
          "Name": namecontroller.text,
          "Email": mailcontroller.text,
          "Id": userCredential.user!.uid,
          "Wallet": "0", // Podemos iniciar su billetera en 0
        };

        // 3. GUARDAR EN FIRESTORE
        await DatabaseMethods().addUserDetail(userInfoMap, userCredential.user!.uid);

        ScaffoldMessenger.of(context).showSnackBar((SnackBar(
            backgroundColor: Colors.green,
            content: Text("Registered Successfully", style: TextStyle(fontSize: 20)))));

        // 4. IR AL HOME
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Bottomnav()));
        
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text("Password Provided is too Weak", style: TextStyle(fontSize: 18))));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text("Account Already exists", style: TextStyle(fontSize: 18))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              // IMAGEN DE CABECERA (Create Account)
              Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "lib/images/login.png", // Tu imagen de "Create Account"
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                        decoration: BoxDecoration(
                            color: Color(0xFFedf0f8),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Name';
                            }
                            return null;
                          },
                          controller: namecontroller,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Name",
                              hintStyle: AppWidget.LightTextfeildStyle()),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                        decoration: BoxDecoration(
                            color: Color(0xFFedf0f8),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Email';
                            }
                            return null;
                          },
                          controller: mailcontroller,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: AppWidget.LightTextfeildStyle()),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                        decoration: BoxDecoration(
                            color: Color(0xFFedf0f8),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Password';
                            }
                            return null;
                          },
                          obscureText: true,
                          controller: passwordcontroller,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: AppWidget.LightTextfeildStyle()),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      GestureDetector(
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              email = mailcontroller.text;
                              name = namecontroller.text;
                              password = passwordcontroller.text;
                            });
                          }
                          registration();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinea texto y botón
                            children: [
                              Text("Sign up", style: AppWidget.HeadLineTextfeildStyle(24)),
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color(0xff3f51b5), // O usa Colors.orange si prefieres
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.arrow_forward, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ", style: AppWidget.LightTextfeildStyle()),
                            Text("Sign In", style: AppWidget.SemiBoldTextfeildStyle()),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}