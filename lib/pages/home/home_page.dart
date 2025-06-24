// lib/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text("首页")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: controller.features.map((feature) {
            return FeatureCard(feature: feature);
          }).toList(),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final Map<String, dynamic> feature;

  const FeatureCard({required this.feature, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => feature['onTap'] is Function ? feature['onTap']() : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              feature['icon'],
              size: 56,
              color: Colors.blue,
            ),
            SizedBox(height: 12),
            Text(
              feature['title'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
