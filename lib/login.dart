import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

// Firebase instances
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLogin = true; // Toggle between Login and Signup
  String? _errorMessage;
  bool _isLoading = false;
  
  // Focus nodes for better focus management
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  // Animation controller for logo fade-in
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _logoController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // Sign Up Function
  Future<String?> signupUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': DateTime.now(),
        'uid': userCredential.user!.uid,
      });

      return null; // Success
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          return 'This email is already in use.';
        } else if (e.code == 'weak-password') {
          return 'The password is too weak.';
        } else if (e.code == 'invalid-email') {
          return 'Invalid email address.';
        }
      }
      return 'Signup failed. Please try again.';
    }
  }

  // Login Function
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return 'User not found in database.';
      }

      return null; // Login successful
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          return 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          return 'Incorrect password.';
        }
      }
      return 'Login failed. Please try again.';
    }
  }

  // Password Recovery
  Future<String?> recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Email sent successfully
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          return 'No user found with this email.';
        } else if (e.code == 'invalid-email') {
          return 'Invalid email format.';
        }
      }
      return 'Error sending password reset email.';
    }
  }

  // Submit form for login/signup
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    
    String? message;
    if (_isLogin) {
      message = await loginUser(_emailController.text.trim(), _passwordController.text);
    } else {
      message = await signupUser(_emailController.text.trim(), _passwordController.text);
    }

    setState(() {
      _isLoading = false;
    });
    
    if (message == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Full-screen gradient background for a world-class look
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.indigo.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Hero logo
                      Hero(
                        tag: 'logo',
                        child: FadeTransition(
                          opacity: _logoAnimation,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image.asset(
                                'assets/logo.png',
                                height: 100,
                              ),
                            ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome to BHAV-AI',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Email Field
                      TextFormField(
                        key: const ValueKey("email"),
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.email, color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white38),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      TextFormField(
                        key: const ValueKey("password"),
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white38),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          key: const ValueKey("login_signup_button"),
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Log In' : 'Sign Up',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Toggle between Login and Signup
                      TextButton(
                        key: const ValueKey("toggle_button"),
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = null;
                            _formKey.currentState?.reset();
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: Text(
                          _isLogin ? 'Create an Account' : 'Already have an account? Log in',
                        ),
                      ),
                      // Forgot Password Option
                      TextButton(
                        key: const ValueKey("forgot_password_button"),
                        onPressed: () async {
                          if (_emailController.text.isEmpty) {
                            setState(() {
                              _errorMessage = 'Please enter your email to recover password.';
                            });
                            return;
                          }
                          String? message = await recoverPassword(_emailController.text.trim());
                          if (message == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password reset email sent! Check your inbox.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setState(() {
                              _errorMessage = message;
                            });
                          }
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.white70),
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}