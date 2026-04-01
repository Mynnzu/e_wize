import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'styled_page_scaffold.dart';
import 'booking_detail_page.dart';
import 'welcome_page.dart';

class LoginPage extends StatefulWidget {
  final void Function(String username) onLoginSuccess;
  final bool redirected;

  const LoginPage({
    required this.onLoginSuccess,
    this.redirected = false,
    Key? key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    if (widget.redirected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please log in to continue with your booking."),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Check 4 admin login first
        final adminResult =
            await FirebaseFirestore.instance
                .collection('administrator')
                .where('username', isEqualTo: username)
                .where('password', isEqualTo: password)
                .get();

        if (adminResult.docs.isNotEmpty) {
          Navigator.pushNamed(context, '/admin');
          return;
        }

        // If not admin, user
        final userResult =
            await FirebaseFirestore.instance
                .collection('Users')
                .where('username', isEqualTo: username)
                .where('password', isEqualTo: password)
                .get();

        if (userResult.docs.isNotEmpty) {
          widget.onLoginSuccess(username);

          if (pendingBooking != null) {
            final hall = pendingBooking!['hall'];
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        BookingDetailsPage(username: username, hallData: hall),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => WelcomePage(username: username, onLogout: () {}),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid username or password')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StyledPageScaffold(
      title: 'Login',
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/LogoSpazio.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Welcome to EventWize!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => username = val.trim(),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Enter username'
                                  : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onChanged: (val) => password = val.trim(),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Enter password'
                                  : null,
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text('Register Account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
