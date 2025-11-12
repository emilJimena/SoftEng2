import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart'; // ✅ use ApiConfig

class AssignVoucherPage extends StatefulWidget {
  @override
  _AssignVoucherPageState createState() => _AssignVoucherPageState();
}

class _AssignVoucherPageState extends State<AssignVoucherPage> {
  int? selectedVoucherId;
  final _quantityController = TextEditingController();

  List<Map<String, dynamic>> vouchers = [];
  List<Map<String, dynamic>> users = [];
  List<int> selectedUserIds = []; // ✅ multiple users

  @override
  void initState() {
    super.initState();
    fetchVouchers();
    fetchUsers();
  }

  Future<void> fetchVouchers() async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/vouchers/get_vouchers.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          vouchers = data.map((e) {
            final map = e as Map<String, dynamic>;
            return {
              'id': int.parse(map['id'].toString()),
              'name': map['name'],
              'quantity': map['quantity'],
              'expiration_date': map['expiration_date'],
            };
          }).toList();
        });
      } else {
        print("Failed to fetch vouchers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching vouchers: $e");
    }
  }

  Future<void> fetchUsers() async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/vouchers/user_voucher_list.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          users = data.map((e) {
            final map = e as Map<String, dynamic>;
            return {
              'id': int.parse(map['id'].toString()),
              'username': map['username'],
            };
          }).toList();
        });
      } else {
        print("Failed to fetch users: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> assignVoucher() async {
    if (selectedVoucherId == null ||
        selectedUserIds.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a voucher, users, and quantity')),
      );
      return;
    }

    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/vouchers/assign.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'voucher_id': selectedVoucherId,
          'user_ids': selectedUserIds,
          'quantity': int.parse(_quantityController.text),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voucher assigned successfully')),
        );
        _quantityController.clear();
        setState(() {
          selectedVoucherId = null;
          selectedUserIds = [];
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to assign voucher')));
      }
    } catch (e) {
      print("Error assigning voucher: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error assigning voucher')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Voucher to Users')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: selectedVoucherId,
                decoration: InputDecoration(labelText: 'Select Voucher'),
                items: vouchers
                    .map(
                      (v) => DropdownMenuItem<int>(
                        value: v['id'],
                        child: Text(v['name']),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedVoucherId = val),
              ),
              SizedBox(height: 16),
              Text(
                'Select Users',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...users.map((u) {
                final userId = u['id'] as int;
                final username = u['username'] as String;
                return CheckboxListTile(
                  title: Text(username),
                  value: selectedUserIds.contains(userId),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        selectedUserIds.add(userId);
                      } else {
                        selectedUserIds.remove(userId);
                      }
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: assignVoucher,
                child: Text('Assign Voucher'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
