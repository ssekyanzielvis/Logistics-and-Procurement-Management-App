import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistics/providers/auth_provider.dart';
import 'package:logistics/screens/admin/other_admin_dashboard.dart';
import 'package:logistics/services/auth_service.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.read(authServiceProvider));
});

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginNotifier(this._authService) : super(LoginState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      // Sign in with Supabase
      final role = await _authService.signIn(email, password);

      // Allow only other_admin (and admin as a privileged superset) into this dashboard
      final normalized = (role ?? 'user').toLowerCase();
      final allowed = normalized == 'other_admin' || normalized == 'admin';

      if (allowed) {
        state = state.copyWith(isLoading: false, isSuccess: true, errorMessage: null);
      } else {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: "You don't have Other Admin access (role: ${role ?? 'unknown'}).",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isSuccess: false, errorMessage: e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(
        isLoading: false,
        resetSent: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void checkCapsLock(String value) {
    bool hasCaps =
        value.isNotEmpty &&
        value == value.toUpperCase() &&
        value != value.toLowerCase();
    if (hasCaps != state.capsLockOn) {
      state = state.copyWith(capsLockOn: hasCaps);
    }
  }
}

@immutable
class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final bool isDarkMode;
  final bool rememberMe;
  final bool isPasswordVisible;
  final bool capsLockOn;
  final bool resetSent;
  final String? errorMessage;

  const LoginState({
    required this.isLoading,
    required this.isSuccess,
    required this.isDarkMode,
    required this.rememberMe,
    required this.isPasswordVisible,
    required this.capsLockOn,
    required this.resetSent,
    this.errorMessage,
  });

  factory LoginState.initial() => const LoginState(
    isLoading: false,
    isSuccess: false,
    isDarkMode: false,
    rememberMe: false,
    isPasswordVisible: false,
    capsLockOn: false,
    resetSent: false,
  );

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isDarkMode,
    bool? rememberMe,
    bool? isPasswordVisible,
    bool? capsLockOn,
    bool? resetSent,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      rememberMe: rememberMe ?? this.rememberMe,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      capsLockOn: capsLockOn ?? this.capsLockOn,
      resetSent: resetSent ?? this.resetSent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OtherAdminLoginPage extends ConsumerStatefulWidget {
  const OtherAdminLoginPage({super.key});

  @override
  ConsumerState<OtherAdminLoginPage> createState() =>
      _OtherAdminLoginPageState();
}

class _OtherAdminLoginPageState extends ConsumerState<OtherAdminLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(loginProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    final state = ref.read(loginProvider);
    if (state.isSuccess && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OtherAdminDashboard()),
      );
    } else if (mounted && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Password'),
            content: const Text(
              'Password reset link will be sent to your email.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(loginProvider.notifier)
                      .resetPassword(_emailController.text.trim());
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Send Link'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final theme = state.isDarkMode ? ThemeData.dark() : ThemeData.light();
    final colorScheme = theme.colorScheme;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor:
            state.isDarkMode
                ? const Color(0xFF121212)
                : const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: state.isDarkMode ? 8 : 12,
                      shadowColor:
                          state.isDarkMode
                              ? Colors.black54
                              : Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(state),
                            const SizedBox(height: 32),
                            _buildLoginForm(state),
                            const SizedBox(height: 24),
                            _buildLoginButton(state),
                            const SizedBox(height: 16),
                            _buildForgotPassword(state),
                            const SizedBox(height: 24),
                            _buildDivider(state),
                            const SizedBox(height: 24),
                            _buildSocialLogin(state),
                            const SizedBox(height: 16),
                            _buildSecurityBadge(state),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          mini: true,
          onPressed: () => ref.read(loginProvider.notifier).toggleDarkMode(),
          backgroundColor: colorScheme.secondary,
          child: Icon(
            state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LoginState state) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  state.isDarkMode
                      ? [Colors.blue[400]!, Colors.purple[400]!]
                      : [Colors.blue[600]!, Colors.purple[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Admin Portal',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: state.isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back! Please sign in to continue.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: state.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(LoginState state) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(state),
          const SizedBox(height: 16),
          _buildPasswordField(state),
          if (state.capsLockOn) _buildCapsLockWarning(state),
          const SizedBox(height: 16),
          _buildRememberMe(state),
        ],
      ),
    );
  }

  Widget _buildEmailField(LoginState state) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'admin@company.com',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor:
            state.isDarkMode
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(LoginState state) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !state.isPasswordVisible,
      textInputAction: TextInputAction.done,
      onChanged:
          (value) => ref.read(loginProvider.notifier).checkCapsLock(value),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            state.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed:
              () => ref.read(loginProvider.notifier).togglePasswordVisibility(),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor:
            state.isDarkMode
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildCapsLockWarning(LoginState state) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[700], size: 16),
          const SizedBox(width: 8),
          Text(
            'Caps Lock is on',
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMe(LoginState state) {
    return Row(
      children: [
        Checkbox(
          value: state.rememberMe,
          onChanged: (_) => ref.read(loginProvider.notifier).toggleRememberMe(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Text('Remember me', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildLoginButton(LoginState state) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: state.isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              state.isDarkMode ? Colors.blue[600] : Colors.blue[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            state.isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Widget _buildForgotPassword(LoginState state) {
    return TextButton(
      onPressed: _handleForgotPassword,
      child: Text(
        'Forgot your password?',
        style: TextStyle(
          color: state.isDarkMode ? Colors.blue[300] : Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider(LoginState state) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[400])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildSocialLogin(LoginState state) {
    return Column(
      children: [
        _buildSocialButton(
          'Continue with Google',
          Icons.g_mobiledata,
          Colors.red[600]!,
          state,
          () => _handleSocialLogin('Google'),
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          'Continue with Microsoft',
          Icons.business,
          Colors.blue[600]!,
          state,
          () => _handleSocialLogin('Microsoft'),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String text,
    IconData icon,
    Color color,
    LoginState state,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
        label: Text(
          text,
          style: TextStyle(
            color: state.isDarkMode ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: state.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(LoginState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            state.isDarkMode
                ? Colors.green[800]!.withOpacity(0.2)
                : Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.isDarkMode ? Colors.green[600]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.security,
            size: 16,
            color: state.isDarkMode ? Colors.green[400] : Colors.green[700],
          ),
          const SizedBox(width: 6),
          Text(
            'SSL Secured',
            style: TextStyle(
              fontSize: 12,
              color: state.isDarkMode ? Colors.green[400] : Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    // Simulate social login
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final state = ref.read(loginProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider login initiated'),
            backgroundColor: state.isDarkMode ? Colors.blue[700] : Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
}
