import "package:flutter/material.dart";
import "package:package_delivery_app/services/widget_support.dart";

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(   // 👈 evita el overflow
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(height: 20),

                // 👇 Se reduce un poco la imagen para pantallas chicas
                Image.asset(
                  'lib/images/onboard.png',
                  width: MediaQuery.of(context).size.width * 0.9,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 40),

                Text(
                  "Track your parcel\nfrom anywhere",
                  textAlign: TextAlign.center,
                  style: AppWidget.HeadLineTextfeildStyle(),
                ),

                SizedBox(height: 25),

                Text(
                  "Check the progress of\nyour deliveries",
                  textAlign: TextAlign.center,
                  style: AppWidget.SimpleTextfeildStyle(),
                ),

                SizedBox(height: 35),

                Material(
                  elevation: 3.0,
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.7,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Color(0xfff8ae39),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        "Track Now",
                        style: AppWidget.WhiteTextfeildStyle(),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
