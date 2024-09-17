import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class AddNewProductScreen extends StatefulWidget {
  final Product? product;

  const AddNewProductScreen({super.key, this.product});

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  final TextEditingController _productNameTEController = TextEditingController();
  final TextEditingController _unitPriceTEController = TextEditingController();
  final TextEditingController _totalPriceTEController = TextEditingController();
  final TextEditingController _imageTEController = TextEditingController();
  final TextEditingController _codeTEController = TextEditingController();
  final TextEditingController _quantityTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateProductFields(widget.product!);
    }
  }

  void _populateProductFields(Product product) {
    _productNameTEController.text = product.productName;
    _unitPriceTEController.text = product.unitPrice;
    _totalPriceTEController.text = product.totalPrice;
    _imageTEController.text = product.productImage;
    _codeTEController.text = product.productCode;
    _quantityTEController.text = product.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.product == null
            ? const Text('Add New Product')
            : const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildNewProductForm(),
        ),
      ),
    );
  }

  Widget _buildNewProductForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _productNameTEController,
            decoration: const InputDecoration(hintText: 'Name', labelText: 'Product Name'),
            validator: (value) => value == null || value.isEmpty ? 'Enter a valid product name' : null,
          ),
          TextFormField(
            controller: _unitPriceTEController,
            decoration: const InputDecoration(hintText: 'Unit Price', labelText: 'Unit Price'),
            validator: (value) => value == null || value.isEmpty ? 'Enter a valid unit price' : null,
          ),
          TextFormField(
            controller: _totalPriceTEController,
            decoration: const InputDecoration(hintText: 'Total Price', labelText: 'Total Price'),
            validator: (value) => value == null || value.isEmpty ? 'Enter a valid total price' : null,
          ),
          TextFormField(
            controller: _imageTEController,
            decoration: const InputDecoration(hintText: 'Image URL', labelText: 'Product Image'),
            validator: (value) => value == null || value.isEmpty ? 'Enter a valid image URL' : null,
          ),
          TextFormField(
            controller: _codeTEController,
            decoration: const InputDecoration(hintText: 'Product Code', labelText: 'Product Code'),
            validator: (value) => value == null || value.isEmpty ? 'Enter a valid product code' : null,
          ),
          TextFormField(
            controller: _quantityTEController,
            decoration: const InputDecoration(hintText: 'Quantity', labelText: 'Quantity'),
            validator: (value) => value == null || value.isEmpty ? 'Enter a valid quantity' : null,
          ),
          const SizedBox(height: 16),
          _inProgress
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: _onTapSaveProductButton,
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromWidth(double.maxFinite),
            ),
            child: widget.product == null
                ? const Text('Add Product')
                : const Text('Update Product'),
          ),
        ],
      ),
    );
  }

  void _onTapSaveProductButton() {
    if (_formKey.currentState!.validate()) {
      widget.product == null ? addNewProduct() : updateProduct();
    }
  }

  Future<void> addNewProduct() async {
    setState(() {
      _inProgress = true;
    });

    try {
      Uri uri = Uri.parse('http://164.68.107.70:6060/api/v1/CreateProduct');
      Map<String, dynamic> requestBody = {
        "Img": _imageTEController.text,
        "ProductCode": _codeTEController.text,
        "ProductName": _productNameTEController.text,
        "Qty": _quantityTEController.text,
        "TotalPrice": _totalPriceTEController.text,
        "UnitPrice": _unitPriceTEController.text
      };

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _clearTextFields();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New product added successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add the product')));
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _inProgress = false;
      });
    }
  }

  Future<void> updateProduct() async {
    setState(() {
      _inProgress = true;
    });

    try {
      Uri uri = Uri.parse(
          'http://164.68.107.70:6060/api/v1/UpdateProduct/${widget.product!.id}');
      Map<String, dynamic> requestBody = {
        "Img": _imageTEController.text,
        "ProductCode": _codeTEController.text,
        "ProductName": _productNameTEController.text,
        "Qty": _quantityTEController.text,
        "TotalPrice": _totalPriceTEController.text,
        "UnitPrice": _unitPriceTEController.text
      };

      final response = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update product')));
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _inProgress = false;
      });
    }
  }

  void _clearTextFields() {
    _productNameTEController.clear();
    _unitPriceTEController.clear();
    _totalPriceTEController.clear();
    _imageTEController.clear();
    _codeTEController.clear();
    _quantityTEController.clear();
  }

  @override
  void dispose() {
    _productNameTEController.dispose();
    _unitPriceTEController.dispose();
    _totalPriceTEController.dispose();
    _imageTEController.dispose();
    _codeTEController.dispose();
    _quantityTEController.dispose();
    super.dispose();
  }
}
