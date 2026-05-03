import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../models/vet_contact_model.dart';

class VetContactsView extends ConsumerStatefulWidget {
  const VetContactsView({super.key});

  @override
  ConsumerState<VetContactsView> createState() => _VetContactsViewState();
}

class _VetContactsViewState extends ConsumerState<VetContactsView> {
  final _name = TextEditingController();
  final _clinic = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  bool _isEmergency = true;

  @override
  void dispose() {
    _name.dispose();
    _clinic.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Veterinarios')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Contactos y emergencia',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _clinic,
            decoration: const InputDecoration(labelText: 'Clinica'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Telefono'),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: _isEmergency,
            onChanged: (value) => setState(() => _isEmergency = value),
            title: const Text('Contacto de emergencia'),
          ),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notas'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final profile = state.profile;
              if (profile == null || _name.text.trim().isEmpty) return;
              await ref
                  .read(appStateControllerProvider.notifier)
                  .saveVetContact(
                    VetContactModel(
                      id: '',
                      userId: profile.id,
                      name: _name.text.trim(),
                      clinic: _clinic.text.trim(),
                      phone: _phone.text.trim(),
                      notes: _notes.text.trim(),
                      isEmergency: _isEmergency,
                    ),
                  );
              _name.clear();
              _clinic.clear();
              _phone.clear();
              _notes.clear();
            },
            icon: const Icon(Icons.add),
            label: const Text('Guardar contacto'),
          ),
          const SizedBox(height: 20),
          for (final contact in state.vetContacts)
            Card(
              child: ListTile(
                leading: Icon(
                  contact.isEmergency
                      ? Icons.local_hospital
                      : Icons.medical_services_outlined,
                ),
                title: Text(contact.name),
                subtitle: Text('${contact.clinic} · ${contact.phone}'),
                trailing: contact.isEmergency
                    ? const Chip(label: Text('Emergencia'))
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
