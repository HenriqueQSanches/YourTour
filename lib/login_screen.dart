// lib/login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();

  String _captchaGerado = '';
  bool _senhaVisivel = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gerarCaptcha();
  }

  void _gerarCaptcha() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = String.fromCharCodes(
      List.generate(
        6,
        (index) => chars.codeUnitAt(
          (DateTime.now().microsecondsSinceEpoch + index) % chars.length,
        ),
      ),
    );
    setState(() {
      _captchaGerado = random;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      if (_captchaController.text.toUpperCase() != _captchaGerado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código CAPTCHA incorreto'),
            backgroundColor: Colors.red,
          ),
        );
        _gerarCaptcha();
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulação de processo de login
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Login bem-sucedido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar para tela principal (substituir pela navegação real)
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
    }
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/cadastro');
  }

  void _navigateToRecuperarSenha() {
    // Implementar navegação para recuperação de senha
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tela de fundo 1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    margin: const EdgeInsets.only(bottom: 16, top: 40),
                    child: Image.asset(
                      'assets/images/youtour-removebg-preview.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          children: [
                            Icon(
                              Icons.travel_explore,
                              size: 60,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Youtour',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Texto de boas-vindas
                  const Text(
                    'Bem-vindo de volta!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Faça login para continuar sua jornada',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Campos do formulário
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'E-mail*',
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.purpleAccent,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, informe seu e-mail';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Por favor, informe um e-mail válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Senha
                          TextFormField(
                            controller: _senhaController,
                            obscureText: !_senhaVisivel,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Senha*',
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.purpleAccent,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _senhaVisivel
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _senhaVisivel = !_senhaVisivel;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, informe sua senha';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Esqueci a senha
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _navigateToRecuperarSenha,
                              child: const Text(
                                'Esqueceu sua senha?',
                                style: TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // CAPTCHA
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Verificação CAPTCHA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _captchaGerado,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: Colors.purpleAccent,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _captchaController,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          letterSpacing: 1,
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Digite o código',
                                          hintStyle: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.purpleAccent,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.2,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 12,
                                              ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Digite o código CAPTCHA';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _gerarCaptcha,
                                      tooltip: 'Gerar novo código',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botão de Login
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  212,
                                  102,
                                  187,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 6,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'ENTRAR',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divisor
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'ou',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Botão de Login com Google
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                // Implementar login com Google
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.g_mobiledata,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Continuar com Google',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Link para cadastro
                          Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.purpleAccent.withOpacity(0.8),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Não tem uma conta?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _navigateToSignUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purpleAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'CADASTRE-SE',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _captchaController.dispose();
    super.dispose();
  }
}
