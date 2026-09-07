import 'package:flutter/material.dart';

import '../../layouts/responsive_layout.dart';
import 'home_mobile.dart';
import 'home_desktop.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: HomeMobile(),
      desktop: HomeDesktop(),
    );
  }
}