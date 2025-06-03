import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: const Color(0xFF00C851),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              child: Icon(
                Icons.person,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'User Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'user@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Account options
            _buildOptionItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                // TODO: Implement edit profile
              },
            ),
            
            _buildOptionItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                // TODO: Implement notifications settings
              },
            ),
            
            _buildOptionItem(
              icon: Icons.favorite_border,
              title: 'Favorite Plants',
              onTap: () {
                // TODO: Implement favorites
              },
            ),
            
            _buildOptionItem(
              icon: Icons.history,
              title: 'History',
              onTap: () {
                // TODO: Implement history
              },
            ),
            
            _buildOptionItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                // TODO: Implement help and support
              },
            ),
            
            _buildOptionItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                // TODO: Implement about
              },
            ),
            
            const SizedBox(height: 20),
            
            // Sign out button
            TextButton(
              onPressed: () {
                // TODO: Implement sign out
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.logout, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00C851)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
