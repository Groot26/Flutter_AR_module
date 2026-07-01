import 'package:ar_demo/domain/models/animal_model.dart';
import 'package:ar_demo/presentation/ar/ar_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  static const animals = [
    AnimalModel(
      name: "Cat",
      modelPath: "assets/models/cat.glb",
      icon: Icons.pets_rounded,
    ),
    AnimalModel(
      name: "Tiger",
      modelPath: "assets/models/tiger.glb",
      icon: Icons.pets,
    ),
    AnimalModel(
      name: "Koi Fish",
      modelPath: "assets/models/koi_fish.glb",
      icon: Icons.water,
    ),
    AnimalModel(
      name: "Ducky",
      modelPath: "assets/models/ducky.glb",
      icon: CupertinoIcons.sun_dust_fill,
    ),
    AnimalModel(
      name: "Ducky",
      modelPath: "assets/models/ducky_textured.glb",
      icon: CupertinoIcons.sun_dust_fill,
    ),
    AnimalModel(
      name: "Astronaut",
      modelPath: "assets/models/dinosaur.glb",
      icon: CupertinoIcons.wifi,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR Animals"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: animals.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: .9,
          ),
          itemBuilder: (context, index) {
            final animal = animals[index];

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Get.to(() => ARScreen(animal: animal));
              },
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(animal.icon, size: 20, color: Colors.orange),
                      const SizedBox(height: 20),
                      Text(
                        animal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => ARScreen(animal: animal));
                        },
                        icon: const Icon(Icons.view_in_ar),
                        label: const Text("AR"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Get.to(() => ARScreen(animal: animal));
