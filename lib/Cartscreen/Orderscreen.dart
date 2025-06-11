import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/Order.model.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class Orderscreen extends StatefulWidget {
  final int userId;
  const Orderscreen({super.key, required this.userId});

  @override
  State<Orderscreen> createState() => _OrderscreenState();
}

class _OrderscreenState extends State<Orderscreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  bool _hasError = false;
  Map<int, bool> _expandedItems = {};
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getOrderById + widget.userId.toString()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = jsonDecode(response.body);

        // If the response is an empty array, set `_orders` to an empty list
        _orders = ordersJson.isNotEmpty
            ? ordersJson.map((orderJson) => Order.fromJson(orderJson)).toList()
            : [];

        setState(() {
          _isLoading = false;
        });
      } else {
        print("Жауаптың форматы дұрыс емес: ${response.statusCode}");
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Тапсырыстарды жүктеу кезінде қате пайда болды: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // Функция для обновления данных при pull-to-refresh
  void _onRefresh() async {
    await _fetchOrders();
    _refreshController.refreshCompleted();
  }

  Color getOrderStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NOT_VALIDATED':
        return errorColor;
      case 'VALIDATED':
        return Colors.blueAccent;
      case 'DELIVERED':
        return successColor;
      case 'CANCELLED':
        return errorColor;
      default:
        return disabledColor;
    }
  }

  String getOrderStatusTranslation(String status) {
    switch (status.toUpperCase()) {
      case 'NOT_VALIDATED':
        return 'Расталмаған';
      case 'VALIDATED':
        return 'Расталған';
      case 'DELIVERED':
        return 'Жеткізілді';
      case 'CANCELLED':
        return 'Бас тартылған';
      case 'PENDING':
        return 'Күтуде';
      case 'ON_ROAD':
        return 'Жолда';
      case 'RETURNED':
        return 'Қайтарылды';
      default:
        return 'Қаралуда';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Менің тапсырыстарым",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'SF-Pro-Text-Bold',
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: successColor,
              ),
            );
          } else if (_hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: errorColor,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Тапсырыстар жүктелмеді',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'SF-Pro-Text-Medium',
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: _fetchOrders,
                    child: Text(
                      'Қайтадан жүктеу',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'SF-Pro-Text-Bold',
                        color: successColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (_orders.isEmpty) {
            return SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                waterDropColor: successColor,
                complete: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.done, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(
                      'Жаңартылды',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 16,
                        fontFamily: 'SF-Pro-Text-Regular',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/Frame.png",
                            height: 200,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Тапсырыстар жоқ",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'SF-Pro-Text-Bold',
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Тапсырыстарды көру үшін тапсырыс бере бастаңыз",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'SF-Pro-Text-Regular',
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                waterDropColor: successColor,
                complete: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.done, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(
                      'Жаңартылды',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 16,
                        fontFamily: 'SF-Pro-Text-Regular',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final status = order.status ?? 'Unknown';
                  final statusColor = getOrderStatusColor(status);
                  final totalPrice = order.totalPrice.toString();
                  final orderItems = order.orderItems;
                  bool isDetailsExpanded = _expandedItems[index] ?? false;

                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Тапсырыс #${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro-Text-Bold',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                //status *******************
                                getOrderStatusTranslation(status),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SF-Pro-Text-Semibold',
                                  color: getOrderStatusColor(status),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _expandedItems[index] = !isDetailsExpanded;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Тапсырыс деректері',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'SF-Pro-Text-Regular',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  isDetailsExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                              ],
                            ),
                          ),
                          if (isDetailsExpanded) ...[
                            SizedBox(height: 16),
                            // ... Previous code remains the same until the order items mapping ...

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: orderItems.map((item) {
                                return Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      // Product Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          item.product.mainImage,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
                                          height: 100, // Match image height for consistency
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      item.product.name,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'SF-Pro-Text-Regular',
                                                        fontWeight: FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Quantity Circle - Always aligned to the right
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(219, 234, 254, 1),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  "x${item.quantity.toString()}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'SF-Pro-Text-Regular',
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                          ],
                          Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Жалпы сома",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro-Text-Medium',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "$totalPrice тг",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro-Text-Bold',
                                  color: successColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
