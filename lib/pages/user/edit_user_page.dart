// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/services/user_service.dart';
import 'package:flutter_inventory/models/user_model.dart';

class EditUserPage extends StatefulWidget {
  final UserModel user;

  const EditUserPage({
    super.key,
    required this.user,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final UserService service = UserService();

  late TextEditingController nameController;
  late TextEditingController emailController;

  String role = "user";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    role = widget.user.role;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> updateUser() async {
    setState(() {
      isLoading = true;
    });

    final berhasil = await service.updateUser(
      widget.user.id,
      nameController.text,
      emailController.text,
      role,
    );

    setState(() {
      isLoading = false;
    });

    if (berhasil) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengubah user"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( // Menghindari overflow jika keyboard muncul
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nama",
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(
                  labelText: "Role",
                ),
                items: const [
                  DropdownMenuItem(
                    value: "admin",
                    child: Text("Admin"),
                  ),
                  DropdownMenuItem(
                    value: "user",
                    child: Text("User"),
                  ),
                  DropdownMenuItem(
                    value: "view_only",
                    child: Text("Viewer"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      role = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 25),
              
              // TOMBOL UPDATE USER
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateUser,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("UPDATE USER"),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // TOMBOL HAPUS USER (Baru ditambahkan)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white, // Warna teks putih agar kontras
                  ),
                  onPressed: isLoading ? null : () async {
                    final konfirmasi = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus User"),
                        content: const Text("Yakin ingin menghapus user ini?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text("Batal"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text("Hapus"),
                          ),
                        ],
                      ),
                    );

                    if (konfirmasi != true) return;

                    setState(() {
                      isLoading = true;
                    });

                    final berhasil = await service.deleteUser(widget.user.id);

                    setState(() {
                      isLoading = false;
                    });

                    if (berhasil) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Gagal menghapus user"),
                        ),
                      );
                    }
                  },
                  child: const Text("HAPUS USER"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}