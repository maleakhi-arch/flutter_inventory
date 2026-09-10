import 'package:flutter/material.dart';

import 'package:flutter_inventory/core/services/user_service.dart';
import 'package:flutter_inventory/core/ui/app_feedback.dart';
import 'package:flutter_inventory/core/ui/app_state_view.dart';
import 'package:flutter_inventory/models/user_model.dart';
import 'package:flutter_inventory/pages/user/edit_user_page.dart';
import 'package:flutter_inventory/pages/user/tambah_user_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService userService = UserService();
  final TextEditingController searchController = TextEditingController();

  List<UserModel> users = [];

  bool isLoading = true;
  String? errorMessage;

  String searchQuery = "";
  String selectedRole = "semua";

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
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await userService.getUsers();

      if (!mounted) return;

      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Gagal mengambil daftar user.";
      });
    }
  }

  List<UserModel> get filteredUsers {
    final query = searchQuery.trim().toLowerCase();

    return users.where((user) {
      final matchSearch =
          query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);

      final matchRole = selectedRole == "semua" || user.role == selectedRole;

      return matchSearch && matchRole;
    }).toList();
  }

  Future<void> tambahUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahUserPage()),
    );

    if (result == true) {
      await loadUsers();

      if (!mounted) return;

      AppFeedback.success(context, "User berhasil ditambahkan");
    }
  }

  Future<void> editUser(UserModel user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditUserPage(user: user)),
    );

    if (result == true) {
      await loadUsers();

      if (!mounted) return;

      AppFeedback.success(context, "Data user berhasil diperbarui");
    }
  }

  Future<void> hapusUser(UserModel user) async {
    final confirm = await AppFeedback.confirmDelete(
      context,
      title: "Hapus User",
      message: 'Akun "${user.name}" (${user.email}) akan dihapus.',
    );

    if (!confirm) return;

    try {
      final success = await userService.deleteUser(user.id);

      if (!mounted) return;

      if (success) {
        AppFeedback.success(context, "User berhasil dihapus");

        await loadUsers();
      } else {
        AppFeedback.error(context, "Gagal menghapus user");
      }
    } catch (_) {
      if (!mounted) return;

      AppFeedback.error(context, "Terjadi kesalahan saat menghapus user");
    }
  }

  String roleLabel(String role) {
    switch (role) {
      case "admin":
        return "Admin";
      case "user":
        return "User";
      case "view_only":
        return "Viewer";
      default:
        return role;
    }
  }

  Color roleColor(String role) {
    switch (role) {
      case "admin":
        return const Color(0xff2563eb);
      case "user":
        return const Color(0xff16a34a);
      case "view_only":
        return const Color(0xffd97706);
      default:
        return const Color(0xff6b7280);
    }
  }

  Color roleBackground(String role) {
    switch (role) {
      case "admin":
        return const Color(0xffeff6ff);
      case "user":
        return const Color(0xffecfdf3);
      case "view_only":
        return const Color(0xfffff7ed);
      default:
        return const Color(0xfff3f4f6);
    }
  }

  Widget roleBadge(String role) {
    final color = roleColor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: roleBackground(role),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        roleLabel(role),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget userCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: const Color(0xffeff6ff),
            child: Text(
              user.name.isEmpty ? "?" : user.name[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xff2563eb),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xff6b7280),
                  ),
                ),
                const SizedBox(height: 9),
                roleBadge(user.role),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: "Aksi User",
            onSelected: (value) {
              if (value == "edit") {
                editUser(user);
              }

              if (value == "hapus") {
                hapusUser(user);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "edit",
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Color(0xff2563eb),
                      size: 19,
                    ),
                    SizedBox(width: 10),
                    Text("Edit User"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "hapus",
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xffdc2626),
                      size: 19,
                    ),
                    SizedBox(width: 10),
                    Text("Hapus User"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text(
          "Management User",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: isLoading ? null : loadUsers,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Cari nama, email, atau role...",
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();

                              setState(() {
                                searchQuery = "";
                              });
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Filter Role",
                    prefixIcon: Icon(Icons.manage_accounts_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: "semua", child: Text("Semua Role")),
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                    DropdownMenuItem(value: "user", child: Text("User")),
                    DropdownMenuItem(value: "view_only", child: Text("Viewer")),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedRole = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_outlined,
                  size: 16,
                  color: Color(0xff6b7280),
                ),
                const SizedBox(width: 6),
                Text(
                  "${filteredUsers.length} User",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff6b7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: isLoading
                ? const AppStateView.loading(
                    title: "Memuat user",
                    message: "Sedang mengambil daftar pengguna.",
                  )
                : errorMessage != null
                ? AppStateView.error(
                    title: "User gagal dimuat",
                    message: errorMessage!,
                    onAction: loadUsers,
                  )
                : filteredUsers.isEmpty
                ? AppStateView.empty(
                    icon: Icons.people_outline_rounded,
                    title: searchQuery.trim().isNotEmpty
                        ? "User tidak ditemukan"
                        : "Belum ada user",
                    message: searchQuery.trim().isNotEmpty
                        ? "Coba gunakan pencarian atau filter lain."
                        : "Akun pengguna akan muncul di sini.",
                  )
                : RefreshIndicator(
                    onRefresh: loadUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return userCard(filteredUsers[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tambahUser,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text("Tambah User"),
      ),
    );
  }
}
