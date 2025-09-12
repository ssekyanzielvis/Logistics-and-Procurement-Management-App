import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    // Initialize timezone database
    tz.initializeTimeZones();

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
  final size = MediaQuery.of(context).size;
  final isCompactHeight = size.height < 700;

  return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Text(
              '${getGreeting(userName: null)}',
              style: TextStyle(
                fontSize: isCompactHeight ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF343A40),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your role to continue',
            style: TextStyle(
              fontSize: isCompactHeight ? 14 : 16,
              color: const Color(0xFF6C757D),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isCompactHeight ? 16 : 24),
          _buildRoleGrid(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRoleGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Responsive columns to keep all choices visible and compact
        int crossAxisCount;
        if (width >= 900) {
          crossAxisCount = 3; // desktop/tablets
        } else if (width >= 600) {
          crossAxisCount = 3; // large phones/small tablets
        } else if (width >= 360) {
          crossAxisCount = 2; // most phones
        } else {
          crossAxisCount = 1; // very narrow screens
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5, // shorter tiles to fit above the fold
          children: [
            _buildRoleTile(
              index: 0,
              title: 'Admin',
              icon: Icons.admin_panel_settings,
              description: 'Manage the entire system',
              color: const Color(0xFF007BFF),
            ),
            _buildRoleTile(
              index: 1,
              title: 'Client/Driver',
              icon: Icons.person,
              description: 'Client and driver features',
              color: const Color(0xFF28A745),
            ),
            _buildRoleTile(
              index: 2,
              title: 'Other Admin',
              icon: Icons.settings_accessibility,
              description: 'Limited admin access',
              color: const Color(0xFF6F42C1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleTile({
    required int index,
    required String title,
    required IconData icon,
    required String description,
    required Color color,
  }) {
    final isHovered = hoveredIndex == index;
    return Semantics(
      button: true,
      label: '$title role',
      child: MouseRegion(
        onEnter: (_) => setState(() => hoveredIndex = index),
        onExit: (_) => setState(() => hoveredIndex = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.identity()..scale(isHovered ? 1.03 : 1.0),
          child: Material(
            elevation: isHovered ? 6 : 2,
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _handleRoleSelection(title),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(icon, size: 28, color: color),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF343A40),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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

  // Removed old _buildRoleCard in favor of compact grid tiles

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

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.of(context).pop();

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

  String getGreeting({String? userName}) {
    try {
      final location = tz.getLocation('Africa/Nairobi');
      final now = tz.TZDateTime.now(location);
      final hour = now.hour;
      String greeting;
      if (hour < 12) {
        greeting = 'Good Morning';
      } else if (hour < 17) {
        greeting = 'Good Afternoon';
      } else if (hour < 20) {
        greeting = 'Good Evening';
      } else {
        greeting = 'Good Night';
      }
      return userName != null ? '$greeting, $userName' : greeting;
    } catch (e) {
      // Fallback to local time if timezone fails
      final hour = DateTime.now().hour;
      String greeting;
      if (hour < 12) {
        greeting = 'Good Morning';
      } else if (hour < 17) {
        greeting = 'Good Afternoon';
      } else if (hour < 20) {
        greeting = 'Good Evening';
      } else {
        greeting = 'Good Night';
      }
      return userName != null ? '$greeting, $userName' : greeting;
    }
  }
}
