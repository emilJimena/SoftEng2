import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sales_data.dart';

class OrdersPopup {
  static Future<void> show(BuildContext context) async {
    bool isLoading = true;

    // 1️⃣ Load logged-in user
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUser = prefs.getString("username") ?? "Unknown";

    // 2️⃣ Load orders from SalesData
    await SalesData().init();
    await SalesData().loadOrders();

    // 3️⃣ Prepare orders with proper formatting
    List<Map<String, dynamic>> allOrders = SalesData().orders.map((order) {
      final items = (order['items'] as List<dynamic>?)
              ?.map((item) => {
                    'menuItem': item['menu_item'] ?? '',
                    'category': item['category'] ?? '',
                    'quantity': item['quantity']?.toString() ?? '1',
                    'size': item['size'] ?? '',
                    'price': item['price']?.toString() ?? '0.00',
                    'addons': (item['addons'] as List<dynamic>?) ?? [],
                  })
              .toList() ??
          [];

      return {
        'orderName': order['order_name'] ?? 'Order',
        'orderDate': order['order_date'] ?? '--',
        'orderTime': order['order_time'] ?? '--',
        'purchaseMethod': order['payment_method'] ?? order['paymentMethod'] ?? 'Cash',
        'voucher': order['voucher'] ?? '',
        'amountPaid': double.tryParse(
                (order['amount_paid'] ?? order['amountPaid'] ?? '0').toString()) ??
            0.0,
        'change': double.tryParse(
                (order['change_amount'] ?? order['change'] ?? '0').toString()) ??
            0.0,
        'handledBy': order['handled_by'] ?? order['cashier'] ?? currentUser,
        'items': items,
      };
    }).toList();

    isLoading = false;

    // 4️⃣ Function to calculate total for an order
    double calculateOrderTotal(Map<String, dynamic> order) {
      double total = 0;
      for (var item in order['items'] as List<dynamic>) {
        total += double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      }
      return total;
    }

    // 5️⃣ Filter only today's orders
    final String todayStr = DateFormat('MMM dd, yyyy').format(DateTime.now());
    final List<Map<String, dynamic>> todaysOrders =
        allOrders.where((order) => order['orderDate'] == todayStr).toList();

    // 6️⃣ Show the popup dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            minWidth: 300,
            maxWidth: 500,
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Title and date
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Orders History",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            todayStr,
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    // Orders list
                    Expanded(
                      child: todaysOrders.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "No orders for today.",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          : Scrollbar(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: todaysOrders.length,
                                itemBuilder: (context, index) {
                                  final order = todaysOrders[index];
                                  final items =
                                      order['items'] as List<dynamic>? ?? [];
                                  final orderTotal =
                                      calculateOrderTotal(order);

                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${order['orderName']} - ₱${orderTotal.toStringAsFixed(2)}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Processed by: ${order['handledBy']}",
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Time: ${order['orderTime']} | Payment: ${order['purchaseMethod']} | Paid: ₱${order['amountPaid'].toStringAsFixed(2)} | Change: ₱${order['change'].toStringAsFixed(2)}",
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                          if ((order['voucher'] ?? '')
                                              .toString()
                                              .isNotEmpty)
                                            Text(
                                              "Voucher: ${order['voucher']}",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.green[700]),
                                            ),
                                          const SizedBox(height: 4),
                                          ...items.map((item) {
                                            final addons =
                                                (item['addons']
                                                        as List<dynamic>?)
                                                    ?.join(", ") ??
                                                    '';
                                            return Text(
                                              "• ${item['menuItem']} (${item['category']}) - Qty: ${item['quantity']}, Size: ${item['size']}, ₱${item['price']} ${addons.isNotEmpty ? '($addons)' : ''}",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}