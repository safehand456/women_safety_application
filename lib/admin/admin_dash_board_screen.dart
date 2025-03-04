import 'package:flutter/material.dart';
import 'package:women_safety_application/admin/admin_add_dangers_places.dart';
import 'package:women_safety_application/admin/admin_view_posts.dart';
import 'package:women_safety_application/admin/admin_view_users.dart';
import 'package:women_safety_application/admin/admin_view_videos.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.pink.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Two columns
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              icon: Icons.person,
              title: "View Users",
              onTap: () {
                
                // Navigate to View Users Screen
                                Navigator.push(context, MaterialPageRoute(builder: (context) => UsersListScreen(),));

              },
            ),
            _buildDashboardCard(
              icon: Icons.location_on,
              title: "Add Danger Places",
              onTap: () {
                // Navigate to Add Danger Places Screen
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDangerPlacesScreen(),));
              },
            ),
            _buildDashboardCard(
              icon: Icons.video_library,
              title: "View Reported Videos",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VideoListScreen(),));
                // Navigate to View Reported Videos Screen
              },
            ),
            _buildDashboardCard(
              icon: Icons.post_add,
              title: "View Posts",
              onTap: () {
                // Navigate to View Posts Screen
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminViewPosts(),));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.pink.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.pink.shade700),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
