import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xffe8e8ed),
          width: 1,
        ),
      ),
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // =========================
            // ICON
            // =========================
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),

            const SizedBox(width: 12),

            // =========================
            // CONTENT
            // =========================
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: Color(0xff777777),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 23,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff202124),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // =========================
            // MORE
            // =========================
            const Icon(
              Icons.more_horiz,
              size: 18,
              color: Color(0xffb5b5b5),
            ),
          ],
        ),
      ),
    );
  }
}