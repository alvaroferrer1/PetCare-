import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final _email = TextEditingController(text: 'demo@petcare.app');
  final _password = TextEditingController(text: 'demopass');
  bool _register = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            Text(
              _register ? 'Crear cuenta' : 'Bienvenido de nuevo',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Accede para sincronizar tus mascotas, eventos y notas con Supabase.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contrasena',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 14),
              Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton(
              onPressed: state.loading
                  ? null
                  : () {
                      final controller = ref.read(
                        appStateControllerProvider.notifier,
                      );
                      if (_register) {
                        controller.register(_email.text, _password.text);
                      } else {
                        controller.signIn(_email.text, _password.text);
                      }
                    },
              child: state.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_register ? 'Registrarme' : 'Entrar'),
            ),
            TextButton(
              onPressed: () => setState(() => _register = !_register),
              child: Text(
                _register ? 'Ya tengo cuenta' : 'No tengo cuenta, registrarme',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
