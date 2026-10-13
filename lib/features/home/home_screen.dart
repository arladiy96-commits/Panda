import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/panda_theme.dart';

class _Dish {
  const _Dish({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  final String name;
  final String description;
  final int price;
  final String image;
}

const _dishes = <_Dish>[
  _Dish(
    name: 'Паста с лососем',
    description: 'Паста Фетучини, лосось, помидор, лук, чеснок, сливки, сыр пармезан',
    price: 3290,
    image: 'assets/images/pasta_salmon.jpg',
  ),
  _Dish(
    name: 'Паста с курицей и грибами',
    description: 'Паста Фетучини, шампиньоны, курица, лук, чеснок, сливки, пармезан',
    price: 2690,
    image: 'assets/images/pasta_chicken.jpg',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _mode = 0;
  int _tab = 0;
  int _category = 0;
  final Map<int, int> _basket = {};
  final Set<int> _favorites = {};

  static const _modes = ['Доставка', 'Самовывоз', 'В зале'];
  static const _categories = ['WOK и Паста', 'Детское меню', 'Акции 1+1'];
  static const _promos = [
    'assets/images/promo_1.jpg',
    'assets/images/promo_2.jpg',
    'assets/images/promo_3.jpg',
  ];

  int get _basketCount => _basket.values.fold(0, (a, b) => a + b);
  int get _basketTotal => _basket.entries.fold(
        0,
        (sum, item) => sum + _dishes[item.key].price * item.value,
      );

  void _addToBasket(int index, int count) {
    setState(() {
      _basket.update(index, (existing) => existing + count, ifAbsent: () => count);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Добавлено в корзину'),
        duration: Duration(milliseconds: 1100),
      ),
    );
  }

  void _openDish(int index) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PandaColors.background,
      showDragHandle: true,
      builder: (ctx) => _DishSheet(
        dish: _dishes[index],
        onAdd: (quantity) {
          Navigator.pop(ctx);
          _addToBasket(index, quantity);
        },
      ),
    );
  }

  void _openModePicker(int mode) {
    setState(() => _mode = mode);
    if (mode == 0) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: PandaColors.background,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                mode == 1 ? 'Выберите ресторан для самовывоза' : 'Выберите ресторан',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.map_outlined, size: 74, color: Colors.white54),
              const SizedBox(height: 12),
              const Center(child: Text('Карту филиалов добавим следующим этапом.')),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Продолжить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: PandaColors.background,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: PandaColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: PandaColors.background,
        drawer: _PandaDrawer(
          onSelect: (tab) {
            Navigator.pop(context);
            setState(() => _tab = tab);
          },
        ),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          toolbarHeight: 58,
          backgroundColor: PandaColors.background,
          title: const Text(
            'Panda',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          leading: Builder(
            builder: (context) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 27),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                Positioned(
                  right: 8,
                  top: 4,
                  child: Container(
                    width: 15,
                    height: 15,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: PandaColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('5', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => showSearch<String>(
                context: context,
                delegate: _PandaSearchDelegate(),
              ),
              icon: const Icon(Icons.search, size: 28),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: switch (_tab) {
          0 => _catalog(),
          1 => _profile(),
          2 => _favoritesScreen(),
          _ => _cart(),
        },
        bottomNavigationBar: _bottomBar(),
      ),
    );
  }

  Widget _catalog() => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 1, 15, 10),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: List.generate(
                        _modes.length,
                        (i) => Expanded(
                          child: GestureDetector(
                            onTap: () => _openModePicker(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _mode == i ? Colors.black : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _modes[i],
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GestureDetector(
                    onTap: () => _openModePicker(_mode),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2B2B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'улица Карима Сутюшева, 49',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 146,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount: _promos.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 6),
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _promos[index],
                        width: 112,
                        height: 146,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => setState(() => _category = index),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _category == index ? Colors.black : PandaColors.chip,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _categories[index],
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _DishCard(
                  dish: _dishes[index],
                  onTap: () => _openDish(index),
                ),
                childCount: _dishes.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.56,
              ),
            ),
          ),
        ],
      );

  Widget _bottomBar() => SafeArea(
        top: false,
        child: Container(
          height: 61,
          color: PandaColors.background,
          child: Row(
            children: [
              _bottomItem(0, Icons.list_alt_rounded, 'Меню'),
              _bottomItem(1, Icons.account_circle_rounded, 'Профиль'),
              _bottomItem(2, Icons.favorite_rounded, 'Любимые'),
              _bottomItem(3, Icons.shopping_bag_rounded, 'Корзина'),
            ],
          ),
        ),
      );

