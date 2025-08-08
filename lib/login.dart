import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

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
  
  bool _isLogin = true;
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
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

  Future<String?> signupUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': DateTime.now(),
        'uid': userCredential.user!.uid,
      });

      return null;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            return 'This email is already in use.';
          case 'weak-password':
            return 'The password is too weak.';
          case 'invalid-email':
            return 'Invalid email address.';
          default:
            return 'Signup failed. Please try again.';
        }
      }
      return 'Signup failed. Please try again.';
    }
  }

  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return 'User not found in database.';
      }

      return null;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            return 'No user found with this email.';
          case 'wrong-password':
            return 'Incorrect password.';
          case 'invalid-email':
            return 'Invalid email format.';
          case 'too-many-requests':
            return 'Too many attempts. Please try again later.';
          default:
            return 'Login failed. Please try again.';
        }
      }
      return 'Login failed. Please try again.';
    }
  }

  Future<String?> recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            return 'No user found with this email.';
          case 'invalid-email':
            return 'Invalid email format.';
          default:
            return 'Error sending password reset email.';
        }
      }
      return 'Error sending password reset email.';
    }
  }

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
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Theme.of(context).colorScheme.surface,
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
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Image.asset(
                                'assets/logo.png',
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to BHAV-AI',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your AI Health Assistant',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Email Field
                      TextFormField(
                        key: const ValueKey("email"),
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
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
                        obscureText: _obscurePassword,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submitForm(),
                      ),
                      const SizedBox(height: 30),
                      
                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // Login/Signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          key: const ValueKey("login_signup_button"),
                          onPressed: _isLoading ? null : _submitForm,
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Log In' : 'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimary,
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
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: Text(
                          _isLogin 
                            ? 'Don\'t have an account? Sign up' 
                            : 'Already have an account? Log in',
                        ),
                      ),
                      
                      // Forgot Password Option
                      if (_isLogin)
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
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Password reset email sent! Check your inbox.'),
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } else {
                              setState(() {
                                _errorMessage = message;
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
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
