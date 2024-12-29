import 'package:flutter/material.dart';
import 'package:women_safety_application/auth/loginscreen.dart';
import 'package:women_safety_application/auth/register.dart';

class ChooseScreen extends StatefulWidget {
  const ChooseScreen({super.key});

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {


  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
           foregroundColor: 
                        const Color.fromARGB(255, 180, 38, 139),
          
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 226, 106, 206),
                  const Color.fromARGB(255, 232, 195, 221)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          toolbarHeight: 70,
          title: Text(
            'Safe Hands',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 218, 164, 210),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/imgg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Centered Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(200, 50)), // Button size
                      foregroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 228, 67, 182),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 233, 205, 228),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder:(context)=> LoginPage()));
                      // Handle Login Button Press
                    },
                    child: Text("Login"),
                  ),
                  SizedBox(height: 10),
                  Text("or"),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(200, 50)), // Button size
                      foregroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 228, 67, 182),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 233, 205, 228),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder:(context)=> SignUpPage()));
                      // Handle Sign-Up Button Press
                    },
                    child: Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
