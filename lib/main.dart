import 'package:flutter/material.dart';
import 'package:helloworldschool/services/database_service.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cadastra o usuário teste antes de iniciar o app
  await _registerTestUser();

  runApp(MyApp());
}

Future<void> _registerTestUser() async {
  final authService = AuthService();
  try {
    // Verifica se o usuário já existe antes de cadastrar
    final existingUser = await authService.login("aluno@teste.com", "senha123");
    if (existingUser == null) {
      await authService.registerUser(
        name: "Aluno Teste",
        email: "aluno@teste.com",
        password: "senha123",
        phone: "(11) 99999-9999",
        type: "student",
        additionalData: {"level": "Iniciante"},
      );
      print("✅ Usuário teste cadastrado com sucesso!");
    } else {
      print("ℹ️ Usuário teste já existe");
    }
  } catch (e) {
    print("⛔ Erro ao cadastrar usuário teste: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escola de Inglês',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _debugUsers();
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciamento Escolar')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ),
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  ),
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _debugUsers() async {
    final db = await DatabaseService().database;
    final users = await db.query('users');
    print('Usuários no banco');
    users.forEach(print);
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'aluno@teste.com');
  final _passwordController = TextEditingController(text: 'senha123');
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Email ou senha incorretos')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator:
                    (value) => value!.isEmpty ? 'Digite seu email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Senha'),
                validator:
                    (value) => value!.isEmpty ? 'Digite sua senha' : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: _login, child: Text('Entrar')),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Novo Aluno');
  final _emailController = TextEditingController(text: 'novo@teste.com');
  final _phoneController = TextEditingController(text: '(11) 99999-9999');
  final _passwordController = TextEditingController(text: 'senha123');
  final _authService = AuthService();
  bool _isLoading = false;
  String _userType = 'student';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = await _authService.registerUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
          type: _userType,
        );

        if (user != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Registro bem-sucedido!')));
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro no registro: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome completo'),
                validator: (value) => value!.isEmpty ? 'Digite seu nome' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator:
                    (value) => value!.isEmpty ? 'Digite seu email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                validator:
                    (value) => value!.isEmpty ? 'Digite seu telefone' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Senha'),
                validator:
                    (value) => value!.isEmpty ? 'Digite sua senha' : null,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _userType,
                items: [
                  DropdownMenuItem(value: 'student', child: Text('Aluno')),
                  DropdownMenuItem(value: 'teacher', child: Text('Professor')),
                ],
                onChanged: (value) => setState(() => _userType = value!),
                decoration: InputDecoration(labelText: 'Tipo de usuário'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _register,
                    child: Text('Registrar'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, ${user.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthWrapper()),
                ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: ${user.email}'),
            Text('Tipo: ${user.type}'),
            Text('Status: ${user.isApproved ? 'Aprovado' : 'Pendente'}'),
          ],
        ),
      ),
    );
  }
}
