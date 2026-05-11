import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../service_locator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  void _register() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await locator.authService.register(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to FreshBite!'),
            backgroundColor: Color(0xFF53D22D),
          ),
        );
        context.go('/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration failed')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF152012),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            return Row(
              children: [
                Expanded(child: _buildHeroImage()),
                Expanded(child: _buildRegisterForm(context)),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight * 0.35,
                    width: double.infinity,
                    child: _buildHeroImage(),
                  ),
                  _buildRegisterForm(context),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=1200&auto=format&fit=crop',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF152012),
            child: const Center(child: Icon(Icons.restaurant, color: Colors.white24, size: 100)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xFF152012),
                const Color(0xFF152012).withOpacity(0.6),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF53d22d),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_menu, color: Color(0xFF152012), size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FreshBite',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Start your culinary journey today.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create an account to save recipes and plan meals.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Join Us!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create an account to unlock all features.',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Username', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF53D22D))),
          ),
          TextField(
            key: const Key('register_username_field'),
            controller: _usernameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF53D22D), size: 20),
              hintText: 'Choose a username',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFF53D22D), width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
            ),
          ),
          const SizedBox(height: 20),
          
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Password', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF53D22D))),
          ),
          TextField(
            key: const Key('register_password_field'),
            controller: _passwordController,
            obscureText: _obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF53D22D), size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500]),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              hintText: 'Create a password',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFF53D22D), width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
            ),
          ),
          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF53D22D))),
          ),
          TextField(
            key: const Key('register_confirm_password_field'),
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_reset_outlined, color: Color(0xFF53D22D), size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmText ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500]),
                onPressed: () {
                  setState(() {
                    _obscureConfirmText = !_obscureConfirmText;
                  });
                },
              ),
              hintText: 'Repeat your password',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFF53D22D), width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
            ),
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('register_button'),
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF53D22D),
                foregroundColor: const Color(0xFF152012),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF53D22D).withOpacity(0.5),
              ),
              child: _isLoading 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF152012))
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
            ),
          ),
          
          const SizedBox(height: 32),
          Center(
            child: Wrap(
              children: [
                Text('Already have an account? ', style: TextStyle(color: Colors.grey[500])),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Color(0xFF53d22d),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
