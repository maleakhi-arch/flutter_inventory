// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/services/user_service.dart';
import 'package:flutter_inventory/models/user_model.dart';
import 'package:flutter_inventory/pages/user/tambah_user_page.dart';
import 'package:flutter_inventory/pages/user/edit_user_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService service = UserService();
  final TextEditingController searchController = TextEditingController();

  List<UserModel> users = [];
  bool isLoading = true;
  String keyword = "";
  String selectedRole = "Semua";

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadUsers() async {
    final data = await service.getUsers();
    setState(() {
      users = data;
      isLoading = false;
    });
  }

  // Refactor Logika Filter menggunakan Getter
  List<UserModel> get filteredUsers {
    return users.where((user) {
      final cocokSearch = user.name.toLowerCase().contains(keyword) ||
          user.email.toLowerCase().contains(keyword);

      final cocokRole = selectedRole == "Semua" || user.role == selectedRole;

      return cocokSearch && cocokRole;
    }).toList();
  }

  Color roleColor(String role) {
    switch (role) {
      case "admin":
        return Colors.red;
      case "user":
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen User"),
      ),
      body: Column(
        children: [
          // Bagian Search dan Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Cari user...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      keyword = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Semua", child: Text("Semua")),
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                    DropdownMenuItem(value: "user", child: Text("User")),
                    DropdownMenuItem(value: "view_only", child: Text("Viewer")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Bagian Daftar User (Dengan RefreshIndicator & Kondisi Loading)
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: loadUsers,
                    child: filteredUsers.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 50),
                              Center(child: Text("Tidak ada data user")),
                            ],
                          )
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(user.name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user.email),
                                      const SizedBox(height: 5),
                                      Chip(
                                        label: Text(user.role.toUpperCase(), 
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: roleColor(user.role),
                                      )
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditUserPage(user: user),
                                        ),
                                      );

                                      if (result == true) {
                                        loadUsers();
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final hasil = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahUserPage(),
            ),
          );

          if (hasil == true) {
            loadUsers();
          }
        },
      ),
    );
  }
}