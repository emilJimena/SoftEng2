import 'package:flutter/material.dart';
import '../material_details_page.dart';
import '../ui/widgets/sidebar.dart';
import '../task_page.dart';
import '../manager_page.dart';
import '../menu_management_page.dart';
import '../sales_page.dart';
import '../expenses_page.dart';
import '../dashboard_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../create_voucher.dart';
import '../assign_vouchers.dart';
import '../addon_page.dart';
import '../add_menu_addon_page.dart';
import '../dash.dart';

class InventoryUI extends StatelessWidget {
  final List<dynamic> materials;
  final bool isLoading;
  final int currentPage;
  final int rowsPerPage;
  final int? sortColumnIndex;
  final bool sortAscending;
  final int totalItems;
  final int lowStockCount;

  final bool isSidebarOpen;
  final String username;
  final String role;
  final String userId;
  final String apiBase;
  final VoidCallback toggleSidebar;
  final VoidCallback? onAdminDashboard;
  final VoidCallback? onManagerPage;
  final VoidCallback? onMenu;
  final VoidCallback? onSales;
  final VoidCallback? onExpenses;
  final VoidCallback onLogout;

  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  final List<dynamic> lowStockMaterials;

  final int? lowStockSortColumnIndex;
  final bool lowStockSortAscending;
  final void Function(
    int columnIndex,
    bool ascending,
    Comparable Function(Map) getField,
  )
  onLowStockSort;
  final void Function(
    int columnIndex,
    bool ascending,
    Comparable Function(Map) getField,
  )
  onSort;
  final VoidCallback onGenerateReport;
  final VoidCallback onShowAddStockDialog;
  final void Function(Map mat) onEditRestock;

  final TextEditingController searchController; // 🔹 add
  final void Function(String) onSearch; // 🔹 add

  const InventoryUI({
    required this.materials,
    required this.isLoading,
    required this.currentPage,
    required this.rowsPerPage,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.totalItems,
    required this.lowStockCount,
    required this.isSidebarOpen,
    required this.username,
    required this.role,
    required this.userId,
    required this.apiBase,
    required this.toggleSidebar,
    this.onAdminDashboard,
    this.onManagerPage,
    this.onMenu,
    this.onSales,
    this.onExpenses,
    required this.onLogout,
    required this.onSort,
    required this.onGenerateReport,
    required this.onShowAddStockDialog,
    required this.onEditRestock,
    required this.lowStockSortColumnIndex,
    required this.lowStockSortAscending,
    required this.onLowStockSort,
    required this.lowStockMaterials,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onSearch,
    required this.searchController, // 🔹 add controller
    Key? key,
  }) : super(key: key);

