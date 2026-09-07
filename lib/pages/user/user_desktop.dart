import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/services/user_service.dart';
import 'package:flutter_inventory/models/user_model.dart';

class UserDesktop extends StatefulWidget {
  const UserDesktop({super.key});

  @override
  State<UserDesktop> createState() => _UserDesktopState();
}

class _UserDesktopState extends State<UserDesktop> {
  final UserService userService = UserService();

  List<UserModel> users = [];

  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await userService.getUsers();

      if (!mounted) return;

      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Gagal mengambil data user');
    }
  }

  List<UserModel> get filteredUsers {
    if (searchQuery.trim().isEmpty) {
      return users;
    }

    final query = searchQuery.toLowerCase();

    return users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus User'),
          content: Text(
            'Apakah kamu yakin ingin menghapus akun ${user.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await userService.deleteUser(user.id);

    if (!mounted) return;

    if (success) {
      _showMessage('User berhasil dihapus');
      _loadUsers();
    } else {
      _showMessage('Gagal menghapus user');
    }
  }

  Future<void> _showUserForm({UserModel? user}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _UserFormDialog(
          user: user,
          userService: userService,
        );
      },
    );

    if (result == true) {
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff7f8fc),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 25),

            _buildToolbar(),

            const SizedBox(height: 20),

            _buildUserTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Management User',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Kelola akun dan hak akses pengguna sistem.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        OutlinedButton.icon(
          onPressed: isLoading ? null : _loadUsers,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh'),
        ),

        const SizedBox(width: 12),

        ElevatedButton.icon(
          onPressed: () => _showUserForm(),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Tambah User'),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffe8e8ed),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: Colors.grey,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Cari nama, email, atau role...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${filteredUsers.length} User',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable() {
    if (isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (filteredUsers.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xffe8e8ed),
          ),
        ),
        child: const Center(
          child: Text(
            'Belum ada user',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffe8e8ed),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: DataTable(
          headingRowHeight: 52,
          dataRowMinHeight: 64,
          dataRowMaxHeight: 70,
          columnSpacing: 35,
          horizontalMargin: 20,
          columns: const [
            DataColumn(
              label: Text(
                'USER',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'EMAIL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'ROLE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'AKSI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          rows: filteredUsers.map((user) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                DataCell(
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                DataCell(
                  _buildRoleBadge(user.role),
                ),

                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () {
                          _showUserForm(user: user);
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),
                      ),

                      IconButton(
                        tooltip: 'Hapus',
                        onPressed: () {
                          _deleteUser(user);
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    String label;
    Color color;

    switch (role) {
      case 'admin':
        label = 'Admin';
        color = Colors.blue;
        break;

      case 'user':
        label = 'User';
        color = Colors.green;
        break;

      case 'view_only':
        label = 'Viewer';
        color = Colors.orange;
        break;

      default:
        label = role;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final UserService userService;

  const _UserFormDialog({
    required this.user,
    required this.userService,
  });

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  String role = 'user';
  bool loading = false;
  bool obscurePassword = true;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.user?.name ?? '',
    );

    emailController = TextEditingController(
      text: widget.user?.email ?? '',
    );

    passwordController = TextEditingController();

    role = widget.user?.role ?? 'user';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      return;
    }

    if (!isEdit && passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 6 karakter'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    bool success;

    if (isEdit) {
      success = await widget.userService.updateUser(
        widget.user!.id,
        nameController.text.trim(),
        emailController.text.trim(),
        role,
      );
    } else {
      success = await widget.userService.tambahUser(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        role,
      );
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Gagal memperbarui user'
                : 'Gagal menambahkan user',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEdit ? 'Edit User' : 'Tambah User',
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              if (!isEdit)
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

              if (!isEdit)
                const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.security_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin'),
                  ),
                  DropdownMenuItem(
                    value: 'user',
                    child: Text('User'),
                  ),
                  DropdownMenuItem(
                    value: 'view_only',
                    child: Text('Viewer'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    role = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: loading
              ? null
              : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),

        ElevatedButton(
          onPressed: loading ? null : save,
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEdit ? 'Simpan Perubahan' : 'Tambah User',
                ),
        ),
      ],
    );
  }
}