import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../models/profile_model.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _vetName;
  late final TextEditingController _vetPhone;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(appStateControllerProvider).profile;
    _fullName = TextEditingController(text: profile?.fullName ?? '');
    _phone = TextEditingController(text: profile?.phone ?? '');
    _vetName = TextEditingController(text: profile?.emergencyVetName ?? '');
    _vetPhone = TextEditingController(text: profile?.emergencyVetPhone ?? '');
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _vetName.dispose();
    _vetPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(appStateControllerProvider).profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del dueno')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 34, child: Icon(Icons.person)),
                  const SizedBox(height: 16),
                  Text(
                    profile?.fullName.isEmpty ?? true
                        ? 'Dueno de mascotas'
                        : profile!.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(profile?.email ?? ''),
                  const Divider(height: 30),
                  const Text('Veterinario de emergencia'),
                  const SizedBox(height: 6),
                  Text(
                    profile?.emergencyVetName.isEmpty ?? true
                        ? 'Pendiente de completar'
                        : profile!.emergencyVetName,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _fullName,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefono',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vetName,
            decoration: const InputDecoration(
              labelText: 'Veterinario de emergencia',
              prefixIcon: Icon(Icons.local_hospital_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vetPhone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefono veterinario',
              prefixIcon: Icon(Icons.call_outlined),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: profile == null ? null : () => _save(profile),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar perfil'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () =>
                ref.read(appStateControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(ProfileModel profile) async {
    await ref
        .read(appStateControllerProvider.notifier)
        .saveProfile(
          profile.copyWith(
            fullName: _fullName.text.trim(),
            phone: _phone.text.trim(),
            emergencyVetName: _vetName.text.trim(),
            emergencyVetPhone: _vetPhone.text.trim(),
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
  }
}
