import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Visual replica of Panda's push-style side navigation.
/// The underlying page is translated (not resized) and dimmed.
enum PandaMenuEntry {
  profile,
  language,
  catalog,
  cart,
  about,
  orders,
  messages,
  review,
  promotions,
  telegram,
  instagram,
  vacancies,
  offer,
  privacy,
}

class PandaSideMenu extends StatefulWidget {
  const PandaSideMenu({
    super.key,
    required this.child,
    required this.onSelect,
  });

  final Widget child;
  final ValueChanged<PandaMenuEntry> onSelect;

  static PandaSideMenuState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<PandaSideMenuState>();

  @override
  State<PandaSideMenu> createState() => PandaSideMenuState();
}

class PandaSideMenuState extends State<PandaSideMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 315),
    reverseDuration: const Duration(milliseconds: 295),
  );

  bool _isOpen = false;
  bool _darkMenu = true;
  bool _languageExpanded = false;

  void open() {
    if (_isOpen) return;
    setState(() => _isOpen = true);
    _animation.animateTo(1, curve: Curves.easeOutCubic);
  }

  void close() {
    if (!_isOpen && _animation.value <= 0) return;
    _animation.animateBack(0, curve: Curves.easeInOutCubic).then((_) {
      if (mounted && _animation.value == 0) {
        setState(() => _isOpen = false);
      }
    });
  }

  void _onDragUpdate(DragUpdateDetails details, double drawerWidth) {
    _animation.value =
        (_animation.value + details.delta.dx / drawerWidth).clamp(0.0, 1.0);
    final nowOpen = _animation.value > 0;
    if (nowOpen != _isOpen) setState(() => _isOpen = nowOpen);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -320) {
      close();
    } else if (velocity > 320 || _animation.value > 0.45) {
      open();
      _animation.animateTo(1, curve: Curves.easeOutCubic);
    } else {
      close();
    }
  }

  void _select(PandaMenuEntry entry) {
    if (entry == PandaMenuEntry.language) {
      setState(() => _languageExpanded = !_languageExpanded);
      return;
    }
    _animation.animateBack(0, curve: Curves.easeInOutCubic).then((_) {
      if (!mounted) return;
      setState(() => _isOpen = false);
      widget.onSelect(entry);
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final drawerWidth = width * 0.76;

    return PopScope(
      canPop: !_isOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isOpen) close();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final progress = _animation.value;
          return ClipRect(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: _darkMenu
                        ? const Color(0xFF202020)
                        : const Color(0xFFF6F6F6),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: drawerWidth,
                  child: Transform.translate(
                    offset: Offset(-drawerWidth * 0.12 * (1 - progress), 0),
                    child: _PandaMenuContents(
                      dark: _darkMenu,
                      languageExpanded: _languageExpanded,
                      onToggleTheme: () =>
                          setState(() => _darkMenu = !_darkMenu),
                      onTapEntry: _select,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(drawerWidth * progress, 0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            boxShadow: progress > 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.38 * progress,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(-6, 0),
                                    ),
                                  ]
                                : const [],
                          ),
                          child: widget.child,
                        ),
                        if (progress > 0.001)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: close,
                            onHorizontalDragUpdate: (details) =>
                                _onDragUpdate(details, drawerWidth),
                            onHorizontalDragEnd: _onDragEnd,
                            child: ColoredBox(
                              color: Colors.black.withValues(
                                alpha: math.min(0.55, 0.52 * progress),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (progress == 0)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    width: 12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) =>
                          _onDragUpdate(details, drawerWidth),
                      onHorizontalDragEnd: _onDragEnd,
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

class _PandaMenuContents extends StatelessWidget {
  const _PandaMenuContents({
    required this.dark,
    required this.languageExpanded,
    required this.onToggleTheme,
    required this.onTapEntry,
  });

  final bool dark;
  final bool languageExpanded;
  final VoidCallback onToggleTheme;
  final ValueChanged<PandaMenuEntry> onTapEntry;

  Color get _text => dark ? Colors.white : const Color(0xFF202020);
  Color get _icon => dark ? const Color(0xFF696969) : const Color(0xFF858585);
  Color get _secondary => dark ? const Color(0xFF909090) : const Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark ? const Color(0xFF202020) : const Color(0xFFF6F6F6),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 21, right: 4, top: 27, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onToggleTheme,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 55,
                    height: 33,
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF424242)
                          : const Color(0xFFD5D5D5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: dark ? 6 : null,
                          right: dark ? null : 6,
                          top: 4,
                          child: Icon(
                            dark ? Icons.nightlight_outlined : Icons.wb_sunny_outlined,
                            size: 24,
                            color: dark ? Colors.white : const Color(0xFF333333),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          left: dark ? 28 : 3,
                          top: 3,
                          child: Container(
                            width: 27,
                            height: 27,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                _item(Icons.account_circle_outlined, 'Профиль', PandaMenuEntry.profile),
                _item(
                  Icons.language_outlined,
                  'Русский',
                  PandaMenuEntry.language,
                  trailing: Icon(
                    languageExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 19,
                    color: _text,
                  ),
                ),
                if (languageExpanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 47),
                    child: TextButton(
                      onPressed: () => onTapEntry(PandaMenuEntry.language),
                      child: Text('Русский', style: TextStyle(color: _secondary)),
                    ),
                  ),
                _item(Icons.article_outlined, 'Меню', PandaMenuEntry.catalog),
                _item(Icons.shopping_cart_outlined, 'Корзина', PandaMenuEntry.cart),
                _item(Icons.storefront_outlined, 'О нас', PandaMenuEntry.about),
                _item(Icons.inventory_2_outlined, 'История заказов', PandaMenuEntry.orders),
                _item(
                  Icons.campaign_outlined,
                  'Сообщения',
                  PandaMenuEntry.messages,
                  badge: '5',
                ),
                _item(Icons.rate_review_outlined, 'Написать отзыв', PandaMenuEntry.review),
                _item(Icons.local_offer_outlined, 'Акции', PandaMenuEntry.promotions),
                _item(Icons.send_outlined, 'Мы в Telegram', PandaMenuEntry.telegram),
                _item(Icons.camera_alt_outlined, 'Мы в Instagram', PandaMenuEntry.instagram),
                _item(Icons.info_outline, 'Вакансии', PandaMenuEntry.vacancies),
                const SizedBox(height: 16),
                _legal('Публичный\nдоговор оферты', PandaMenuEntry.offer),
                const SizedBox(height: 12),
                _legal('Политика\nконфиденциальности', PandaMenuEntry.privacy),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.only(left: 46),
                  child: Text(
                    'Приложение работает',
                    style: TextStyle(fontSize: 12, color: _secondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String label,
    PandaMenuEntry entry, {
    Widget? trailing,
    String? badge,
  }) {
    return SizedBox(
      height: 51.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTapEntry(entry),
          child: Row(
            children: [
              SizedBox(
                width: 46,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 27,
                    height: 29,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(child: Icon(icon, size: 24, color: _icon)),
                        if (badge != null)
                          Positioned(
                            right: -9,
                            top: -5,
                            child: Container(
                              height: 19,
                              constraints: const BoxConstraints(minWidth: 19),
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE45143),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  fontFamily: 'GolosText',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'GolosText',
                  fontSize: 16.5,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: _text,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _legal(String label, PandaMenuEntry entry) => Padding(
        padding: const EdgeInsets.only(left: 46),
        child: InkWell(
          onTap: () => onTapEntry(entry),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'GolosText',
                fontSize: 12.5,
                height: 1.3,
                color: _secondary,
              ),
            ),
          ),
        ),
      );
}
