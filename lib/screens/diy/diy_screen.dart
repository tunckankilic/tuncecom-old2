import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuncecom/models/diy_model.dart';
import 'package:tuncecom/screens/diy/diy_details.dart';

class DIYScreen extends StatelessWidget {
  static const routeName = "/diy";

  const DIYScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('diyCollection').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Hiç ürün bulunamadı.'));
          } else {
            final products = snapshot.data!.docs;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                List<dynamic> productDetails = [];
                final productData =
                    products[index].data() as Map<String, dynamic>;
                productDetails.add(productData);
                final productId = productData['id'];
                productDetails.add(productId);
                final productName = productData['title'];
                productDetails.add(productName);
                final productDescription = productData['description'];
                productDetails.add(productDescription);
                final productImagePath = productData['imagePath'];
                productDetails.add(productName);
                final productSteps = List<String>.from(productData['steps']);

                return ListTile(
                  title: Text(productName),
                  leading: SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.network(productImagePath),
                  ),
                  onTap: () async {
                    // Ürün detaylarına gitmek için tıklama işlemini burada yapabilirsiniz
                    log('navigateToProductDetails fonksiyonu çağrıldı.');
                    await navigateToProductDetails(context, productSteps);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> navigateToProductDetails(
    BuildContext context,
    List<String> productSteps,
  ) async {
    final List<DIYModel> productDetails = [];

    for (String stepId in productSteps) {
      await FirebaseFirestore.instance
          .collection('diyCollection')
          .doc(stepId)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final model = DIYModel(
            description: data['description'],
            id: data['id'],
            imageUrl: data['imagePath'],
            steps: List<String>.from(data['steps']),
            title: data['title'],
          );
          productDetails.add(model);
        }
      });
    }

    // Ürün detayları alındıysa, detay sayfasına geçiş yapabilirsiniz.
    if (productDetails.isNotEmpty) {
      print('Sayfa geçişi yapılıyor.');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DIYDetails(productDetails: productDetails),
        ),
      );
    }
  }
}