  void _showAccessDeniedDialog(BuildContext context, String pageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Access Denied"),
        content: Text(
          "You don’t have permission to access $pageName. This page is only available to Managers.",
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

  @override
  Widget build(BuildContext context) {
    final totalPages = (materials.length / rowsPerPage).ceil();
    final paginatedMaterials = materials.sublist(
      currentPage * rowsPerPage,
      (currentPage * rowsPerPage + rowsPerPage) > materials.length
          ? materials.length
          : currentPage * rowsPerPage + rowsPerPage,
    );
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.grey[50]),
          Row(
            children: [
              Sidebar(
                isSidebarOpen: isSidebarOpen,
                toggleSidebar: toggleSidebar,
                onHome: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => dash()),
                  );
                },
                onDashboard: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardPage(
                        userId: userId,
                        username: username,
                        role: role,
                        isSidebarOpen: isSidebarOpen,
                        toggleSidebar: toggleSidebar,
                      ),
                    ),
                    (route) => false,
                  );
                },

                onTaskPage: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskPage(
                        userId: userId,
                        username: username,
                        role: role,
                      ),
                    ),
                  );
                },
                onAdminDashboard: onAdminDashboard,
                onMaterials: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManagerPage(
                        username: username,
                        role: role,
                        userId: userId,
                        isSidebarOpen: isSidebarOpen,
                        toggleSidebar: toggleSidebar,
                      ),
                    ),
                  );
                },
                onInventory: () {},
                onMenu: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MenuManagementPage(
                        username: username,
                        role: role,
                        userId: userId,
                        isSidebarOpen: isSidebarOpen,
                        toggleSidebar: toggleSidebar,
                      ),
                    ),
                  );
                },
                onSales: () {
                  if (role.toLowerCase() == "manager") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SalesContent(
                          userId: userId,
                          username: username,
                          role: role,
                          isSidebarOpen: isSidebarOpen,
                          toggleSidebar: toggleSidebar,
                          onLogout: onLogout,
                        ),
                      ),
                    );
                  } else {
                    _showAccessDeniedDialog(context, "Sales");
                  }
                },

                onExpenses: () {
                  if (role.toLowerCase() == "manager") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpensesContent(
                          userId: userId,
                          username: username,
                          role: role,
                          isSidebarOpen: isSidebarOpen,
                          toggleSidebar: toggleSidebar,
                          onLogout: onLogout,
                        ),
                      ),
                    );
                  } else {
                    _showAccessDeniedDialog(context, "Expenses");
                  }
                },
                onAddons: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddonPage(
                        userId: userId,
                        username: username,
                        role: role,
                      ),
                    ),
                  );
                },

                // Add Menu Addon Page (manager only)
                onAddMenuAddon: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddMenuAddonPage()),
                  );
                },

                // Voucher Pages (manager only)
                onCreateVoucher: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoucherPage(
                        userId: userId,
                        username: username,
                        role: role,
                        isSidebarOpen: isSidebarOpen,
                        toggleSidebar: toggleSidebar,
                      ),
                    ),
                  );
                },
                onAssignVoucher: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AssignVoucherPage()),
                  );
                },
                username: username,
                role: role,
                userId: userId,
                onLogout: onLogout,
                activePage: 'inventory',
              ),
              Expanded(
                child: Column(
                  children: [
                    // Top bar - Inventory Management with Low Stock Notification
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white, // Card-style background
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Sidebar toggle
                            IconButton(
                              icon: Icon(
                                isSidebarOpen
                                    ? Icons.arrow_back_ios
                                    : Icons.menu,
                                color: Colors.orange,
                              ),
                              onPressed: toggleSidebar,
                            ),

                            const SizedBox(width: 10),

                            // Title
                            Text(
                              "Inventory Management",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const Spacer(),

                            // Low Stock Notification Icon with custom image
                            IconButton(
                              icon: Stack(
                                children: [
                                  Image.asset(
                                    'assets/images/notification.png', // Your custom notification image
                                    width: 30,
                                    height: 30,
                                  ),
                                  if (lowStockCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '$lowStockCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onPressed: () {
                                // Show low stock details dialog
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    if (lowStockMaterials.isEmpty) {
                                      return AlertDialog(
                                        title: const Text(
                                          "Low Stock Ingredients",
                                        ),
                                        content: const Text(
                                          "✅ All ingredients are sufficiently stocked!",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text("Close"),
                                          ),
                                        ],
                                      );
                                    }

                                    return AlertDialog(
                                      title: Text(
                                        "⚠️ Low Stock Ingredients ($lowStockCount)",
                                      ),
                                      content: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          sortColumnIndex:
                                              lowStockSortColumnIndex,
                                          sortAscending: lowStockSortAscending,
                                          columns: const [
                                            DataColumn(
                                              label: Text(
                                                "ID",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              numeric: true,
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Name",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Quantity",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              numeric: true,
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Restock Level",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              numeric: true,
                                            ),
                                          ],
                                          rows: lowStockMaterials.map((mat) {
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(mat['id'].toString()),
                                                ),
                                                DataCell(Text(mat['name'])),
                                                DataCell(
                                                  Text(
                                                    (double.tryParse(
                                                              mat['quantity']
                                                                  .toString(),
                                                            ) ??
                                                            0)
                                                        .toStringAsFixed(2),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    (double.tryParse(
                                                              mat['restock_level']
                                                                  .toString(),
                                                            ) ??
                                                            0)
                                                        .toStringAsFixed(2),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Close"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Table + Status + Search + Buttons
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status + Search + Buttons Row
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  child: Row(
                                    children: [
                                      _StatusBox(
                                        text: "Total Items: $totalItems",
                                        color: Colors.orangeAccent,
                                        bgOpacity: 0.2,
                                      ),
                                      _StatusBox(
                                        text: "Low Stock: $lowStockCount",
                                        color: Colors.redAccent,
                                        bgOpacity: 0.2,
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 200,
                                        child: TextField(
                                          controller: searchController,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Search...',
                                            hintStyle: const TextStyle(
                                              color: Colors.black45,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 12,
                                                ),
                                            filled: true,
                                            fillColor: Colors.grey[200],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide.none,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.search,
                                              color: Colors.black45,
                                            ),
                                          ),

                                          onChanged: (value) =>
                                              onSearch(value.trim()),
                                          onSubmitted: (value) =>
                                              onSearch(value.trim()),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        height:
                                            44, // match the TextField height
                                        child: ElevatedButton.icon(
                                          onPressed: onShowAddStockDialog,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ), // only horizontal padding
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    8,
                                                  ), // smooth edges, not pill
                                            ),
                                          ),
                                          icon: Image.asset(
                                            'assets/icons/add.png',
                                            width: 19,
                                            height: 19,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "Add Stock",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // === TABLE CONTAINER ===
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 20,
                                    ),
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth:
                                                    constraints.maxWidth - 48,
                                              ),
                                              child: DataTable(
                                                sortColumnIndex:
                                                    sortColumnIndex,
                                                sortAscending: sortAscending,
                                                headingRowColor:
                                                    MaterialStateProperty.all(
                                                      Colors.orange.shade100,
                                                    ),
                                                headingTextStyle:
                                                    const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                dataTextStyle: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 15,
                                                ),
                                                dividerThickness: 1,
                                                horizontalMargin: 24,
                                                columnSpacing: 80,
                                                border: TableBorder(
                                                  horizontalInside: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                                columns: const [
                                                  DataColumn(
                                                    label: Text("ID"),
                                                    numeric: true,
                                                  ),
                                                  DataColumn(
                                                    label: Text("Name"),
                                                  ),
                                                  DataColumn(
                                                    label: Text("Quantity"),
                                                    numeric: true,
                                                  ),
                                                  DataColumn(
                                                    label: Text("Unit"),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      "Restock Level",
                                                    ),
                                                    numeric: true,
                                                  ),
                                                  DataColumn(
                                                    label: Text("Actions"),
                                                  ),
                                                ],
                                                rows: paginatedMaterials.map<DataRow>((
                                                  mat,
                                                ) {
                                                  final isLowStock =
                                                      (double.tryParse(
                                                            mat['quantity']
                                                                .toString(),
                                                          ) ??
                                                          0) <=
                                                      (double.tryParse(
                                                            mat['restock_level']
                                                                .toString(),
                                                          ) ??
                                                          0);

                                                  return DataRow(
                                                    color:
                                                        MaterialStateProperty.resolveWith<
                                                          Color?
                                                        >(
                                                          (states) =>
                                                              paginatedMaterials
                                                                  .indexOf(mat)
                                                                  .isEven
                                                              ? Colors.grey[50]
                                                              : Colors.white,
                                                        ),
                                                    cells: [
                                                      DataCell(
                                                        Text(
                                                          mat['id'].toString(),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          isLowStock
                                                              ? "${mat['name']} (Low)"
                                                              : mat['name'],
                                                          style: TextStyle(
                                                            color: isLowStock
                                                                ? Colors
                                                                      .redAccent
                                                                : Colors
                                                                      .black87,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          (double.tryParse(
                                                                    mat['quantity']
                                                                        .toString(),
                                                                  ) ??
                                                                  0)
                                                              .toStringAsFixed(
                                                                2,
                                                              ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(mat['unit'] ?? ''),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          mat['restock_level'] ??
                                                              '',
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (_) => MaterialDetailsPage(
                                                                      materialId:
                                                                          mat['id']
                                                                              .toString(),
                                                                      materialName:
                                                                          mat['name'],
                                                                      apiBase:
                                                                          apiBase,
                                                                      userId:
                                                                          userId,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors
                                                                    .orangeAccent
                                                                    .withOpacity(
                                                                      0.75,
                                                                    ),
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          14,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        20,
                                                                      ),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                "Show Entries",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () =>
                                                                  onEditRestock(
                                                                    mat,
                                                                  ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors
                                                                    .blueAccent
                                                                    .withOpacity(
                                                                      0.75,
                                                                    ),
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          14,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        20,
                                                                      ),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                "Edit Restock",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // === Pagination + Generate Report ===
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 24,
                                    top: 8,
                                    bottom: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Generate Report button first
                                      ElevatedButton.icon(
                                        onPressed: onGenerateReport,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            26,
                                            190,
                                            67,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        icon: Image.asset(
                                          'assets/icons/print.png',
                                          width: 19,
                                          height: 19,
                                          color: Colors.black,
                                        ),
                                        label: const Text(
                                          "Generate Report",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      // Back button
                                      Container(
                                        decoration: BoxDecoration(
                                          color: currentPage > 0
                                              ? Colors.orangeAccent
                                              : Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: currentPage > 0
                                              ? onPreviousPage
                                              : null,
                                          icon: const Icon(
                                            Icons.arrow_back_ios,
                                          ),
                                          color: currentPage > 0
                                              ? Colors.white
                                              : Colors.black26,
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          "${currentPage + 1} / $totalPages",
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      // Next button
                                      Container(
                                        decoration: BoxDecoration(
                                          color: currentPage < totalPages - 1
                                              ? Colors.orangeAccent
                                              : Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed:
                                              currentPage < totalPages - 1
                                              ? onNextPage
                                              : null,
                                          icon: const Icon(
                                            Icons.arrow_forward_ios,
                                          ),
                                          color: currentPage < totalPages - 1
                                              ? Colors.white
                                              : Colors.black26,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String text;
  final Color color;
  final double bgOpacity;

  const _StatusBox({
    required this.text,
    required this.color,
    required this.bgOpacity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(bgOpacity),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
