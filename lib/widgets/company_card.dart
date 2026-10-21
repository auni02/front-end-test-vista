import 'package:flutter/material.dart';

import '../models/company.dart';
import '../models/service.dart';
import '../theme/app_theme.dart';
import 'animations.dart';
import 'common.dart';

class CompanyTile extends StatefulWidget {
  const CompanyTile({
    super.key,
    required this.company,
    required this.selected,
    required this.onTap,
  });

  static const width = 220.0;

  final Company company;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<CompanyTile> createState() => _CompanyTileState();
}

class _CompanyTileState extends State<CompanyTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    final selected = widget.selected;
    final name = company.name.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    final count = company.services.length;
    const duration = Duration(milliseconds: 300);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: selected ? 1 : (_hovered ? 0.98 : 0.94),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: selected || _hovered ? 1 : 0.8,
            duration: duration,
            child: SizedBox(
              width: CompanyTile.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: duration,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: selected ? 0.42 : 0.25),
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: selected ? 0.9 : 0),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 16,
                          child: _Chip(label: '$count ${count == 1 ? 'SERVICE' : 'SERVICES'}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Floating(
                            amplitude: 6,
                            phase: (company.id % 7) / 7,
                            child: GlossySphere(
                              size: 120,
                              child: Text(initial, style: AppFonts.brand(size: 52, color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.display(size: 13, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              company.registrationNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body(
                                size: 10,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PillButton(
                        label: selected ? 'Viewing' : 'View',
                        light: true,
                        compact: true,
                        onPressed: widget.onTap,
                      ),
                    ],
                  ),
                  if (count > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      company.services.map((s) => s.name).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(size: 10, color: Colors.white.withValues(alpha: 0.75)),
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: AppFonts.display(size: 9, color: Colors.white, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  const ServiceCard({super.key, required this.service});

  final Service service;

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.pinkMist,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.pinkDeep.withValues(alpha: _hovered ? 0.18 : 0),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.pinkDeep),
                  ),
                  child: Text(
                    'SERVICE',
                    style: AppFonts.display(size: 9, color: AppColors.pinkDeep, letterSpacing: 1),
                  ),
                ),
                const Spacer(),
                Text(
                  'RM ${service.price.toStringAsFixed(2)}',
                  style: AppFonts.display(size: 15, color: AppColors.pinkDeep),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(service.name, style: AppFonts.display(size: 16)),
            const SizedBox(height: 8),
            Text(
              service.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(size: 11, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
