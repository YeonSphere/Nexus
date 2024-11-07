import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

class PasswordManagerScreen extends ConsumerStatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  ConsumerState<PasswordManagerScreen> createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends ConsumerState<PasswordManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _domainController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
        backgroundColor: AppTheme.primaryPurple,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildCredentialsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCredentialDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search passwords...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onChanged: (value) {
          // Implement search functionality
        },
      ),
    );
  }

  Widget _buildCredentialsList() {
    // TODO: Replace with actual credentials from state management
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) {
        return const ListTile(
          leading: Icon(Icons.lock),
          title: Text('Example.com'),
          subtitle: Text('username@example.com'),
        );
      },
    );
  }

  void _showAddCredentialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Password'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _domainController,
                decoration: const InputDecoration(labelText: 'Website'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveCredential,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveCredential() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement save functionality
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _domainController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
