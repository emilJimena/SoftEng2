import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'ui/widgets/sidebar.dart';
import 'task_page.dart';
import 'manager_page.dart';
import 'sales_page.dart';
import 'menu_management_page.dart';
import 'inventory_page.dart';
import 'dash.dart';
import 'dashboard_page.dart';
import 'create_voucher.dart';
import 'assign_vouchers.dart';
import 'addon_page.dart';
import 'add_menu_addon_page.dart';
import 'config/api_config.dart';

class Expense {
  int? id;
  String date;
  String category;
  String description;
  String vendor;
  double quantity;
  double unitPrice;
  double totalCost;
  String paymentMethod;
  String notes;

  Expense({
    this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.vendor,
    required this.quantity,
    required this.unitPrice,
    required this.totalCost,
    required this.paymentMethod,
    required this.notes,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      date: json['date'],
      category: json['category'],
      description: json['description'],
      vendor: json['vendor'],
      quantity: json['quantity'] is num
          ? (json['quantity'] as num).toDouble()
          : double.tryParse(json['quantity'].toString()) ?? 0.0,
      unitPrice: json['unit_price'] is num
          ? (json['unit_price'] as num).toDouble()
          : double.tryParse(json['unit_price'].toString()) ?? 0.0,
      totalCost: json['total_cost'] is num
          ? (json['total_cost'] as num).toDouble()
          : double.tryParse(json['total_cost'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class ExpensesContent extends StatefulWidget {
  final String userId;
  final String username;
  final String role;
  final bool isSidebarOpen;
  final VoidCallback toggleSidebar;
  final VoidCallback onLogout;

  const ExpensesContent({
    super.key,
    required this.userId,
    required this.username,
    required this.role,
    required this.isSidebarOpen,
    required this.toggleSidebar,
    required this.onLogout,
  });

  @override
  State<ExpensesContent> createState() => _ExpensesContentState();
}

class _ExpensesContentState extends State<ExpensesContent> {
  late bool _isSidebarOpen;
  List<Expense> _allExpenses = [];
  bool isLoading = true;

  // Date filters
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _isSidebarOpen = widget.isSidebarOpen;
    _loadExpenses();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
    widget.toggleSidebar();
  }

  void _showAccessDeniedDialog(String page) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Access Denied"),
        content: Text(
          "You don’t have permission to access the $page page. This page is only available to Managers.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _loadExpenses() async {
    setState(() => isLoading = true);
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/expense/get_expenses.php'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        _allExpenses = data.map((e) => Expense.fromJson(e)).toList();
      } else {
        _allExpenses = [];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load expenses.')));
      }
    } catch (e) {
      _allExpenses = [];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching expenses: $e')));
    }
    setState(() => isLoading = false);
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.totalCost);
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (startDate ?? DateTime.now())
          : (endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  List<Expense> get _filteredExpenses {
    return _allExpenses.where((e) {
      final expenseDate = DateTime.tryParse(e.date);
      if (expenseDate == null) return false;
      if (startDate != null && expenseDate.isBefore(startDate!)) return false;
      if (endDate != null && expenseDate.isAfter(endDate!)) return false;
      return true;
    }).toList();
  }

  Widget _buildExpenseRow(Expense e) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(e.category, style: GoogleFonts.poppins(fontSize: 16)),
          ),
          Expanded(
            flex: 2,
            child: Text(e.date, style: GoogleFonts.poppins(fontSize: 16)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              e.description,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(e.vendor, style: GoogleFonts.poppins(fontSize: 16)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              e.paymentMethod,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              "₱${e.totalCost.toStringAsFixed(2)}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExpenses;
    final totalExpenses = _calculateTotal(filtered);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Could trigger add expense dialog
        child: const Icon(Icons.add),
      ),
      body: Row(
        children: [
          Material(
            elevation: 2,
            child: Sidebar(
              isSidebarOpen: _isSidebarOpen,
              toggleSidebar: _toggleSidebar,
              username: widget.username,
              role: widget.role,
              userId: widget.userId,
              onLogout: widget.onLogout,
              activePage: 'expenses',
              onHome: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => dash()),
                  (route) => false,
                );
              },
              onDashboard: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardPage(
                      username: widget.username,
                      role: widget.role,
                      userId: widget.userId,
                      isSidebarOpen: widget.isSidebarOpen,
                      toggleSidebar: widget.toggleSidebar,
                    ),
                  ),
                );
              },
              onTaskPage: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskPage(
                      userId: widget.userId,
                      username: widget.username,
                      role: widget.role,
                    ),
                  ),
                );
              },
              onMaterials: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManagerPage(
                      username: widget.username,
                      role: widget.role,
                      userId: widget.userId,
                      isSidebarOpen: widget.isSidebarOpen,
                      toggleSidebar: widget.toggleSidebar,
                    ),
                  ),
                );
              },
              onInventory: () {
                if (widget.role.toLowerCase() == "manager") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InventoryManagementPage(
                        userId: widget.userId,
                        username: widget.username,
                        role: widget.role,
                        isSidebarOpen: widget.isSidebarOpen,
                        toggleSidebar: widget.toggleSidebar,
                        onLogout: widget.onLogout,
                      ),
                    ),
                  );
                } else {
                  _showAccessDeniedDialog("Inventory");
                }
              },
              onMenu: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MenuManagementPage(
                      username: widget.username,
                      role: widget.role,
                      userId: widget.userId,
                      isSidebarOpen: widget.isSidebarOpen,
                      toggleSidebar: widget.toggleSidebar,
                    ),
                  ),
                );
              },
              onSales: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SalesContent(
                      userId: widget.userId,
                      username: widget.username,
                      role: widget.role,
                      isSidebarOpen: widget.isSidebarOpen,
                      toggleSidebar: widget.toggleSidebar,
                      onLogout: widget.onLogout,
                    ),
                  ),
                );
              },
              onAddons: () {
                if (widget.role.toLowerCase() == "manager") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddonPage(
                        userId: widget.userId,
                        username: widget.username,
                        role: widget.role,
                      ),
                    ),
                  );
                }
              },

              // Add Menu Addon Page (manager only)
              onAddMenuAddon: () {
                if (widget.role.toLowerCase() == "manager") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddMenuAddonPage()),
                  );
                }
              },

              // Voucher Pages (manager only)
              onCreateVoucher: () {
                if (widget.role.toLowerCase() == "manager") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoucherPage(
                        userId: widget.userId,
                        username: widget.username,
                        role: widget.role,
                        isSidebarOpen: widget.isSidebarOpen,
                        toggleSidebar: widget.toggleSidebar,
                      ),
                    ),
                  );
                }
              },
              onAssignVoucher: () {
                if (widget.role.toLowerCase() == "manager") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AssignVoucherPage()),
                  );
                }
              },
              onExpenses: () {},
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSidebarOpen ? Icons.arrow_back_ios : Icons.menu,
                          color: Colors.orange,
                        ),
                        onPressed: _toggleSidebar,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Expenses",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _pickDate(context, true),
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.orange,
                        ),
                        label: Text(
                          startDate != null
                              ? DateFormat('MMM dd, yyyy').format(startDate!)
                              : 'From',
                          style: GoogleFonts.poppins(color: Colors.orange),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _pickDate(context, false),
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.orange,
                        ),
                        label: Text(
                          endDate != null
                              ? DateFormat('MMM dd, yyyy').format(endDate!)
                              : 'To',
                          style: GoogleFonts.poppins(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Total Expenses: ₱${totalExpenses.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filtered.isEmpty
                        ? Center(
                            child: Text(
                              "No expenses found for the selected date range.",
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) =>
                                _buildExpenseRow(filtered[index]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
