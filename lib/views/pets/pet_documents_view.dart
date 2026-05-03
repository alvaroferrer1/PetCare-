import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../models/pet_document_model.dart';

class PetDocumentsView extends ConsumerStatefulWidget {
  const PetDocumentsView({required this.petId, super.key});

  final String petId;

  @override
  ConsumerState<PetDocumentsView> createState() => _PetDocumentsViewState();
}

class _PetDocumentsViewState extends ConsumerState<PetDocumentsView> {
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _notes = TextEditingController();
  String _type = 'vet_report';

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    final docs = state.documents
        .where((doc) => doc.petId == widget.petId)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Documentos')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: const [
              DropdownMenuItem(
                value: 'vet_report',
                child: Text('Informe veterinario'),
              ),
              DropdownMenuItem(
                value: 'vaccine_card',
                child: Text('Cartilla vacuna'),
              ),
              DropdownMenuItem(value: 'lab_result', child: Text('Analitica')),
              DropdownMenuItem(value: 'other', child: Text('Otro')),
            ],
            onChanged: (value) => setState(() => _type = value ?? 'other'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Titulo'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _url,
            decoration: const InputDecoration(labelText: 'URL del documento'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notas'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final profile = state.profile;
              if (profile == null || _title.text.trim().isEmpty) return;
              await ref
                  .read(appStateControllerProvider.notifier)
                  .addDocument(
                    PetDocumentModel(
                      id: '',
                      userId: profile.id,
                      petId: widget.petId,
                      title: _title.text.trim(),
                      documentType: _type,
                      fileUrl: _url.text.trim(),
                      notes: _notes.text.trim(),
                      createdAt: DateTime.now(),
                    ),
                  );
              _title.clear();
              _url.clear();
              _notes.clear();
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Guardar documento'),
          ),
          const SizedBox(height: 20),
          for (final doc in docs)
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(doc.title),
                subtitle: Text('${doc.documentType} · ${doc.notes}'),
              ),
            ),
        ],
      ),
    );
  }
}
