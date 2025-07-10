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
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email ou senha incorretos')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'fotos/fotoprova.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 100),
                    Text(
                      'HELLO WORLD',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 0.8,
                      ),
                    ),
                    Text(
                      'ENGLISH SCHOOL',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email
                    Text(
                      'EMAIL',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(44, 255, 255, 255),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) =>
                            value!.isEmpty ? 'Digite seu email' : null,
                        decoration: InputDecoration(
                          hintText: 'HELLO@EXAMPLE.COM',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Senha
                    Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(52, 255, 255, 255),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) =>
                            value!.isEmpty ? 'Digite sua senha' : null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Botão de login
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 210, 198, 33),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : Text(
                                  'LOGIN',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Link registrar-se
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OpcaoRegistro()),
                          );
                        },
                        child: Text(
                          'REGISTRAR-SE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpcaoRegistro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'fotos/fotoprova.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'CADASTRAR-SE',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Text(
                    'Qual seu tipo de usuário?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 300,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 240, 153, 39),
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: Text(
                        'SOU ALUNO',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 300,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 240, 153, 39),
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: Text(
                        'SOU PROFESSOR(A)',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
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
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'fotos/fotoprova.jpg',
            fit: BoxFit.cover,
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const SizedBox(height: 100),
                     Text(
                    'CADASTRAR-SE',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                      
                      const SizedBox(height: 30),
                      Text(
                        'NOME',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(44, 255, 255, 255),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                
            
                Text(
                  'EMAIL',
                    style: TextStyle(
                     fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                ),
),
Container(
  decoration: BoxDecoration(
    color: const Color.fromARGB(44, 255, 255, 255),
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: TextFormField(
    controller: _emailController,
    validator: (value) =>
        value!.isEmpty ? 'Digite seu email' : null,
    decoration: InputDecoration(
      border: InputBorder.none,
    ),
    style: TextStyle(color: Colors.white),
  ),
),

                       const SizedBox(height: 10),
                Text(
                  'SENHA',
                    style: TextStyle(
                     fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                ),
),
Container(
  decoration: BoxDecoration(
    color: const Color.fromARGB(44, 255, 255, 255),
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: TextFormField(
    controller: _phoneController,
    validator: (value) =>
        value!.isEmpty ? 'Digite sua senha' : null,
    decoration: InputDecoration(
      border: InputBorder.none,
    ),
    style: TextStyle(color: Colors.white),
  ),
),
  const SizedBox(height: 10),
                Text(
                  'TELEFONE',
                    style: TextStyle(
                     fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                ),
),
Container(
  decoration: BoxDecoration(
    color: const Color.fromARGB(44, 255, 255, 255),
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: TextFormField(
    controller: _passwordController,
    obscureText: true,
                  decoration: InputDecoration(labelText: 'Senha'),
                  validator: (value) =>
                      value!.isEmpty ? 'Digite sua senha' : null,
    style: TextStyle(color: Colors.white),
  ),
),
                 const SizedBox(height: 80),
Align(
  alignment: Alignment.center,
  child: SizedBox(
    width: 250,
    height: 50,
       child:  ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CadastroEnviadoScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 210, 198, 33),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      child: Text(
        'CADASTRE-SE',
        style: TextStyle(fontSize:22, fontWeight: FontWeight.bold),
      ),
    ),
                 ),
),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}

class CadastroEnviadoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'fotos/fotoprova.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
  'Seu cadastro foi enviado para análise.\n'
  'Você será notificado assim que for aprovado.',
  style: TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  ),
  textAlign: TextAlign.center,
),
),

                const SizedBox(height: 30),
  Text(
 'THANKS!!!',
  style: TextStyle(
    fontSize: 30,
    color: const Color.fromARGB(255, 255, 255, 255),
    fontWeight: FontWeight.bold,
  ),
  textAlign: TextAlign.center,
),
const SizedBox(height: 90),
                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 210, 198, 33),
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    child: Text(
                      'OKAY',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
                  MaterialPageRoute(builder: (context) => LoginScreen()),
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
