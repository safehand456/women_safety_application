import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WomenSafetyProductsScreen extends StatelessWidget {
  // List of products (without using a model class)
  final List<Map<String, String>> products = [
    {
      "name": "Vegan Leather Safety Keychain Set",
      "imageUrl": "https://tse2.mm.bing.net/th?id=OIP.kVItq-ZoqfoEBGZ0jXf7fwHaHa&pid=Api",
      "price": "₹999",
      "description": "Portable self-defense keychain set with essential safety tools.",
      "buyUrl": "https://www.amazon.in/Vegan-Leather-Safety-Keychain-Women/dp/B099WNJL14",
    },
    {
      "name": "Personal Safety Alarm Keychain",
      "imageUrl": "https://tse2.mm.bing.net/th?id=OIP.oKBPvKfajzUyit6ltnYEmAHaFC&pid=Api",
      "price": "₹599",
      "description": "140dB loud alarm to alert others in an emergency.",
      "buyUrl": "https://www.amazon.com/Personal-Keychain-Children-Elderly-Emergency/dp/B0BF8NJG57",
    },
    {
      "name": "Go Guarded Self-Defense Ring",
      "imageUrl": "https://tse1.mm.bing.net/th?id=OIP._slxGWWpw1_5yr9F3F-kygHaF5&pid=Api",
      "price": "₹1,299",
      "description": "Wearable self-defense tool for runners and active women.",
      "buyUrl": "https://goguarded.com/",
    },
    {
      "name": "AMIR Safety Keychain Set",
      "imageUrl": "https://tse2.mm.bing.net/th?id=OIP.f9uaKACBzdBF7SzrUAmflgHaHr&pid=Api",
      "price": "₹1,499",
      "description": "10-piece safety kit including alarms and defense tools.",
      "buyUrl": "https://www.amazon.com/Keychain-Accessories-Defense-Personal-Whistle/dp/B09DPFJCFT",
    },
  ];

  // Function to open the buy link
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Women Safety Products")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(products[index]["imageUrl"]!, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(products[index]["name"]!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(products[index]["description"]!, style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 5),
                      Text("Price: ${products[index]["price"]!}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: () => _launchURL(products[index]["buyUrl"]!),
                        child: Text("Buy Now", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
