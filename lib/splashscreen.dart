import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety_application/choosig.dart';
import 'package:women_safety_application/notfy_dun.dart';
import 'package:women_safety_application/user/userinterface.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



 

 
  // @override
  void initState(){
    super.initState();
    sendAlert();
    
  }

  bool isLoading = false;

  bool ? isLogged;
  String ? name;


  void  sendAlert() async{


setState(() {
  isLoading = true;
});

    


    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogged = prefs.getBool('alertMode');
     name = prefs.getString('auth_user');

     print(isLogged);
     print(name);

    
    setState(() {
        
      });


    if(name != null ){
      if(isLogged == true){

      await sendNotificationToDevice('Alert', '$name  Danger click here to loction and call near police station' );
      
      
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
              Icon(Icons.dangerous,size: 100,color: Colors.red,),
              ElevatedButton.icon(onPressed: () {
                 Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(),), (route) => false,);
              }, label: Text('Go to home'))
            ],
          ),
        ),
      ),), (route) => false,);



    }else if(isLogged == false){

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(),),(route) => false,);
    }else{

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(),),(route) => false,);



    }
    }else{
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ChooseScreen(),),(route) => false,);


    }

   
    setState(() {
      isLoading = false;
    });


  }




  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Center(
        
        child: isLoading ? CircularProgressIndicator()  : Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/sample logo.png'),
            fit: BoxFit.cover)
          ),
        ) 
      )
    ));
  }
}