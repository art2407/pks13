import 'package:flutter/material.dart';
import '../model/product.dart';
import '../pages/product_details_page.dart';
import '../logic/favorites_provider.dart';
import 'package:provider/provider.dart';
import '../logic/cart_provider.dart';

class ItemCard extends StatelessWidget {
  final Product product;
  
  const ItemCard({
    Key? key,
    required this.product,
  }) : super(key: key);

    @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsPage(product: product)));
      },
      child: Card(
        elevation: 2,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          Expanded(
            child: Image.network(
              product.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          
          // Название
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),

          // Цена и иконки
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 4.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${product.price} ₽',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Consumer<FavoritesProvider>(
                        builder: (context, favoritesProvider, child) {
                          final isFavorite = favoritesProvider.isFavorite(product);
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFavorite ? Colors.red : null,
                            ),
                            onPressed: () {
                              favoritesProvider.toggleFavorite(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite 
                                        ? 'Товар удален из избранного' 
                                        : 'Товар добавлен в избранное'
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                                        SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.shopping_cart,
                          size: 18,
                        ),
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Товар добавлен в корзину'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
