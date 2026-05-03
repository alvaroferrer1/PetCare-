import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/constants/app_copy.dart';
import '../../core/widgets/empty_state.dart';

class EmergencyView extends ConsumerWidget {
  const EmergencyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final profile = state.profile;
    final emergencyContacts = state.vetContacts
        .where((contact) => contact.isEmergency)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Emergencia')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Actua con calma',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(AppCopy.veterinaryNotice),
          const SizedBox(height: 18),
          Card(
            color: Colors.red.shade50,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Senales para consultar rapido',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 10),
                  _EmergencyPoint('Ingestion de alimento toxico.'),
                  _EmergencyPoint('Dificultad para respirar.'),
                  _EmergencyPoint('Vomitos repetidos o sangre.'),
                  _EmergencyPoint('Convulsiones, desmayo o debilidad extrema.'),
                  _EmergencyPoint('Dolor intenso o accidente.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if ((profile?.emergencyVetName.isNotEmpty ?? false) ||
              emergencyContacts.isNotEmpty)
            Column(
              children: [
                if (profile?.emergencyVetName.isNotEmpty ?? false)
                  _ContactCard(
                    title: profile!.emergencyVetName,
                    subtitle: 'Veterinario principal',
                    phone: profile.emergencyVetPhone,
                  ),
                for (final contact in emergencyContacts)
                  _ContactCard(
                    title: contact.name,
                    subtitle: contact.clinic.isEmpty
                        ? 'Contacto de emergencia'
                        : contact.clinic,
                    phone: contact.phone,
                  ),
              ],
            )
          else
            const EmptyState(
              icon: Icons.local_hospital_outlined,
              title: 'Sin contacto de emergencia',
              message:
                  'Anade un veterinario de emergencia para tenerlo a mano.',
            ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos utiles',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text('Mascotas registradas: ${state.pets.length}'),
                  Text(
                    'Alergias registradas: ${state.pets.where((p) => p.allergies.isNotEmpty).length}',
                  ),
                  Text('Eventos pendientes: ${state.pendingEvents.length}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyPoint extends StatelessWidget {
  const _EmergencyPoint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.title,
    required this.subtitle,
    required this.phone,
  });

  final String title;
  final String subtitle;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.call_outlined)),
        title: Text(title),
        subtitle: Text(phone.isEmpty ? subtitle : '$subtitle · $phone'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
