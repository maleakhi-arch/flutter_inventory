import 'package:flutter/material.dart';

class AppStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  const AppStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = const Color(0xff9ca3af),
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  const AppStateView.loading({
    super.key,
    this.title = "Memuat data...",
    this.message = "Mohon tunggu sebentar.",
  }) : icon = Icons.hourglass_empty_rounded,
       iconColor = const Color(0xff2563eb),
       actionLabel = null,
       onAction = null,
       loading = true;

  const AppStateView.empty({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  }) : iconColor = const Color(0xff9ca3af),
       loading = false;

  const AppStateView.error({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel = "Coba Lagi",
    this.onAction,
  }) : icon = Icons.error_outline_rounded,
       iconColor = const Color(0xffdc2626),
       loading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              else
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 27),
                ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff374151),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xff9ca3af),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
