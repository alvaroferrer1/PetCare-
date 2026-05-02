import 'package:flutter/material.dart';

import '../../core/constants/app_copy.dart';

class ResourcesView extends StatelessWidget {
  const ResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final resources = [
      _ResourceItem(
        icon: Icons.health_and_safety_outlined,
        title: 'Uso responsable de IA',
        body:
            'La IA organiza informacion y prepara preguntas. No diagnostica ni sustituye al veterinario.',
      ),
      _ResourceItem(
        icon: Icons.restaurant_menu,
        title: 'Alimentos',
        body:
            'La seguridad alimentaria usa una base local curada. Si no hay datos, se muestra desconocido.',
      ),
      _ResourceItem(
        icon: Icons.vaccines_outlined,
        title: 'Historial',
        body:
            'Vacunas, medicacion, visitas y notas se guardan por mascota y usuario.',
      ),
      _ResourceItem(
        icon: Icons.security,
        title: 'Privacidad',
        body:
            'Supabase RLS limita los datos para que cada usuario vea solo sus mascotas y registros.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Guia y seguridad')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Centro de confianza',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(AppCopy.veterinaryNotice),
          const SizedBox(height: 18),
          for (final item in resources)
            Card(
              child: ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                subtitle: Text(item.body),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResourceItem {
  const _ResourceItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
