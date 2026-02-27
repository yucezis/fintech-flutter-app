import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  int _passwordStrength = 0;

  static const _red      = Color(0xFFE63946);
  static const _cream    = Color(0xFFF1FAEE);
  static const _frost    = Color(0xFFA8DADC);
  static const _cerulean = Color(0xFF457B9D);
  static const _ink      = Color(0xFF0A131F);

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    int strength = 0;
    if (value.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength++;
    if (RegExp(r'[0-9]').hasMatch(value)) strength++;
    if (RegExp(r'[!@#\$&*~%^()_+\-=\[\]{}|;:",.<>?/]').hasMatch(value)) strength++;
    setState(() => _passwordStrength = strength);
  }

  Color _strengthColor(int index) {
    if (_passwordStrength == 0) return _ink.withOpacity(0.08);
    if (index >= _passwordStrength) return _ink.withOpacity(0.08);
    if (_passwordStrength == 1) return _red;
    if (_passwordStrength == 2) return const Color(0xFFFF9F1C);
    if (_passwordStrength == 3) return _cerulean;
    return const Color(0xFF2EC071);
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 0: return '';
      case 1: return 'Zayıf';
      case 2: return 'Orta';
      case 3: return 'İyi';
      case 4: return 'Güçlü';
      default: return '';
    }
  }

  Color get _strengthLabelColor {
    switch (_passwordStrength) {
      case 1: return _red;
      case 2: return const Color(0xFFFF9F1C);
      case 3: return _cerulean;
      case 4: return const Color(0xFF2EC071);
      default: return Colors.transparent;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen kullanım koşullarını kabul edin.'),
          backgroundColor: _cerulean,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final service = ref.read(authServiceProvider);
    final fullName =
        '${_nameController.text.trim()} ${_surnameController.text.trim()}';
    final isSuccess = await service.register(
      fullName,
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (isSuccess) {
      if (mounted) context.go('/dashboard');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kayıt başarısız. Lütfen tekrar deneyin.'),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: _ink.withOpacity(0.45),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(prefixIcon, color: _cerulean.withOpacity(0.7), size: 18),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _cerulean.withOpacity(0.15), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _cerulean, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      children: [
        Container(
          height: 220,
          color: _cerulean,
        ),

        Positioned(
          top: -50, right: -50,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          top: 30, right: 60,
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _red.withOpacity(0.2),
            ),
          ),
        ),
        Positioned(
          bottom: 30, left: -30,
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _ink.withOpacity(0.07),
            ),
          ),
        ),

        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Zen',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Budget',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _frost,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    _stepDot(done: true),
                    _stepLine(),
                    _stepDot(active: true),
                    _stepLine(faded: true),
                    _stepDot(faded: true),
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  'Hesap Oluştur',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Finansal özgürlüğe giden yolculuğuna başla.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dalga geçiş
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 48, color: _cream),
          ),
        ),
      ],
    );
  }

  Widget _stepDot({bool done = false, bool active = false, bool faded = false}) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? _red
            : active
                ? Colors.white
                : Colors.white.withOpacity(0.25),
        border: active
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
      child: done
          ? const Icon(Icons.check, size: 6, color: Colors.white)
          : null,
    );
  }

  Widget _stepLine({bool faded = false}) {
    return Expanded(
      child: Container(
        height: 2,
        color: faded
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.5),
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _ink.withOpacity(0.08), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _ink.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: _ink.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 220, child: _buildHero()),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('AD'),
                              TextFormField(
                                controller: _nameController,
                                decoration: _inputDecoration(
                                  label: 'Ayşe',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(fontSize: 14, color: _ink),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Gerekli'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('SOYAD'),
                              TextFormField(
                                controller: _surnameController,
                                decoration: _inputDecoration(
                                  label: 'Kaya',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(fontSize: 14, color: _ink),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Gerekli'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _fieldLabel('E-POSTA ADRESİ'),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        label: 'ayse@email.com',
                        prefixIcon: Icons.mail_outline_rounded,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 14, color: _ink),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Gerekli';
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,}$')
                            .hasMatch(v.trim())) return 'Geçersiz e-posta';
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _fieldLabel('TELEFON NUMARASI'),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration(
                        label: '+90 555 000 00 00',
                        prefixIcon: Icons.phone_outlined,
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 14, color: _ink),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Gerekli' : null,
                    ),

                    const SizedBox(height: 14),

                    _fieldLabel('ŞİFRE'),
                    TextFormField(
                      controller: _passwordController,
                      onChanged: _onPasswordChanged,
                      decoration: _inputDecoration(
                        label: 'En az 8 karakter',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: _ink.withOpacity(0.35),
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(fontSize: 14, color: _ink),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Gerekli';
                        if (v.length < 8) return 'En az 8 karakter';
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(4, (i) => Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 3,
                            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: _strengthColor(i),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        )),
                        if (_passwordStrength > 0) ...[
                          const SizedBox(width: 10),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _strengthLabel,
                              key: ValueKey(_strengthLabel),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _strengthLabelColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () =>
                          setState(() => _acceptedTerms = !_acceptedTerms),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: _acceptedTerms
                                  ? _cerulean
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: _acceptedTerms
                                    ? _cerulean
                                    : _ink.withOpacity(0.15),
                                width: 1.5,
                              ),
                              boxShadow: _acceptedTerms
                                  ? [
                                      BoxShadow(
                                        color: _cerulean.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: _acceptedTerms
                                ? const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _ink.withOpacity(0.45),
                                  height: 1.6,
                                ),
                                children: [
                                  const TextSpan(text: 'Okudum ve '),
                                  TextSpan(
                                    text: 'Kullanım Koşulları',
                                    style: const TextStyle(
                                      color: _frost,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: _frost,
                                    ),
                                  ),
                                  const TextSpan(text: ' ile '),
                                  TextSpan(
                                    text: 'Gizlilik Politikası',
                                    style: const TextStyle(
                                      color: _frost,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: _frost,
                                    ),
                                  ),
                                  const TextSpan(text: '\'nı kabul ediyorum.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _red,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _red.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ).copyWith(
                          elevation: WidgetStateProperty.resolveWith((s) =>
                              s.contains(WidgetState.pressed) ? 2 : 8),
                          shadowColor:
                              WidgetStateProperty.all(_red.withOpacity(0.35)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22, width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hesap Oluştur',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_rounded, size: 16),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: _ink.withOpacity(0.08), thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'VEYA',
                            style: TextStyle(
                              fontSize: 11,
                              color: _ink.withOpacity(0.3),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: _ink.withOpacity(0.08), thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _buildSocialButton(
                          icon: _GoogleIcon(),
                          label: 'Google',
                          onTap: () {
                           
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildSocialButton(
                          icon: const Icon(Icons.facebook_rounded,
                              color: Color(0xFF1877F2), size: 20),
                          label: 'Facebook',
                          onTap: () {
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Giriş yap
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          foregroundColor: _red,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Zaten hesabın var mı? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _ink.withOpacity(0.4),
                                ),
                              ),
                              const TextSpan(
                                text: 'Giriş Yap',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _ink.withOpacity(0.4),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.25, 0,
      size.width * 0.5, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height,
      size.width, size.height * 0.25,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper _) => false;
}


class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
      width: 20,
      height: 20,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.language, color: Colors.blue, size: 20),
    );
  }
}
  @override
  bool shouldRepaint(_) => false;
