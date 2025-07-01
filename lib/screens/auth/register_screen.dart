import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/user_controller.dart';
import '../../utils/user_session.dart';
import '../../theme/halus.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// Enum to track which field is currently the target
enum ActiveField { name, email, password, confirm, none }

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  // Firebase & Controllers
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userController = Get.put(UserController());
  final userSession = Get.put(UserSession());

  // Text Editing Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Focus Nodes to control text field focus
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // Keys to get the position of each text field
  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _emailKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();
  final GlobalKey _confirmPasswordKey = GlobalKey();

  // State for UI logic
  bool _isLoading = false;
  String? _error;
  
  // FIX: Re-introducing ActiveField to track the bubble's target step-by-step
  ActiveField _activeField = ActiveField.name;
  double _bubbleYPosition = 0;

  // State to enable/disable text fields
  bool _isEmailEnabled = false;
  bool _isPasswordEnabled = false;
  bool _isConfirmPasswordEnabled = false;

  // Animation variables
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    // Add listeners to controllers to advance the state
    _nameController.addListener(_onNameChanged);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);

    // Add listeners to FocusNodes to update bubble position on focus change
    _nameFocus.addListener(_handleFocusChange);
    _emailFocus.addListener(_handleFocusChange);
    _passwordFocus.addListener(_handleFocusChange);
    _confirmPasswordFocus.addListener(_handleFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateBubblePosition(_nameKey);
        FocusScope.of(context).requestFocus(_nameFocus);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Remove all focus listeners
    _nameFocus.removeListener(_handleFocusChange);
    _emailFocus.removeListener(_handleFocusChange);
    _passwordFocus.removeListener(_handleFocusChange);
    _confirmPasswordFocus.removeListener(_handleFocusChange);
    
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    
    _animationController?.dispose();
    super.dispose();
  }

  // --- LOGIC FOR GIMMICK ---

  void _handleFocusChange() {
    // This function is called whenever focus changes.
    // It ensures the bubble is correctly positioned next to the active field.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_nameFocus.hasFocus && _activeField == ActiveField.name) {
        _updateBubblePosition(_nameKey);
      } else if (_emailFocus.hasFocus && _activeField == ActiveField.email) {
        _updateBubblePosition(_emailKey);
      } else if (_passwordFocus.hasFocus && _activeField == ActiveField.password) {
        _updateBubblePosition(_passwordKey);
      } else if (_confirmPasswordFocus.hasFocus && _activeField == ActiveField.confirm) {
        _updateBubblePosition(_confirmPasswordKey);
      }
    });
  }

  void _onNameChanged() {
    if (_nameController.text.isNotEmpty && !_isEmailEnabled) {
      setState(() {
        _isEmailEnabled = true;
        _activeField = ActiveField.email;
      });
      _emailFocus.requestFocus();
    }
  }

  void _onEmailChanged() {
    if (_emailController.text.isNotEmpty && !_isPasswordEnabled) {
      setState(() {
        _isPasswordEnabled = true;
        _activeField = ActiveField.password;
      });
      _passwordFocus.requestFocus();
    }
  }

  void _onPasswordChanged() {
    if (_passwordController.text.isNotEmpty && !_isConfirmPasswordEnabled) {
      setState(() {
        _isConfirmPasswordEnabled = true;
        _activeField = ActiveField.confirm;
      });
      _confirmPasswordFocus.requestFocus();
    }
  }
  
  void _onConfirmPasswordChanged() {
    if (_confirmPasswordController.text.isNotEmpty && _activeField != ActiveField.none) {
      setState(() {
        // All fields are filled, hide the bubble for good.
        _activeField = ActiveField.none;
      });
    }
  }

  void _updateBubblePosition(GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
      setState(() {
        _bubbleYPosition = position.dy - 40; 
      });
    }
  }

  void _showBlockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Isi dulu field sebelumnya baru boleh lanjut!'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // --- REGISTRATION LOGIC ---
  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = 'Semua field harus diisi');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _error = 'Password dan Password Konfirmasi tidak cocok');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await userController.saveInitialUserData(userId, email, name);
        await userController.fetchUserData(userId);
        userSession.setUserId(userId);
        userSession.setUserName(name);
        Get.offAllNamed('/home', arguments: {'userId': userId});
      } else {
        setState(() => _error = 'Pendaftaran gagal: user ID tidak ditemukan');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Terjadi kesalahan');
    } catch (e) {
      setState(() => _error = 'Error: Kesalahan Sistem');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTouchMeBubble() {
    if (_animation == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation!.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Isi di sini',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required GlobalKey key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    bool isEnabled = true,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isEnabled) {
          _showBlockedMessage();
        }
      },
      child: AbsorbPointer(
        absorbing: !isEnabled,
        child: TextField(
          key: key,
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            labelStyle: TextStyle(color: isEnabled ? null : Colors.grey[400]),
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: isEnabled,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Daftar Akun',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 48),
                      _buildTextField(
                        key: _nameKey,
                        controller: _nameController,
                        focusNode: _nameFocus,
                        label: 'Nama Lengkap',
                      ),
                      SizedBox(height: 1.5, child: CustomPaint(painter: SmoothLinePainter())),
                      const SizedBox(height: 20),
                      _buildTextField(
                        key: _emailKey,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        label: 'Email',
                        isEnabled: _isEmailEnabled,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 1.5, child: CustomPaint(painter: SmoothLinePainter())),
                      const SizedBox(height: 20),
                      _buildTextField(
                        key: _passwordKey,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        label: 'Password',
                        isEnabled: _isPasswordEnabled,
                        obscureText: true,
                      ),
                      SizedBox(height: 1.5, child: CustomPaint(painter: SmoothLinePainter())),
                      const SizedBox(height: 20),
                      _buildTextField(
                        key: _confirmPasswordKey,
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        label: 'Konfirmasi Password',
                        isEnabled: _isConfirmPasswordEnabled,
                        obscureText: true,
                      ),
                      SizedBox(height: 1.5, child: CustomPaint(painter: SmoothLinePainter())),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Daftar Akun'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Sudah punya akun? Masuk di sini'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // FIX: Visibility is now controlled by the ActiveField enum
            Visibility(
              visible: _activeField != ActiveField.none,
              child: Positioned(
                top: _bubbleYPosition,
                right: 24,
                child: _buildTouchMeBubble(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
