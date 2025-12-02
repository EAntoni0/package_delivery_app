import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_delivery_app/pages/login.dart';
import 'package:package_delivery_app/pages/signup.dart';
import 'package:package_delivery_app/services/database.dart';
import 'package:package_delivery_app/services/widget_support.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "Loading...";
  String email = "Loading...";

  // Cargar datos al iniciar
  getProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await DatabaseMethods().getUserDetail(user.uid);
      
      if (mounted) {
        setState(() {
          // Usamos validaciones por si los campos no existen
          name = doc.data().toString().contains("Name") ? doc["Name"] : "User Name";
          email = doc.data().toString().contains("Email") ? doc["Email"] : "User Email";
        });
      }
    }
  }

  // Lógica para Cerrar Sesión
  logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const LogIn())
    );
  }

  // Lógica para Eliminar Cuenta
  deleteAccount() async {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel")
            ),
            TextButton(
              onPressed: () async {
                 User? user = FirebaseAuth.instance.currentUser;
                 if (user != null) {
                   // 1. Borrar datos de Firestore
                   await DatabaseMethods().deleteUser(user.uid);
                   // 2. Borrar usuario de Auth
                   await user.delete();
                   // 3. Ir a la pantalla de registro
                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp()));
                 }
              }, 
              child: const Text("Delete", style: TextStyle(color: Colors.red))
            ),
          ],
        );
      }
    );
  }

  @override
  void initState() {
    getProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo general blanco
      body: SingleChildScrollView(
        child: Column(
          children: [
            // PARTE SUPERIOR (Header + Foto)
            Stack(
              children: [
                // Fondo Morado Curvo
                Container(
                  padding: const EdgeInsets.only(top: 45.0, left: 20.0, right: 20.0),
                  height: MediaQuery.of(context).size.height / 4.3,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Color(0xff6053f8),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(400, 105.0) // Curva suave
                    )
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ),
                
                // Foto de Perfil Centrada
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 6.5),
                    child: Material(
                      elevation: 10.0,
                      borderRadius: BorderRadius.circular(60),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        // Aquí usamos una imagen genérica. 
                        // Si no tienes "boy.png", puedes cambiarlo por un Icono grande.
                        child: Image.asset(
                          "lib/images/boy.png", 
                          height: 120, 
                          width: 120, 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120, width: 120, 
                              color: Colors.grey[200],
                              child: const Icon(Icons.person, size: 60, color: Colors.grey)
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30.0),

            // TARJETA: NOMBRE
            _buildInfoCard(Icons.person, "Name", name),
            
            const SizedBox(height: 20.0),

            // TARJETA: EMAIL
            _buildInfoCard(Icons.email, "Email", email),
            
            const SizedBox(height: 20.0),

            // BOTÓN: LOGOUT
            GestureDetector(
              onTap: logOut,
              child: _buildActionCard(Icons.logout, "LogOut", false),
            ),

            const SizedBox(height: 20.0),

            // BOTÓN: DELETE ACCOUNT
            GestureDetector(
              onTap: deleteAccount,
              child: _buildActionCard(Icons.delete_outline, "Delete Account", true),
            ),
            
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  // Widget para las tarjetas de información (Nombre, Email)
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 3.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xff6053f8), size: 28), // Icono morado
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500)),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget para los botones de acción (Logout, Delete)
  Widget _buildActionCard(IconData icon, String title, bool isDestructive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 3.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: isDestructive ? Colors.red : const Color(0xff6053f8), size: 28),
                  const SizedBox(width: 20.0),
                  Text(title,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey)
            ],
          ),
        ),
      ),
    );
  }
}