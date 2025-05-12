import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_check/main.dart';

class TenantSelectionScreen extends StatefulWidget {
  @override
  State<TenantSelectionScreen> createState() => _TenantSelectionScreenState();
}

class _TenantSelectionScreenState extends State<TenantSelectionScreen> {
  final TextEditingController _tenantNameController = TextEditingController();
  bool _loading = false;

  Future<void> _createTenantAndAssign() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final tenantName = _tenantNameController.text.trim();
    if (tenantName.isEmpty) return;

    setState(() => _loading = true);

    try {
      // Create tenant
      final tenantRef = await FirebaseFirestore.instance
          .collection('tenants')
          .add({'name': tenantName, 'createdAt': FieldValue.serverTimestamp()});

      // Add user document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'phone': user.phoneNumber,
        'tenantId': tenantRef.id,
        'role': 'member',
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => NotesPage()), // your home screen
        (route) => false,
      );


    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create or Join Tenant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tenantNameController,
              decoration: InputDecoration(labelText: 'Create workspace name'),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _createTenantAndAssign,
                  child: Text('Continue'),
                ),
          ],
        ),
      ),
    );
  }
}
