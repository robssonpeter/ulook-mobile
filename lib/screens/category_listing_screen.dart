import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/service_categories.dart';
import '../providers/data_provider.dart';
import '../widgets/professional_card.dart';
import '../widgets/ui.dart';
import 'professional_profile_screen.dart';

/// Lists the professionals that belong to a chosen [ServiceCategory].
class CategoryListingScreen extends StatefulWidget {
  final ServiceCategory category;
  const CategoryListingScreen({super.key, required this.category});

  @override
  State<CategoryListingScreen> createState() => _CategoryListingScreenState();
}

class _CategoryListingScreenState extends State<CategoryListingScreen> {
  double? _minRating;
  String? _sortBy;

  Future<void> _load() {
    return context.read<DataProvider>().fetchProfessionals(
          query: widget.category.keyword,
          minRating: _minRating,
          sortBy: _sortBy,
        );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) _load();
    });
  }

  Future<void> _showFilterSheet() async {
    double? tempRating = _minRating;
    String? tempSort = _sortBy;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter & Sort',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        tempRating = null;
                        tempSort = null;
                        setSheet(() {});
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Minimum Rating',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempRating ?? 0,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: tempRating != null
                            ? '${tempRating!.toStringAsFixed(1)}★'
                            : 'Any',
                        onChanged: (v) =>
                            setSheet(() => tempRating = v > 0 ? v : null),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        tempRating != null
                            ? '${tempRating!.toStringAsFixed(1)}★'
                            : 'Any',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Sort By',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _SortChip(
                      label: 'Default',
                      selected: tempSort == null,
                      onTap: () => setSheet(() => tempSort = null),
                    ),
                    _SortChip(
                      label: 'Top Rated',
                      selected: tempSort == 'rating',
                      onTap: () => setSheet(() => tempSort = 'rating'),
                    ),
                    _SortChip(
                      label: 'Nearest',
                      selected: tempSort == 'distance',
                      onTap: () => setSheet(() => tempSort = 'distance'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _minRating = tempRating;
                      _sortBy = tempSort;
                    });
                    _load();
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                  child: const Text('Apply'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = _minRating != null || _sortBy != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.label),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filter & Sort',
                onPressed: _showFilterSheet,
              ),
              if (hasFilters)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.isLoading && data.professionals.isEmpty) {
            return const AppSkeletonList(itemHeight: 104);
          }

          if (data.professionals.isEmpty) {
            return EmptyState(
              icon: widget.category.icon,
              title: 'No ${widget.category.label} found',
              subtitle: hasFilters
                  ? 'Try adjusting your filters.'
                  : 'We couldn\'t find professionals in this category near you.',
              actionLabel: hasFilters ? 'Clear Filters' : 'Refresh',
              onAction: () {
                if (hasFilters) {
                  setState(() {
                    _minRating = null;
                    _sortBy = null;
                  });
                }
                _load();
              },
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Top professionals near you',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                    if (_sortBy == 'rating')
                      const Text('★ Top rated',
                          style: TextStyle(fontSize: 12, color: Colors.amber)),
                    if (_sortBy == 'distance')
                      const Text('📍 Nearest',
                          style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                ...data.professionals.map(
                  (pro) => ProfessionalCard(
                    professional: pro,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfessionalProfileScreen(id: pro.id),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
            : null,
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
        ),
        labelStyle: TextStyle(
          color: selected ? Theme.of(context).colorScheme.primary : null,
          fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
