import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/ui/app_state_view.dart';
import 'package:flutter_inventory/core/ui/app_feedback.dart';
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

      _showError('Gagal mengambil data user');
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

  void _showSuccess(String message) {
    AppFeedback.success(context, message);
  }

  void _showError(String message) {
    AppFeedback.error(context, message);
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await AppFeedback.confirmDelete(
      context,
      title: 'Hapus User',
      message:
          'Akun "${user.name}" (${user.email}) akan dihapus dan tidak dapat digunakan lagi.',
    );

    if (!confirm) return;

    try {
      final success = await userService.deleteUser(user.id);
      if (!mounted) return;
      if (success) {
        _showSuccess('User berhasil dihapus');
        await _loadUsers();
      } else {
        _showError('Gagal menghapus user');
      }
    } catch (_) {
      if (!mounted) return;
      _showError('Terjadi kesalahan saat menghapus user');
    }
  }

  Future<void> _showUserForm({UserModel? user}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _UserFormDialog(user: user, userService: userService);
      },
    );

    if (result == true) {
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff6f7fb),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            _buildToolbar(),
            const SizedBox(height: 16),
            Expanded(child: _buildUserTable()),
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
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff111827),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Kelola akun dan hak akses pengguna sistem.',
                style: TextStyle(fontSize: 13, color: Color(0xff6b7280)),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: isLoading ? null : _loadUsers,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Refresh'),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => _showUserForm(),
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Cari nama, email, atau role...',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffe5e7eb)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_outlined,
                  size: 17,
                  color: Color(0xff6b7280),
                ),
                const SizedBox(width: 7),
                Text(
                  '${filteredUsers.length} User',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable() {
    if (isLoading) {
      return const AppStateView.loading(
        title: "Memuat user",
        message: "Sedang mengambil daftar akun pengguna.",
      );
    }
    if (filteredUsers.isEmpty) {
      return AppStateView.empty(
        icon: Icons.people_outline_rounded,
        title: searchQuery.trim().isEmpty
            ? "Belum ada user"
            : "User tidak ditemukan",
        message: searchQuery.trim().isEmpty
            ? "Akun pengguna yang dibuat akan muncul di sini."
            : "Coba gunakan nama, email, atau role yang berbeda.",
        actionLabel: searchQuery.trim().isEmpty ? "Tambah User" : null,
        onAction: searchQuery.trim().isEmpty ? () => _showUserForm() : null,
      );
    }
    return Container(
      width: double.infinity,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xfff8fafc),
                  ),
                  headingRowHeight: 52,
                  dataRowMinHeight: 66,
                  dataRowMaxHeight: 72,
                  columnSpacing: 40,
                  horizontalMargin: 20,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'USER',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xff4b5563),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'EMAIL',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xff4b5563),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ROLE',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xff4b5563),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'AKSI',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xff4b5563),
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
                                backgroundColor: const Color(0xffeff6ff),
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Color(0xff2563eb),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff6b7280),
                            ),
                          ),
                        ),
                        DataCell(_buildRoleBadge(user.role)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit User',
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xffeff6ff),
                                  foregroundColor: const Color(0xff2563eb),
                                ),
                                onPressed: () {
                                  _showUserForm(user: user);
                                },
                                icon: const Icon(Icons.edit_outlined, size: 18),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                tooltip: 'Hapus User',
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xfffff1f2),
                                  foregroundColor: const Color(0xffdc2626),
                                ),
                                onPressed: () {
                                  _deleteUser(user);
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
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
          },
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    String label;
    Color color;
    Color background;
    switch (role) {
      case 'admin':
        label = 'Admin';
        color = const Color(0xff2563eb);
        background = const Color(0xffeff6ff);
        break;
      case 'user':
        label = 'User';
        color = const Color(0xff16a34a);
        background = const Color(0xffecfdf3);
        break;
      case 'view_only':
        label = 'Viewer';
        color = const Color(0xffd97706);
        background = const Color(0xfffff7ed);
        break;
      default:
        label = role;
        color = const Color(0xff6b7280);
        background = const Color(0xfff3f4f6);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final UserService userService;

  const _UserFormDialog({required this.user, required this.userService});

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

    nameController = TextEditingController(text: widget.user?.name ?? '');

    emailController = TextEditingController(text: widget.user?.email ?? '');

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
        const SnackBar(content: Text('Password minimal 6 karakter')),
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
            isEdit ? 'Gagal memperbarui user' : 'Gagal menambahkan user',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xffeff6ff),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      isEdit
                          ? Icons.edit_outlined
                          : Icons.person_add_alt_1_rounded,
                      color: const Color(0xff2563eb),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit User' : 'Tambah User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff111827),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isEdit
                              ? 'Perbarui informasi dan hak akses user.'
                              : 'Buat akun baru untuk mengakses sistem.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff6b7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      hintText: 'Nama pengguna',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'nama@perusahaan.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  if (!isEdit) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Minimal 6 karakter',
                        prefixIcon: const Icon(Icons.lock_outline),
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
                  ],
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Admin — Akses penuh'),
                      ),
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('User — Operasional'),
                      ),
                      DropdownMenuItem(
                        value: 'view_only',
                        child: Text('Viewer — Hanya melihat'),
                      ),
                    ],
                    onChanged: loading
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              role = value;
                            });
                          },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: loading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: loading ? null : save,
                    icon: loading
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isEdit
                                ? Icons.save_outlined
                                : Icons.person_add_alt_1_rounded,
                            size: 18,
                          ),
                    label: Text(
                      loading
                          ? 'Menyimpan...'
                          : isEdit
                          ? 'Simpan Perubahan'
                          : 'Tambah User',
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
}
