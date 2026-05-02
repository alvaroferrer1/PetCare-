import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/constants/app_copy.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/safety_badge.dart';
import '../../models/food_safety_item_model.dart';

class FoodSafetyView extends ConsumerStatefulWidget {
  const FoodSafetyView({super.key});

  @override
  ConsumerState<FoodSafetyView> createState() => _FoodSafetyViewState();
}

class _FoodSafetyViewState extends ConsumerState<FoodSafetyView> {
  final _query = TextEditingController();
  String _species = 'dog';
  FoodSafetyLevel? _filterLevel;
  FoodSafetyItemModel? _highlight;
  bool _searchingExternal = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(appStateControllerProvider).foodItems;
    final filtered = _filter(items);
    final common = items
        .where((item) => item.species == _species)
        .take(10)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Food Safety')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Busca antes de compartir comida',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'La base local evita respuestas inventadas: si no aparece, se marca como desconocido.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'dog',
                label: Text('Perro'),
                icon: Icon(Icons.pets),
              ),
              ButtonSegment(
                value: 'cat',
                label: Text('Gato'),
                icon: Icon(Icons.cruelty_free),
              ),
            ],
            selected: {_species},
            onSelectionChanged: (value) => setState(() {
              _species = value.first;
              _highlight = null;
            }),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _query,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Buscar alimento',
              hintText: 'Ej. chocolate, arroz, cebolla',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.text.isEmpty
                  ? IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _search,
                    )
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _query.clear();
                          _highlight = null;
                        });
                      },
                    ),
            ),
            onChanged: (_) => setState(() => _highlight = null),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          _SafetyFilters(
            selected: _filterLevel,
            onChanged: (value) => setState(() => _filterLevel = value),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: common
                .map(
                  (item) => ActionChip(
                    avatar: Icon(
                      item.safetyLevel == FoodSafetyLevel.toxic
                          ? Icons.warning_amber
                          : Icons.restaurant,
                      size: 18,
                    ),
                    label: Text(item.foodName),
                    onPressed: () {
                      _query.text = item.foodName;
                      _search();
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _searchingExternal
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Buscando en base local y fuente externa gratuita...',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _highlight == null
                ? const SizedBox.shrink()
                : _FoodResultCard(item: _highlight!),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Directorio curado',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Chip(label: Text('${filtered.length}')),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.manage_search,
                    title: 'Sin coincidencias',
                    message:
                        'No hay alimentos con esos filtros. Prueba otra busqueda o cambia el nivel de seguridad.',
                    action: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _query.clear();
                          _filterLevel = null;
                          _highlight = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Limpiar filtros'),
                    ),
                  )
                : Column(
                    children: [
                      for (final entry in filtered.take(30).indexed)
                        AnimatedListItem(
                          index: entry.$1,
                          child: _FoodCompactTile(item: entry.$2),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(child: Text(AppCopy.veterinaryNotice)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FoodSafetyItemModel> _filter(List<FoodSafetyItemModel> items) {
    final query = normalizeFoodName(_query.text);
    return items.where((item) {
      if (item.species != _species) return false;
      if (_filterLevel != null && item.safetyLevel != _filterLevel) {
        return false;
      }
      if (query.isEmpty) return true;
      return item.normalizedName.contains(query) ||
          query.contains(item.normalizedName);
    }).toList()..sort((a, b) {
      final level = a.safetyLevel.index.compareTo(b.safetyLevel.index);
      if (level != 0) return level;
      return a.foodName.compareTo(b.foodName);
    });
  }

  Future<void> _search() async {
    setState(() => _searchingExternal = true);
    final result = await ref
        .read(appStateControllerProvider.notifier)
        .searchFoodWithExternalFallback(_query.text, _species);
    if (!mounted) return;
    setState(() {
      _highlight = result;
      _searchingExternal = false;
    });
  }
}

class _SafetyFilters extends StatelessWidget {
  const _SafetyFilters({required this.selected, required this.onChanged});

  final FoodSafetyLevel? selected;
  final ValueChanged<FoodSafetyLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <FoodSafetyLevel?>[
      null,
      FoodSafetyLevel.safe,
      FoodSafetyLevel.caution,
      FoodSafetyLevel.toxic,
      FoodSafetyLevel.unknown,
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final active = option == selected;
          return FilterChip(
            selected: active,
            label: Text(option == null ? 'Todos' : option.label),
            avatar: option == null ? const Icon(Icons.tune, size: 18) : null,
            onSelected: (_) => onChanged(option),
          );
        },
      ),
    );
  }
}

class _FoodCompactTile extends StatelessWidget {
  const _FoodCompactTile({required this.item});

  final FoodSafetyItemModel item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(item.species == 'dog' ? Icons.pets : Icons.cruelty_free),
        title: Text(item.foodName),
        subtitle: Text(item.description, maxLines: 2),
        trailing: SafetyBadge(level: item.safetyLevel),
      ),
    );
  }
}

class _FoodResultCard extends StatelessWidget {
  const _FoodResultCard({required this.item});

  final FoodSafetyItemModel item;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(
        '${item.species}-${item.foodName}-${item.safetyLevel.name}',
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafetyBadge(level: item.safetyLevel),
            const SizedBox(height: 12),
            Text(
              item.foodName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(item.description),
            if (item.safetyLevel == FoodSafetyLevel.unknown) ...[
              const SizedBox(height: 12),
              const Text(
                'No se muestra como fallo: la app evita inventar seguridad alimentaria cuando no hay datos curados.',
              ),
            ],
            const Divider(height: 28),
            Text('Fuente: ${item.source}'),
          ],
        ),
      ),
    );
  }
}
