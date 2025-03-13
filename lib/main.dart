//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shoply/firebase_options.dart';
import 'package:shoply/models/task.dart';
import 'package:shoply/screens/home_screen.dart';

// Pantallas de autenticación
//import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'package:shoply/screens/auth/forgot_password_screen.dart';

// Pantallas de listas
import 'screens/list/add_list_screen.dart';
import 'screens/list/edit_list_screen.dart';
import 'screens/list/list_screen.dart';

// Pantallas de perfil
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/edit_profile_screen.dart'; // Agregada para la pantalla de edición de perfil

// Proveedores
import 'screens/providers/task_providers.dart';

// Pantallas de tareas
import 'screens/task/add_task_screen.dart';
import 'screens/task/edit_task_screen.dart';
import 'screens/task/trash_screen.dart';

// Pantallas de settings
import 'screens/settings/contact_support_screen.dart';
import 'screens/settings/faqs_screen.dart';
import 'screens/settings/language_screen.dart';
import 'screens/settings/privacy_policy_screen.dart';
import 'screens/settings/send_feedback_screen.dart';

void main() async {

 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const ShoplyApp(),
    ),
  );
}

class ShoplyApp extends StatelessWidget {
  const ShoplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoply',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(), // Pantalla de login inicial
        '/register': (context) =>
             RegisterScreen(), // Pantalla de registro
        //'/forgotPassword': (context) =>
        // const ForgotPasswordScreen(), // Recuperación de contraseña

        '/home': (context) {
                              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                              return HomeScreen(
                                email: args['email'],
                                password: args['password'],
                                id: args['id'],
                                username: args['username']
                              );
                            }, // Pantalla principal
                            
        '/listScreen': (context) =>
            const ListScreen(), // Pantalla de lista de compras
        '/editList': (context) => EditListScreen(), // Editar lista de compras

        '/addTask': (context) => AddTaskScreen(), // Pantalla para agregar tarea
        '/addList': (context) => AddListScreen(
              // ignore: avoid_types_as_parameter_names
              addListCallback: (String, Color) {},
            ), // Pantalla para agregar lista
        '/editTask': (context) => EditTaskScreen(
              task: Task(
                  id: '',
                  title: ''), // Provisión de un objeto Task predeterminado
            ), // Pantalla para editar tarea
        '/trash': (context) =>
            const TrashScreen(trashLists: []), // Papelera de tareas

        '/profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProfileScreen(
            username: args['username'],
            email: args['email'],
            userId: args['userId'],
          );
        },
        '/editProfile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EditProfileScreen(
            username: args['username'],
            email: args['email'],
            userId: args['userId'],
          );
        }, 
        '/settings': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                  return SettingsScreen(
                    userId: args['userId'],
                  );
                },        
        '/forgotPassword': (context) => const ChangePasswordScreen(),
        '/privacy_policy': (context) => PrivacyPolicyScreen(),
        '/contact_support': (context) => ContactSupportScreen(),
        '/faqs': (context) => FaqsScreen(),
        '/send_feedback': (context) => SendFeedbackScreen(),
        '/language': (context) => LanguageScreen(),
      },
    );
  }
}
