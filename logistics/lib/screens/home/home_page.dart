import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int? hoveredIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildMainContent(),
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apps, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'LOGISTICS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF343A40),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'HOME',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF007BFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose Your Role',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF343A40),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Select your role to access the appropriate dashboard',
            style: TextStyle(fontSize: 16, color: Color(0xFF6C757D)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 768) {
                return _buildDesktopLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          ),
          const SizedBox(
            height: 24,
          ), // Add padding to ensure content is not cut off
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildRoleCard(
            0,
            'Admin',
            Icons.admin_panel_settings,
            'Full system administration access',
            const Color(0xFF007BFF),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildRoleCard(
            1,
            'Client/Driver',
            Icons.person,
            'Access client or driver features',
            const Color(0xFF28A745),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildRoleCard(
            2,
            'Other Admin',
            Icons.settings_accessibility,
            'Limited admin access',
            const Color(0xFF6F42C1),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildRoleCard(
          0,
          'Admin',
          Icons.admin_panel_settings,
          'Full system administration access',
          const Color(0xFF007BFF),
        ),
        const SizedBox(height: 16),
        _buildRoleCard(
          1,
          'Client/Driver',
          Icons.person,
          'Access client or driver features',
          const Color(0xFF28A745),
        ),
        const SizedBox(height: 16),
        _buildRoleCard(
          2,
          'Other Admin',
          Icons.settings_accessibility,
          'Limited admin access',
          const Color(0xFF6F42C1),
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    int index,
    String title,
    IconData icon,
    String description,
    Color color,
  ) {
    final isHovered = hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        child: Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: Material(
            elevation: isHovered ? 8 : 4,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleRoleSelection(title),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  border: Border.all(
                    color: isHovered ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(icon, size: 32, color: color),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF343A40),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6C757D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isHovered ? color : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isHovered ? Colors.white : color,
                        ),
                      ),
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Help'),
                      content: const Text(
                        'Select your role to access the appropriate login page. '
                        'Admins will get full access, while clients/drivers will '
                        'have limited access based on their permissions.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
              );
            },
            icon: const Icon(
              Icons.help_outline,
              size: 16,
              color: Color(0xFF6C757D),
            ),
            label: const Text(
              'Need help?',
              style: TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRoleSelection(String role) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007BFF)),
                ),
                const SizedBox(height: 16),
                Text('Preparing $role login...'),
              ],
            ),
          ),
    );

    // Simulate loading and navigate to appropriate page
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.of(context).pop(); // Close loading dialog

      switch (role) {
        case 'Admin':
          Navigator.pushNamed(context, '/admin-login');
          break;
        case 'Client/Driver':
          Navigator.pushNamed(context, '/login');
          break;
        case 'Other Admin':
          Navigator.pushNamed(context, '/other-admin-login');
          break;
        default:
          Navigator.pushNamed(context, '/');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redirecting to $role login'),
            backgroundColor: const Color(0xFF28A745),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
