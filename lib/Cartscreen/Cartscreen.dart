import 'package:dastarkhana/models/Card.model.dart';
import 'package:dastarkhana/widgets/CartWidget/EmptyCart.dart';
import 'package:dastarkhana/widgets/CartWidget/LocationBarWidget.dart';
import 'package:dastarkhana/widgets/CartWidget/ProductItemWidget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/CartWidget/OrderSummaryWidget.dart';

class Cardscreen extends StatefulWidget {
  const Cardscreen({super.key, required this.userId});
  final int userId;

  @override
  State<Cardscreen> createState() => _CardscreenState();
}

class _CardscreenState extends State<Cardscreen> {
  bool _isCreatingOrder = false; // Initially set to false
  String userLocation = '';
  String userAddress = 'Мекенжай анықталуда...';
  bool isFetchingAddress = false;

  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      isFetchingAddress = true;
    });
    try {
      final position = await getCurrentLocationApp();
      if (position != null) {
        final coords = "${position.latitude}, ${position.longitude}";
        setState(() {
          userLocation = coords;
        });
        await getAddressFromCoordinates(coords);
      } else {
        setState(() {
          userAddress = 'Мекенжайды анықтау мүмкін болмады';
        });
      }
    } catch (e) {
      print("Error initializing location: $e");
      setState(() {
        userAddress = 'Мекенжайды анықтау кезінде қате';
      });
    } finally {
      setState(() {
        isFetchingAddress = false;
      });
    }
  }

  Future<Position?> getCurrentLocationApp() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Мекенжайға рұқсат берілмеді.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Мекенжайға рұқсат біржола берілмеді.");
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> getAddressFromCoordinates(String coordinates) async {
    final latLng = coordinates.split(',');
    if (latLng.length != 2) {
      setState(() => userAddress = 'Мекенжай форматы дұрыс емес');
      return;
    }

    final lat = latLng[0].trim();
    final lng = latLng[1].trim();
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String address = data['display_name'] ?? 'Unknown location';

        int commaCount = 0;
        int index = 0;
        for (int i = 0; i < address.length; i++) {
          if (address[i] == ',') commaCount++;
          if (commaCount == 2) {
            index = i;
            break;
          }
        }
        if (commaCount >= 2) {
          address = address.substring(0, index);
        }
        setState(() => userAddress = address);
      } else {
        setState(() => userAddress = 'Мекенжай табылмады');
      }
    } catch (error) {
      print("Геокодтау кезінде қате пайда болды:: $error");
      setState(() => userAddress = 'Мекенжай қолжетімсіз');
    }
  }

  double calculateSubtotal(CartProvider cart) {
    double subtotal = 0;
    for (var product in cart.products) {
      final double price = double.tryParse(
          product.product['price']?.toString() ?? '0') ?? 0;
      final quantity = product.quantity ?? 1;
      subtotal += price * quantity;
    }
    return subtotal;
  }

  Future<void> makeOrder() async {
    setState(() {
      _isCreatingOrder = true; // Start loading
    });

    try {
      String currentLocation = userLocation;
      if (currentLocation.isEmpty) {
        final position = await getCurrentLocationApp();
        if (position != null) {
          currentLocation = "${position.latitude}, ${position.longitude}";
          setState(() {
            userLocation = currentLocation;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Мекенжайды анықтау мүмкін болмады. Қайталап көріңіз.",
                style: TextStyle(fontSize: 16, fontFamily: "SF-Pro-Text-Bold", fontWeight: FontWeight.w700),
              ),
              backgroundColor: errorColor,
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            _isCreatingOrder = false;
          });
          return;
        }
      }

      final cart = Provider.of<CartProvider>(context, listen: false);
      double subtotal = calculateSubtotal(cart);
      double deliveryFee = 1000;
      double totalPrice = subtotal + deliveryFee;

      List<Map<String, dynamic>> orderItems = cart.products.map((product) {
        return {
          "quantity": product.quantity,
          "productId": product.product['id'],
        };
      }).toList();

      Map<String, dynamic> orderData = {
        "totalPrice": totalPrice,
        "location": currentLocation,
        "status": "PENDING",
        "customerId": widget.userId,
        "orderItems": orderItems,
      };

      final response = await http.post(
        Uri.parse(ApiConstants.createOrder),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );
print(response.body);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Рахмет! Тапсырысыңыз өңделуде!",
              style: TextStyle(fontSize: 16, fontFamily: "SF-Pro-Text-Bold", fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.indigo,
            duration: Duration(seconds: 3),
          ),
        );
        await Future.delayed(Duration(seconds: 2));
        cart.clearCart();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Тапсырысты құру сәтсіз аяқталды. Қайталап көріңіз.",
              style: TextStyle(fontSize: 16, fontFamily: "SF-Pro-Text-Bold", fontWeight: FontWeight.w700),
            ),
            backgroundColor: errorColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Қате орын алды. Қайталап көріңіз.",
            style: TextStyle(fontSize: 16, fontFamily: "SF-Pro-Text-Bold", fontWeight: FontWeight.w700),
          ),
          backgroundColor: errorColor,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isCreatingOrder = false; // Stop loading once the process is done
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Себет',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'SF-Pro-Text-Bold',
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.products.isEmpty) {
            return EmptyCart();
          }

          final subtotal = calculateSubtotal(cart);
          final deliveryFee = 1000.0;
          final total = subtotal + deliveryFee;

          return CustomScrollView(
            slivers: [
              // Location Bar
              SliverToBoxAdapter(
                child: LocationBarWidget(
                  userAddress: userAddress,
                  isFetchingAddress: isFetchingAddress,
                ),
              ),

              // Product List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final product = cart.products[index];
                    return ProductItemWidget(product: product, cart: cart, successColor: successColor);
                  },
                  childCount: cart.products.length,
                ),
              ),

              // Summary
              SliverFillRemaining(
                hasScrollBody: false,
                child:OrderSummary(
                  subtotal: subtotal,
                  deliveryFee: deliveryFee,
                  total: total,
                  isCreatingOrder: _isCreatingOrder,
                  makeOrder: makeOrder,
                  successColor: successColor,
                ),

              ),
            ],
          );
        },
      ),
    );
  }
}
