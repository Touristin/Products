import 'package:flutter/material.dart';
import 'models.dart';
import 'product_details.dart';

class FavoritesTab extends StatefulWidget {
  final List<Product> products;

  FavoritesTab({required this.products});

  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProducts = widget.products;

    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];

              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListTile(
                  title: Text(product.label, style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(foodId: product.foodId),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
