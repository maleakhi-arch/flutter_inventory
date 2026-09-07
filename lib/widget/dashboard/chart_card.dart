import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {

  const ChartCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Card(

      child: SizedBox(

        height: 300,

        child: Center(

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: const [

              Icon(
                Icons.bar_chart,
                size: 80,
                color: Colors.blue,
              ),

              SizedBox(height: 15),

              Text(
                "Grafik Dashboard",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                "Chart akan ditambahkan pada tahap berikutnya",
              ),

            ],

          ),

        ),

      ),

    );

  }
}