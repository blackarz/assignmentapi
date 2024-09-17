import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../widgets/product_item.dart';
import 'add_new_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> productList = [];
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    getProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          IconButton(
            onPressed: getProductList,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _inProgress
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          itemCount: productList.length,
          itemBuilder: (context, index) {
            final product = productList[index];
            return ProductItem(
              product: product,
              onEdit: () => _onTapEditProduct(product),
              onDelete: () => _onTapDeleteProduct(product.id),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewProductScreen(),
            ),
          ).then((_) => getProductList()); // Refresh after adding a product
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> getProductList() async {
    setState(() {
      _inProgress = true;
    });

    try {
      Uri uri = Uri.parse('http://164.68.107.70:6060/api/v1/ReadProduct');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        productList.clear();
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        for (var item in jsonResponse['data']) {
          Product product = Product(
            id: item['_id'],
            productName: item['ProductName'] ?? '',
            productCode: item['ProductCode'] ?? '',
            productImage: item['Img'] ?? '',
            unitPrice: item['UnitPrice'] ?? '',
            quantity: item['Qty'] ?? '',
            totalPrice: item['TotalPrice'] ?? '',
            createdAt: item['CreatedDate'] ?? '',
          );
          productList.add(product);
        }
      } else {
        print('Failed to load products');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _inProgress = false;
      });
    }
  }

  void _onTapEditProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewProductScreen(product: product),
      ),
    ).then((_) => getProductList()); // Refresh list after editing
  }

  Future<void> _onTapDeleteProduct(String productId) async {
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        Uri uri = Uri.parse('http://164.68.107.70:6060/api/v1/DeleteProduct/$productId');
        final response = await http.delete(uri);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product deleted successfully')));
          getProductList(); // Refresh the list after deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete product')));
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }
}
