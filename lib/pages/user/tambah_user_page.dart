// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/services/user_service.dart';

class TambahUserPage extends StatefulWidget {
  const TambahUserPage({super.key});

  @override
  State<TambahUserPage> createState() => _TambahUserPageState();
}

class _TambahUserPageState extends State<TambahUserPage> {

  final service = UserService();

  final nama = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  String role = "user";

  Future<void> simpan() async {

    final berhasil = await service.tambahUser(
      nama.text,
      email.text,
      password.text,
      role,
    );

    if(berhasil){

      Navigator.pop(context,true);

    }else{

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Gagal menambah user"),
        ),

      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Tambah User"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: nama,
              decoration: const InputDecoration(
                labelText: "Nama",
              ),
            ),

            const SizedBox(height:15),

            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height:15),

            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height:15),

            DropdownButtonFormField(

              value: role,

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

              onChanged: (v){

                setState(() {

                  role=v!;

                });

              },

            ),

            const SizedBox(height:30),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: simpan,

                child: const Text("SIMPAN"),

              ),

            )

          ],

        ),

      ),

    );

  }

}