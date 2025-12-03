import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_delivery_app/pages/login.dart';
import 'package:package_delivery_app/pages/signup.dart';
// Importamos tus estilos

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController mailcontroller = TextEditingController();

  String email = "";

  final _formkey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Password Reset Email has been sent!",
            style: TextStyle(fontSize: 18.0),
          )));

      // --- TRUCO DE FLUJO DE USUARIO ---
      // Esperamos 2 segundos para que lea el mensaje y lo mandamos al Login
      // para que esté listo para entrar con su nueva contraseña.
      Future.delayed(const Duration(seconds: 2), () {
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LogIn()));
      });

    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No user found for that email.",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco consistente
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              // HEADER MORADO CURVO (Igual que Profile)
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 45.0, left: 20.0, right: 20.0),
                    height: MediaQuery.of(context).size.height / 4.3,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Color(0xff6053f8),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(400, 105.0)
                      )
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Password Recovery",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  
                  // Icono de candado o interrogación centrado
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 6.5),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(60),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60)
                          ),
                          child: const Icon(Icons.lock_reset, size: 60, color: Color(0xff6053f8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50.0),

              const Text(
                "Enter your email",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 20.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      // CAMPO DE EMAIL CON ESTILO APP
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFececf8), // Fondo gris suave
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextFormField(
                          controller: mailcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Email';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Color(0xff6053f8),
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      
                      // BOTÓN ENVIAR (Estilo App)
                      GestureDetector(
                        onTap: () {
                          if(_formkey.currentState!.validate()){
                            setState(() {
                              email = mailcontroller.text;
                            });
                            resetPassword();
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: const Color(0xff6053f8), // Color morado principal
                              borderRadius: BorderRadius.circular(30)),
                          child: const Center(
                            child: Text(
                              "Send Email",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 50.0),
                      
                      // OPCIÓN VOLVER A CREAR CUENTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 16.0, color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> const SignUp()));
                            },
                            child: const Text(
                              "Create",
                              style: TextStyle(
                                  color: Color(0xff6053f8),
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
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