import 'package:flutter/material.dart';
import 'package:logistics/screens/admin/admin_login_page.dart';
import 'package:logistics/screens/admin/other_admin_login_page.dart';
import 'package:logistics/screens/home/client_login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
            colors: [Color(0xFFF2F6FF), Color(0xFFEFF4F9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Select your access level to continue',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ) ??
                            const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                      ),
                      const SizedBox(height: 20),

                      _buildAccessCard(
                        title: 'ADMIN LOGIN',
                        description:
                            'Full system access and administrative privileges',
                        icon: Icons.verified_user_outlined,
                        iconColor: const Color(0xFF4C6FFF),
                        iconBg: const Color(0xFFE9EDFF),
                        badgeText: 'Full Access',
                        badgeBg: const Color(0xFFE9EDFF),
                        badgeFg: const Color(0xFF4C6FFF),
                        onTap: () => _handleRoleSelection('Admin'),
                      ),

                      _buildAccessCard(
                        title: 'CLIENT/DRIVER LOGIN',
                        description:
                            'Access for clients and drivers to manage assignments',
                        icon: Icons.groups_outlined,
                        iconColor: const Color(0xFF16A34A),
                        iconBg: const Color(0xFFE9FCEB),
                        badgeText: 'User Access',
                        badgeBg: const Color(0xFFE9FCEB),
                        badgeFg: const Color(0xFF16A34A),
                        onTap: () => _handleRoleSelection('Client/Driver'),
                      ),

                      _buildAccessCard(
                        title: 'OTHER ADMIN LOGIN',
                        description:
                            'Department heads and supervisors with limited permissions',
                        icon: Icons.apartment_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        iconBg: const Color(0xFFFFF4E5),
                        badgeText: 'Limited Access',
                        badgeBg: const Color(0xFFFFF4E5),
                        badgeFg: const Color(0xFFD97706),
                        onTap: () => _handleRoleSelection('Other Admin'),
                      ),

                      const SizedBox(height: 12),
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

  void _handleRoleSelection(String role) {
    switch (role) {
      case 'Admin':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminLoginPage()),
        );
        break;
      case 'Client/Driver':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        break;
      case 'Other Admin':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OtherAdminLoginPage()),
        );
        break;
    }
  }

  Widget _buildAccessCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String badgeText,
    required Color badgeBg,
    required Color badgeFg,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final iconBox = w < 360 ? 40.0 : 48.0;
        final titleSize = w < 360 ? 16.0 : 18.0;
        final descSize = w < 360 ? 12.0 : 14.0;
        final padding = w < 360 ? 12.0 : 16.0;
  final isNarrow = w < 360;

        return Semantics(
          button: true,
          label: title,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            constraints: BoxConstraints(minHeight: isNarrow ? 112 : 88),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000), // subtle shadow without withOpacity
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: iconBox,
                                height: iconBox,
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon,
                                    color: iconColor, size: iconBox * 0.5),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF111827),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Color(0xFF9CA3AF)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Allow full wrap on small screens to show all details
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: descSize,
                              color: const Color(0xFF6B7280),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: badgeFg,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: iconBox,
                            height: iconBox,
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon,
                                color: iconColor, size: iconBox * 0.5),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF111827),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: descSize,
                                    color: const Color(0xFF6B7280),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 60),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.end,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    badgeText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: badgeFg,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: Color(0xFF9CA3AF)),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
