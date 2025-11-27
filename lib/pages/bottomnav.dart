import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:package_delivery_app/pages/home.dart';
import 'package:package_delivery_app/pages/order.dart';
import 'package:package_delivery_app/pages/post.dart';
import 'package:package_delivery_app/pages/profile.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {

  late List <Widget> pages;

  late Home homePage;
  late PostPage postPage;
  late Order orderPage;
  late Profile profilePage;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    homePage = const Home();
    postPage = const PostPage();
    orderPage = const Order();
    profilePage = const Profile();

    pages = [homePage, postPage, orderPage, profilePage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.black,
        height: 70.0,
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const <Widget>[
          Icon(Icons.home, size: 34.0, color: Colors.white),
          Icon(Icons.post_add, size: 34.0, color: Colors.white),
          Icon(Icons.shopping_bag, size: 34.0, color: Colors.white),
          Icon(Icons.person, size: 34.0, color: Colors.white),
        ],
      ),
      body: pages[currentIndex],
    );
  }
}