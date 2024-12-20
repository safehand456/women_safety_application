import 'package:flutter/material.dart';



class HomePage extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         foregroundColor: 
                        const Color.fromARGB(255, 197, 9, 144),
          toolbarHeight: 80,
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
        title: Text('Home Page'),
      ),
      body:Stack(
          children:[
             Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color.fromARGB(255, 243, 204, 236),
                  const Color.fromARGB(255, 232, 195, 221)
                ])
              ),
            ),  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(300,60)
                ),
                onPressed: () {},
                icon: Icon(Icons.contact_page),
                label: Text('Add Contact',style: TextStyle(color: const Color.fromARGB(255, 204, 50, 158)),),
                
              
          ),
              
              SizedBox(height: 20),
              ElevatedButton.icon(
                 style: ElevatedButton.styleFrom(
                  fixedSize: Size(300,60)
                ),

                onPressed: (){},
                icon: Icon(Icons.notification_important),
                label: Text('Alert Mode',style: TextStyle(color: const Color.fromARGB(255, 204, 50, 158)),),
                ),
              
              SizedBox(height: 20),
              ElevatedButton.icon(
                 style: ElevatedButton.styleFrom(
                  fixedSize: Size(300,60)
                ),
                onPressed: (){},
                icon: Icon(Icons.location_on),
                label: Text('Location',style: TextStyle(color: const Color.fromARGB(255, 204, 50, 158)),),
                ),
              
              SizedBox(height: 20),
              ElevatedButton.icon(
                 style: ElevatedButton.styleFrom(
                  fixedSize: Size(300,60)
                ),
                onPressed: (){},
                icon: Icon(Icons.mic),
                label: Text('Voice Assistant',style: TextStyle(color: const Color.fromARGB(255, 204, 50, 158)),),
                ),
              
            ],
          ),
        ),
      ),
          ]
      )
    );
  }
}
