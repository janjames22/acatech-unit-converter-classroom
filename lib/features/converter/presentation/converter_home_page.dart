import 'package:flutter/material.dart';

import '../../../app/layout/app_breakpoints.dart';
import '../converter.dart';
import 'category_icon.dart';

typedef UnitSelectionCallback =
    void Function(UnitCategory category, UnitDefinition? initialUnit);

class ConverterHomePage extends StatefulWidget {
  const ConverterHomePage({
    required this.catalog,
    required this.onSelection,
    super.key,
  });

  final UnitCatalog catalog;
  final UnitSelectionCallback onSelection;

  @override
  State<ConverterHomePage> createState() => _ConverterHomePageState();
}

class _ConverterHomePageState extends State<ConverterHomePage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.catalog.searchCategories(_query);
    final searchResults = widget.catalog.search(_query);

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Convert with confidence',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a category or search any supported unit.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SearchBar(
                      controller: _searchController,
                      hintText: 'Search categories or units',
                      leading: const Icon(Icons.search_rounded),
                      trailing: [
                        if (_query.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                      ],
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_query.isNotEmpty && searchResults.isNotEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.contentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: _SearchResults(
                    results: searchResults,
                    onSelection: widget.onSelection,
                  ),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _query.isEmpty ? 'Categories' : 'Matching categories',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        if (categories.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptySearch(query: _query),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final horizontalMargin =
                    (constraints.crossAxisExtent -
                            AppBreakpoints.contentMaxWidth)
                        .clamp(0.0, double.infinity) /
                    2;
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 380,
                          mainAxisExtent: 190,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryCard(
                        category: category,
                        onTap: () => widget.onSelection(category, null),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.onSelection});

  final List<UnitSearchResult> results;
  final UnitSelectionCallback onSelection;

  @override
  Widget build(BuildContext context) {
    final visibleResults = results.take(8).toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Quick results',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final result in visibleResults)
              ListTile(
                leading: Icon(iconForCategory(result.category.id)),
                title: Text(result.label),
                subtitle: Text(
                  result.isUnit
                      ? '${result.category.name} · ${result.unit!.symbol}'
                      : '${result.category.units.length} units',
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () => onSelection(result.category, result.unit),
              ),
            if (results.length > visibleResults.length)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  '${results.length - visibleResults.length} more matches are available in the categories below.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final UnitCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.all(20),
            child: constraints.maxWidth < 270
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CategoryIcon(category: category, size: 48),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                      const Spacer(),
                      _CategoryLabels(category: category),
                    ],
                  )
                : Row(
                    children: [
                      _CategoryIcon(category: category, size: 56),
                      const SizedBox(width: 16),
                      Expanded(child: _CategoryLabels(category: category)),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category, required this.size});

  final UnitCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(
          iconForCategory(category.id),
          color: colorScheme.onSecondaryContainer,
          size: 30,
        ),
      ),
    );
  }
}

class _CategoryLabels extends StatelessWidget {
  const _CategoryLabels({required this.category});

  final UnitCategory category;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '${category.units.length} supported units',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 56),
            const SizedBox(height: 16),
            Text(
              'No results for “$query”',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a category, unit name, or symbol such as kg or °C.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
