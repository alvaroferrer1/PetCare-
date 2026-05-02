import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/constants/app_copy.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/safety_badge.dart';
import '../../models/food_safety_item_model.dart';
import '../../models/product_check_model.dart';

class ProductCheckView extends ConsumerStatefulWidget {
  const ProductCheckView({super.key});

  @override
  ConsumerState<ProductCheckView> createState() => _ProductCheckViewState();
}

class _ProductCheckViewState extends ConsumerState<ProductCheckView> {
  final _query = TextEditingController();
  String _species = 'dog';
  bool _loading = false;
  ProductCheckModel? _result;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analizar producto')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Producto e ingredientes',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Busca un producto gratis en Open Food Facts y cruza sus ingredientes con la base de riesgos de la app.',
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            selected: {_species},
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
            onSelectionChanged: (value) =>
                setState(() => _species = value.first),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _query,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Nombre del producto',
              hintText: 'Ej. chocolate cookies, peanut butter',
              prefixIcon: const Icon(Icons.qr_code_scanner),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _check,
              ),
            ),
            onSubmitted: (_) => _check(),
          ),
          const SizedBox(height: 18),
          if (_loading)
            const LinearProgressIndicator()
          else if (_result == null)
            const EmptyState(
              icon: Icons.manage_search,
              title: 'Sin producto analizado',
              message: 'Busca un producto para revisar sus ingredientes.',
            )
          else
            _ProductResult(result: _result!),
          const SizedBox(height: 18),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(AppCopy.veterinaryNotice),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _check() async {
    if (_query.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final result = await ref
        .read(appStateControllerProvider.notifier)
        .checkProductIngredients(_query.text, _species);
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
  }
}

class _ProductResult extends StatelessWidget {
  const _ProductResult({required this.result});

  final ProductCheckModel result;

  @override
  Widget build(BuildContext context) {
    final level = result.hasRisks
        ? result.highestLevel
        : FoodSafetyLevel.unknown;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafetyBadge(level: level),
            const SizedBox(height: 12),
            Text(
              result.productName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(result.ingredients),
            const Divider(height: 28),
            if (result.matchedRisks.isEmpty)
              const Text(
                'No se han detectado ingredientes de riesgo en la base local, pero esto no significa que el producto sea seguro.',
              )
            else ...[
              const Text(
                'Ingredientes detectados en la base de riesgo:',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              for (final item in result.matchedRisks)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.foodName),
                  subtitle: Text(item.description),
                  trailing: SafetyBadge(level: item.safetyLevel),
                ),
            ],
            const Divider(height: 28),
            Text('Fuente: ${result.source}'),
          ],
        ),
      ),
    );
  }
}