  Widget _bottomItem(int index, IconData icon, String label) {
    final selected = _tab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: selected ? Colors.white : Colors.white54, size: 26),
                if (index == 3 && _basketCount > 0)
                  Positioned(
                    top: -5,
                    right: -9,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: PandaColors.red,
                      child: Text('$_basketCount', style: const TextStyle(fontSize: 9)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: selected ? Colors.white : Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profile() => _emptyTab(
        icon: Icons.account_circle_rounded,
        title: 'Профиль',
        caption: 'Здесь будет точная копия личного кабинета Panda.',
      );

  Widget _favoritesScreen() => _favorites.isEmpty
      ? _emptyTab(
          icon: Icons.favorite_border,
          title: 'Любимые',
          caption: 'Сохранённые товары появятся здесь.',
        )
      : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Любимые', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._favorites.map(
              (i) => ListTile(
                leading: Image.asset(_dishes[i].image, width: 56, fit: BoxFit.cover),
                title: Text(_dishes[i].name),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: PandaColors.red),
                  onPressed: () => setState(() => _favorites.remove(i)),
                ),
                onTap: () => _openDish(i),
              ),
            ),
          ],
        );

  Widget _cart() {
    if (_basketCount == 0) {
      return _emptyTab(
        icon: Icons.shopping_bag_outlined,
        title: 'Корзина пуста',
        caption: 'Добавьте блюда из меню.',
        action: () => setState(() => _tab = 0),
        actionLabel: 'Перейти в меню',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(18),
          child: Text('Корзина', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: ListView(
            children: _basket.entries.map((entry) {
              final dish = _dishes[entry.key];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(dish.image, width: 57, height: 57, fit: BoxFit.cover),
                ),
                title: Text(dish.name),
                subtitle: Text('${dish.price} ₸ × ${entry.value}'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _basket.remove(entry.key)),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Оформление заказа добавим позже')),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(51),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text('К оформлению · $_basketTotal ₸'),
          ),
        ),
      ],
    );
  }

  Widget _emptyTab({
    required IconData icon,
    required String title,
    required String caption,
    VoidCallback? action,
    String? actionLabel,
  }) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 70, color: Colors.white38),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(caption, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
              if (action != null) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: action,
                  style: FilledButton.styleFrom(backgroundColor: Colors.black),
                  child: Text(actionLabel ?? 'Продолжить'),
                ),
              ],
            ],
          ),
        ),
      );
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.dish, required this.onTap});

  final _Dish dish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PandaColors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Image.asset(dish.image, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.7, color: PandaColors.muted, height: 1.16),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text('${dish.price} ₸', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DishSheet extends StatefulWidget {
  const _DishSheet({required this.dish, required this.onAdd});

  final _Dish dish;
  final ValueChanged<int> onAdd;

  @override
  State<_DishSheet> createState() => _DishSheetState();
}

class _DishSheetState extends State<_DishSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(dish.image, width: double.infinity, height: 255, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 5),
                      child: Text(dish.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(dish.description, style: const TextStyle(color: Colors.white60)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => widget.onAdd(_quantity),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text('В корзину · ${dish.price * _quantity} ₸'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PandaDrawer extends StatelessWidget {
  const _PandaDrawer({required this.onSelect});

  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: PandaColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Text('Panda', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
            ),
            const Divider(color: Colors.white12),
            _tile(Icons.account_circle_outlined, 'Профиль', () => onSelect(1)),
            _tile(Icons.shopping_bag_outlined, 'Корзина', () => onSelect(3)),
            _tile(Icons.favorite_outline, 'Любимые', () => onSelect(2)),
            _tile(Icons.receipt_long_outlined, 'История заказов', () => onSelect(1)),
            _tile(Icons.campaign_outlined, 'Акции', () => onSelect(0)),
            _tile(Icons.notifications_outlined, 'Сообщения', () => onSelect(1)),
            _tile(Icons.language, 'Язык', () => Navigator.pop(context)),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('Визуальный прототип · 0.1', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback action) => ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        onTap: action,
      );
}

class _PandaSearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: PandaColors.background),
      );

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, ''),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final items = _dishes.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(
      children: items.map((item) => ListTile(title: Text(item.name), subtitle: Text('${item.price} ₸'))).toList(),
    );
  }
}
