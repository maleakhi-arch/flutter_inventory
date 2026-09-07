import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: ListView(
        children: [

          const SizedBox(height: 30),

          const Center(
            child: Icon(
              Icons.inventory,
              color: Colors.white,
              size: 70,
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "MEDIFRA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(color: Colors.white54),

          ListTile(
            leading: const Icon(Icons.dashboard,color: Colors.white),
            title: const Text(
              "Dashboard",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.inventory_2,color: Colors.white),
            title: const Text(
              "Barang",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.history,color: Colors.white),
            title: const Text(
              "Histori",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.people,color: Colors.white),
            title: const Text(
              "User",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),

          const Divider(color: Colors.white54),

          ListTile(
            leading: const Icon(Icons.logout,color: Colors.white),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),

        ],
      ),
    );
  }
}