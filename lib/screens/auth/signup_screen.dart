import 'package:flutter/material.dart';
import '../../constants/app_colours.dart';
import '../../constants/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String selectedRole = 'Customer';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: AppTextStyles.header,
              ),
              SizedBox(height: 8),
              Text(
                'Join MukBites community',
                style: AppTextStyles.body,
              ),
              SizedBox(height: 32),
              
              // Role Selection
              Text(
                'I am a:',
                style: AppTextStyles.subHeader,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard('Customer', Icons.person),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildRoleCard('Vendor', Icons.store),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildRoleCard('Delivery', Icons.delivery_dining),
                  ),
                ],
              ),
              SizedBox(height: 32),
              
              // Form Fields
              _buildTextField('Full Name', _nameController, Icons.person_outline),
              SizedBox(height: 16),
              _buildTextField('Email', _emailController, Icons.email_outlined),
              SizedBox(height: 16),
              _buildTextField('Phone', _phoneController, Icons.phone_outlined),
              SizedBox(height: 16),
              _buildPasswordField(),
              SizedBox(height: 32),
              
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.body,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.textDark,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              role,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Email' && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.primary,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

 Future<void> _handleSignUp() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    // 1. create the Firebase Auth user
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    final uid = userCredential.user!.uid;

    // 2. write the extra profile fields to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name'      : _nameController.text.trim(),
      'email'     : _emailController.text.trim(),
      'phone'     : _phoneController.text.trim(),
      'role'      : selectedRole,
      'createdAt' : FieldValue.serverTimestamp(),
    });

    // 3. send user to the correct home screen
    _goHome(selectedRole);

  } on FirebaseAuthException catch (e) {
    final msg = switch (e.code) {
      'email-already-in-use' => 'That e-mail is already registered.',
      'weak-password'        => 'Choose a stronger password.',
      _                      => 'Sign-up failed: ${e.message}',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

void _goHome(String role) {
  switch (role) {
    case 'Customer': Navigator.pushReplacementNamed(context, '/customer-home'); break;
    case 'Vendor'  : Navigator.pushReplacementNamed(context, '/vendor-home');   break;
    case 'Delivery': Navigator.pushReplacementNamed(context, '/delivery-home'); break;
  }
}


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}