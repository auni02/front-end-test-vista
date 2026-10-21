import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animations.dart';

class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.light = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  final bool light;

  final bool compact;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final active = _hovered && enabled;
    final background = widget.light ? Colors.white : AppColors.pinkDeep;
    final foreground = widget.light ? AppColors.pinkDeep : Colors.white;
    final hoverBackground = widget.light ? AppColors.pinkMist : const Color(0xFFC25A7B);
    final height = widget.compact ? 32.0 : 46.0;
    const duration = Duration(milliseconds: 200);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTap: enabled ? widget.onPressed : null,
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1,
            duration: const Duration(milliseconds: 120),
            child: AnimatedOpacity(
              opacity: widget.onPressed == null ? 0.5 : 1,
              duration: duration,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: duration,
                    height: height,
                    padding: EdgeInsets.symmetric(horizontal: widget.compact ? 16 : 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? hoverBackground : background,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: AnimatedSwitcher(
                      duration: duration,
                      child: widget.isLoading
                          ? SizedBox(
                              key: const ValueKey('loading'),
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
                            )
                          : Text(
                              widget.label,
                              key: const ValueKey('label'),
                              style: AppFonts.display(
                                size: widget.compact ? 10 : 12,
                                weight: FontWeight.w500,
                                color: foreground,
                              ),
                            ),
                    ),
                  ),
                  if (!widget.compact) ...[
                    const SizedBox(width: 4),
                    AnimatedSlide(
                      offset: active ? const Offset(0.15, 0) : Offset.zero,
                      duration: duration,
                      child: AnimatedContainer(
                        duration: duration,
                        width: height,
                        height: height,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active ? background : Colors.transparent,
                          border: Border.all(color: background, width: 1.5),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: active ? foreground : background,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArrowCircle extends StatefulWidget {
  const ArrowCircle({super.key, required this.icon, required this.onPressed, this.tooltip});

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  State<ArrowCircle> createState() => _ArrowCircleState();
}

class _ArrowCircleState extends State<ArrowCircle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? '',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: _hovered ? 0.9 : 0.25),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: _hovered ? AppColors.pinkDeep : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

enum NavItem { companies, newCompany, newService }

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.current, required this.onNavigate, this.trailing});

  final NavItem current;
  final void Function(NavItem item) onNavigate;
  final Widget? trailing;

  static const _labels = {
    NavItem.companies: 'Companies',
    NavItem.newCompany: 'New company',
    NavItem.newService: 'New service',
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Row(
            crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: wide
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final item in NavItem.values)
                              _NavLink(
                                label: _labels[item]!,
                                active: item == current,
                                onTap: () => onNavigate(item),
                              ),
                          ],
                        )
                      : PopupMenuButton<NavItem>(
                          tooltip: 'Menu',
                          icon: const Icon(Icons.menu_rounded),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onSelected: onNavigate,
                          itemBuilder: (context) => [
                            for (final item in NavItem.values)
                              PopupMenuItem(
                                value: item,
                                child: Text(
                                  _labels[item]!,
                                  style: AppFonts.body(
                                    color: item == current ? AppColors.pinkDeep : AppColors.ink,
                                    weight: item == current ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onNavigate(NavItem.companies),
                  child: Text('VISTA', style: AppFonts.brand(size: 30)),
                ),
              ),
              Expanded(
                child: Align(alignment: Alignment.centerRight, child: trailing),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppFonts.body(
                  size: 12,
                  color: highlighted ? AppColors.pinkDeep : AppColors.ink,
                  weight: widget.active ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(widget.label),
              ),
              AnimatedScale(
                scale: widget.active ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(color: AppColors.pinkDeep, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_rounded, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeSlideIn(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Floating(child: GlossySphere(size: 88)),
                const SizedBox(height: 32),
                Text(title, textAlign: TextAlign.center, style: AppFonts.display(size: 20)),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(color: AppColors.grey),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 28),
                  PillButton(label: actionLabel!, onPressed: onAction),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showCuteSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.error : AppColors.ink,
        content: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isError ? Colors.white : AppColors.pink,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.current,
    required this.onNavigate,
    required this.eyebrow,
    required this.heading,
    required this.description,
    required this.child,
  });

  final NavItem current;
  final void Function(NavItem item) onNavigate;
  final String eyebrow;
  final String heading;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TopBar(
                current: current,
                onNavigate: onNavigate,
                trailing: IconButton(
                  tooltip: 'Back to companies',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => onNavigate(NavItem.companies),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 64),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 860;
                        final intro = _FormIntro(
                          eyebrow: eyebrow,
                          heading: heading,
                          description: description,
                          wide: wide,
                        );
                        final form = FadeSlideIn(
                          delay: const Duration(milliseconds: 150),
                          child: child,
                        );

                        return wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: intro),
                                  const SizedBox(width: 64),
                                  SizedBox(width: 440, child: form),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [intro, const SizedBox(height: 40), form],
                              );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormIntro extends StatelessWidget {
  const _FormIntro({
    required this.eyebrow,
    required this.heading,
    required this.description,
    required this.wide,
  });

  final String eyebrow;
  final String heading;
  final String description;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final sphere = wide ? 96.0 : 60.0;

    return FadeSlideIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: AppFonts.body(color: AppColors.grey)),
          const SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(right: sphere * 0.5),
                child: Text(
                  heading,
                  style: AppFonts.display(
                    size: wide ? 64 : 40,
                    weight: FontWeight.w400,
                    height: 1.05,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: -sphere * 0.2,
                child: Floating(child: GlossySphere(size: sphere)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(description, style: AppFonts.body(weight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
