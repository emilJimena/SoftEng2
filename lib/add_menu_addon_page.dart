import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../config/api_config.dart';

class AddMenuAddonPage extends StatefulWidget {
  @override
  _AddMenuAddonPageState createState() => _AddMenuAddonPageState();
}

class _AddMenuAddonPageState extends State<AddMenuAddonPage> {
  List<dynamic> menus = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final res = await http.get(Uri.parse("$baseUrl/menu/get_menu_items.php"));
      if (res.statusCode == 200) {
        final jsonRes = json.decode(res.body);
        setState(() => menus = jsonRes['data'] ?? []);
      } else {
        print("❌ Failed to fetch menus: ${res.body}");
      }
    } catch (e) {
      print("⚠️ Error fetching menus: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Items', style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                return MenuExpansionTile(menu: menu);
              },
            ),
    );
  }
}

class MenuExpansionTile extends StatefulWidget {
  final dynamic menu;
  MenuExpansionTile({required this.menu});

  @override
  _MenuExpansionTileState createState() => _MenuExpansionTileState();
}

class _MenuExpansionTileState extends State<MenuExpansionTile> {
  bool _isLoading = false;
  List<dynamic> menuAddons = [];
  List<dynamic> allAddons = [];
  List<dynamic> materials = [];

  int? selectedAddonId;
  int? selectedMaterialId;
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMenuAddons();
    fetchAllAddons();
    fetchMaterials();
  }

  Future<void> fetchMenuAddons() async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final res = await http.get(
        Uri.parse(
          "$baseUrl/menu/get_menu_addons.php?menu_id=${widget.menu['id']}",
        ),
      );
      if (res.statusCode == 200) {
        final jsonRes = json.decode(res.body);
        if (jsonRes is Map && jsonRes['success'] == true) {
          setState(() => menuAddons = jsonRes['data'] ?? []);
        } else if (jsonRes is List) {
          setState(() => menuAddons = jsonRes);
        } else {
          setState(() => menuAddons = []);
        }
      }
    } catch (e) {
      print("⚠️ Error fetching menu addons: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchAllAddons() async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final res = await http.get(
        Uri.parse("$baseUrl/addons/get_all_addons.php"),
      );
      if (res.statusCode == 200) {
        final jsonRes = json.decode(res.body);
        if (jsonRes['success'] == true) {
          setState(() => allAddons = jsonRes['data'] ?? []);
        }
      }
    } catch (e) {
      print("⚠️ Error fetching all addons: $e");
    }
  }

  Future<void> fetchMaterials() async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final res = await http.get(
        Uri.parse("$baseUrl/menu/get_raw_materials.php"),
      );
      if (res.statusCode == 200) {
        final jsonRes = json.decode(res.body);
        setState(() => materials = jsonRes['data'] ?? []);
      }
    } catch (e) {
      print("⚠️ Error fetching materials: $e");
    }
  }

  Future<void> submitAddon() async {
    if (selectedAddonId == null ||
        selectedMaterialId == null ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse("$baseUrl/addons/add_menu_addon.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "menu_id": widget.menu['id'],
          "addon_id": selectedAddonId,
          "material_id": selectedMaterialId,
          "quantity": double.tryParse(_quantityController.text) ?? 0.0,
        }),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Addon successfully added!')));
        _quantityController.clear();
        setState(() {
          selectedAddonId = null;
          selectedMaterialId = null;
        });
        fetchMenuAddons(); // refresh addons after adding
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Failed to add addon'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> removeMenuAddon(int addonId) async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse("$baseUrl/addons/remove_menu_addon.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"menu_id": widget.menu['id'], "addon_id": addonId}),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Addon removed successfully!')));
        fetchMenuAddons(); // refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Failed to remove addon'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.menu['name'], style: GoogleFonts.poppins()),
      subtitle: Text('Price: ${widget.menu['price']}'),
      childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: _isLoading
          ? [Center(child: CircularProgressIndicator())]
          : [
              Text(
                'Current Addons',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              ...menuAddons.isEmpty
                  ? [Text('No addons assigned.')]
                  : menuAddons
                        .map(
                          (addon) => ListTile(
                            title: Text(addon['name']),
                            subtitle: Text(
                              'Category: ${addon['category']} | Quantity: ${addon['quantity']}',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('Remove Addon'),
                                    content: Text(
                                      'Are you sure you want to remove this addon?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  removeMenuAddon(
                                    int.tryParse(addon['id'].toString())!,
                                  );
                                }
                              },
                            ),
                          ),
                        )
                        .toList(),

              Divider(),
              Text(
                'Add New Addon',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              _buildDropdown(
                title: 'Select Addon',
                value: selectedAddonId,
                items: allAddons,
                labelExtractor: (a) => a['name'],
                onChanged: (val) => setState(() => selectedAddonId = val),
              ),
              _buildDropdown(
                title: 'Select Raw Material',
                value: selectedMaterialId,
                items: materials,
                labelExtractor: (m) => m['name'],
                onChanged: (val) => setState(() => selectedMaterialId = val),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: submitAddon,
                icon: Icon(Icons.add),
                label: Text('Add Addon'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
    );
  }

  Widget _buildDropdown({
    required String title,
    required int? value,
    required List<dynamic> items,
    required String Function(dynamic) labelExtractor,
    required Function(int?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<int>(
            value: value,
            items: items.isEmpty
                ? [
                    DropdownMenuItem(
                      value: null,
                      child: Text('No items available'),
                    ),
                  ]
                : items.map((item) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(item['id'].toString()),
                      child: Text(labelExtractor(item)),
                    );
                  }).toList(),
            onChanged: items.isEmpty ? null : onChanged,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
