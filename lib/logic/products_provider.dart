import 'package:flutter/foundation.dart';
import '../model/product.dart';
import '../services/product_service.dart';
import 'package:flutter/material.dart';

enum SortOrder { 
  none, 
  priceAscending, 
  priceDescending,
  nameAscending,
  nameDescending,
}

class ProductsProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  SortOrder _currentSortOrder = SortOrder.none;
  String? _selectedBrand; // Добавляем фильтр по фирме
  double _minPrice = 0;
  double _maxPrice = 200000; // Обновляем диапазон цен
  String? _error;
  bool _isLoading = false;

  List<Product> get products {
    if (_searchQuery.isEmpty && _currentSortOrder == SortOrder.none && 
        _selectedBrand == null && _minPrice == 0 && _maxPrice == 200000) {
      return [..._products];
    }
    return [..._filteredProducts];
  }

  String? get error => _error;
  String get searchQuery => _searchQuery;
  SortOrder get currentSortOrder => _currentSortOrder;
  String? get selectedBrand => _selectedBrand; // Геттер для выбранной фирмы
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get isLoading => _isLoading;

  // Список доступных фирм
  List<String> get availableBrands {
    final brands = ['Acer', 'Lenovo', 'Ninkear', 'N4000'];
    return brands;
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _updateFilteredProducts();
  }

  void setSortOrder(SortOrder order) {
    _currentSortOrder = order;
    _updateFilteredProducts();
  }

  // Сеттер для выбранной фирмы
  void setSelectedBrand(String? brand) {
    _selectedBrand = brand;
    _updateFilteredProducts();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    _updateFilteredProducts();
  }

  void _updateFilteredProducts() {
    _filteredProducts = List.from(_products);

    // Применяем фильтр по фирме
    if (_selectedBrand != null) {
      _filteredProducts = _filteredProducts
          .where((product) => product.title.contains(_selectedBrand!))
          .toList();
    }

    // Применяем фильтр по цене
    _filteredProducts = _filteredProducts
        .where((product) => 
            product.price >= _minPrice && 
            product.price <= _maxPrice)
        .toList();

    // Применяем поиск
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((product) =>
              product.title.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Применяем сортировку
    switch (_currentSortOrder) {
      case SortOrder.priceAscending:
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOrder.priceDescending:
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOrder.nameAscending:
        _filteredProducts.sort((a, b) => 
          a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOrder.nameDescending:
        _filteredProducts.sort((a, b) => 
          b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case SortOrder.none:
        break;
    }

    // Обновляем состояние после завершения кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> init() async {
    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final fetchedProducts = await _productService.getProducts();
      _products = fetchedProducts;
      _updateFilteredProducts();
    } catch (e) {
      _error = 'Failed to fetch products: ${e.toString()}';
      _products = [];
      _filteredProducts = [];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    try {
      _error = null;
      final result = await _productService.updateProduct(updatedProduct);
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index >= 0) {
        _products[index] = result;
        _updateFilteredProducts();
      }
    } catch (e) {
      _error = 'Failed to update product: ${e.toString()}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      throw e;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      _error = null;
      final success = await _productService.deleteProduct(id);
      if (success) {
        _products.removeWhere((p) => p.id == id);
        _updateFilteredProducts();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        _error = 'Failed to delete product';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e) {
      _error = 'Failed to delete product: ${e.toString()}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final newProduct = await _productService.createProduct(product);
      _products.add(newProduct);
      _updateFilteredProducts();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (error) {
      print('Error adding product: $error');
      rethrow;
    }
  }
}