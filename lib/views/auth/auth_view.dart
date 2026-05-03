import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'demo@petcare.app');
  final _password = TextEditingController(text: 'demopass');
  final _confirmPassword = TextEditingController(text: 'demopass');
  final _fullName = TextEditingController();
  bool _register = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _fullName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 34),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _register ? 'Crear cuenta' : 'Bienvenido de nuevo',
                  key: ValueKey(_register),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _register
                    ? 'Crea tu perfil para guardar mascotas, cuidados y notas.'
                    : 'Accede para sincronizar tus mascotas, eventos y notas.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              if (_register) ...[
                TextFormField(
                  controller: _fullName,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Ej. Alvaro Ferrer',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'nombre@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: _hidePassword,
                textInputAction: _register
                    ? TextInputAction.next
                    : TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Contrasena',
                  hintText: 'Minimo 8 caracteres',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                validator: _validatePassword,
              ),
              if (_register) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: _hidePassword,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contrasena',
                    hintText: 'Repite la contrasena',
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                  validator: (value) {
                    if (value != _password.text) {
                      return 'Las contrasenas no coinciden.';
                    }
                    return null;
                  },
                ),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 14),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ],
              if (state.message != null) ...[
                const SizedBox(height: 14),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      state.message!,
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: state.loading ? null : _submit,
                child: state.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_register ? 'Registrarme' : 'Entrar'),
              ),
              if (!_register) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: state.loading
                      ? null
                      : () => ref
                            .read(appStateControllerProvider.notifier)
                            .startDemoSession(),
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Entrar en demo para video'),
                ),
              ],
              TextButton(
                onPressed: () => setState(() => _register = !_register),
                child: Text(
                  _register
                      ? 'Ya tengo cuenta'
                      : 'No tengo cuenta, registrarme',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(appStateControllerProvider.notifier);
    if (_register) {
      await controller.register(
        _email.text.trim(),
        _password.text,
        fullName: _fullName.text.trim(),
      );
    } else {
      await controller.signIn(_email.text.trim(), _password.text);
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'El email es obligatorio.';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valid ? null : 'Introduce un email valido.';
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) {
      return 'La contrasena debe tener minimo 8 caracteres.';
    }
    return null;
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 2) return 'El nombre debe tener al menos 2 letras.';
    if (RegExp(r'^\d+$').hasMatch(name)) {
      return 'El nombre no puede ser solo numeros.';
    }
    return null;
  }
}
