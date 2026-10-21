import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';
import '../providers/company_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/common.dart';
import '../widgets/company_card.dart';
import 'create_company_screen.dart';
import 'create_service_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final _carousel = ScrollController();
  int? _selectedId;

  @override
  void dispose() {
    _carousel.dispose();
    super.dispose();
  }

  Company? _selected(List<Company> companies) {
    if (companies.isEmpty) return null;
    return companies.firstWhere((c) => c.id == _selectedId, orElse: () => companies.first);
  }

  Future<void> _openCreateCompany() async {
    final company = await Navigator.of(context).push<Company>(
      softRoute(const CreateCompanyScreen()),
    );
    if (company == null || !mounted) return;

    // Company baru masuk depan, so select terus & scroll balik ke awal 
    setState(() => _selectedId = company.id);
    if (_carousel.hasClients) {
      _carousel.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
    }
  }

  void _openCreateService({int? companyId}) {
    Navigator.of(context).push(softRoute(CreateServiceScreen(initialCompanyId: companyId)));
  }

  void _onNavigate(NavItem item) {
    switch (item) {
      case NavItem.companies:
        break;
      case NavItem.newCompany:
        _openCreateCompany();
      case NavItem.newService:
        _openCreateService(companyId: _selectedId);
    }
  }

  void _scrollCarousel(int direction) {
    if (!_carousel.hasClients) return;
    final target = (_carousel.offset + direction * (CompanyTile.width + 24) * 2)
        .clamp(0.0, _carousel.position.maxScrollExtent);
    _carousel.animateTo(target, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyProvider>();

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.pinkDeep,
        onRefresh: provider.fetchCompanies,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: TopBar(
                  current: NavItem.companies,
                  onNavigate: _onNavigate,
                  trailing: IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: provider.isLoading ? null : provider.fetchCompanies,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _Hero()),
            SliverToBoxAdapter(child: _Intro(onAddCompany: _openCreateCompany)),
            ..._buildCompanies(provider),
            const SliverToBoxAdapter(child: _Footer()),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCompanies(CompanyProvider provider) {
    final companies = provider.companies;

    if (provider.isLoading && companies.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: _PinkBand(
            child: SizedBox(
              height: 320,
              child: Center(child: SphereLoader(label: 'Loading companies', light: true)),
            ),
          ),
        ),
      ];
    }

    if (provider.error != null && companies.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: MessageView(
            title: 'Oops, something went wrong',
            message: provider.error!,
            actionLabel: 'Try again',
            onAction: provider.fetchCompanies,
          ),
        ),
      ];
    }

    if (companies.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: MessageView(
            title: 'No companies yet',
            message: 'Add your first company to get started.',
            actionLabel: 'Add company',
            onAction: _openCreateCompany,
          ),
        ),
      ];
    }

    final selected = _selected(companies)!;
    return [
      // Refresh fail tapi list lama still ada, so tunjuk je yang lama, jangan kosongkan
      if (provider.error != null)
        SliverToBoxAdapter(child: _ErrorBanner(message: provider.error!)),
      SliverToBoxAdapter(
        child: _PinkBand(
          child: _CompanyCarousel(
            companies: companies,
            selectedId: selected.id,
            controller: _carousel,
            onSelect: (company) => setState(() => _selectedId = company.id),
            onScroll: _scrollCarousel,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: _ServicesSection(
          company: selected,
          onAddService: () => _openCreateService(companyId: selected.id),
        ),
      ),
    ];
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final sphere = (width * 0.24).clamp(110.0, 280.0);
        final height = (width * 0.34).clamp(220.0, 440.0);

        return SizedBox(
          height: height,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: FadeSlideIn(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Juara inovasi pasifik Sdn Bhd',
                          style: AppFonts.display(
                            size: 120,
                            weight: FontWeight.w400,
                            height: 1,
                            letterSpacing: -5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                offset: 60,
                child: Floating(child: GlossySphere(size: sphere)),
              ),
              Positioned(
                left: width / 2 - sphere * 0.85,
                top: height * 0.1,
                child: Floating(
                  phase: 0.4,
                  amplitude: 8,
                  child: GlossySphere(size: sphere * 0.32, chrome: true),
                ),
              ),
              Positioned(
                right: width / 2 - sphere * 0.75,
                bottom: height * 0.08,
                child: Floating(
                  phase: 0.7,
                  amplitude: 10,
                  child: GlossySphere(size: sphere * 0.18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onAddCompany});

  final VoidCallback onAddCompany;

  @override
  Widget build(BuildContext context) {
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: AppFonts.body(color: AppColors.grey)),
        Text('Full stack assignment', style: AppFonts.body(weight: FontWeight.w600)),
      ],
    );
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Every company and the services it offers, all in one place.',
          style: AppFonts.display(size: 14, height: 1.5),
        ),
        const SizedBox(height: 20),
        PillButton(label: 'Add company', onPressed: onAddCompany),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 720
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Expanded(child: left), SizedBox(width: 420, child: right)],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [left, const SizedBox(height: 20), right],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinkBand extends StatelessWidget {
  const _PinkBand({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.pink,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: child,
    );
  }
}

class _CompanyCarousel extends StatelessWidget {
  const _CompanyCarousel({
    required this.companies,
    required this.selectedId,
    required this.controller,
    required this.onSelect,
    required this.onScroll,
  });

  final List<Company> companies;
  final int selectedId;
  final ScrollController controller;
  final void Function(Company company) onSelect;
  final void Function(int direction) onScroll;

  static const _gap = 24.0;
  static const _height = 330.0;

  @override
  Widget build(BuildContext context) {
    final serviceCount = companies.fold<int>(0, (sum, c) => sum + c.services.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final faded = AppFonts.display(size: 14, color: Colors.white.withValues(alpha: 0.55));
        final title = Text(
          'COMPANIES',
          style: AppFonts.display(size: wide ? 30 : 24, color: Colors.white, letterSpacing: 1),
        );

        Widget tile(int i) {
          final company = companies[i];
          return FadeSlideIn(
            key: ValueKey(company.id),
            delay: Duration(milliseconds: 80 * math.min(i, 6)),
            child: CompanyTile(
              company: company,
              selected: company.id == selectedId,
              onTap: () => onSelect(company),
            ),
          );
        }

        // letak tengah; kalau tak muat baru boleh scroll
        final sidePadding = wide ? 16.0 : 24.0;
        final arrowsWidth = wide ? 2 * (44 + 24) : 0;
        final available = constraints.maxWidth - arrowsWidth - 2 * sidePadding;
        final contentWidth = companies.length * CompanyTile.width + (companies.length - 1) * _gap;
        final fits = contentWidth <= available;

        final cards = fits
            ? Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < companies.length; i++) ...[
                      if (i > 0) const SizedBox(width: _gap),
                      tile(i),
                    ],
                  ],
                ),
              )
            : ScrollConfiguration(
                // Flutter tak bagi mouse drag by default, so kena on manual untuk web & desktop
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: ListView.separated(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  itemCount: companies.length,
                  separatorBuilder: (context, index) => const SizedBox(width: _gap),
                  itemBuilder: (context, i) => tile(i),
                ),
              );

        return Column(
          children: [
            if (wide)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$serviceCount services', style: faded),
                  const SizedBox(width: 32),
                  title,
                  const SizedBox(width: 32),
                  Text('newest first', style: faded),
                ],
              )
            else ...[
              title,
              const SizedBox(height: 6),
              Text('$serviceCount services · newest first', style: faded.copyWith(fontSize: 11)),
            ],
            const SizedBox(height: 40),
            Row(
              children: [
                if (wide && !fits)
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: ArrowCircle(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Previous',
                      onPressed: () => onScroll(-1),
                    ),
                  ),
                Expanded(child: SizedBox(height: _height, child: cards)),
                if (wide && !fits)
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: ArrowCircle(
                      icon: Icons.arrow_forward_rounded,
                      tooltip: 'Next',
                      onPressed: () => onScroll(1),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.company, required this.onAddService});

  final Company company;
  final VoidCallback onAddService;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Services', style: AppFonts.display(size: 26)),
        const SizedBox(height: 6),
        Text(
          'at ${company.name} · ${company.registrationNumber}',
          style: AppFonts.body(color: AppColors.grey),
        ),
      ],
    );
    final addButton = PillButton(label: 'Add service', onPressed: onAddService);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1000 ? 3 : (width >= 620 ? 2 : 1);
              const spacing = 20.0;
              final itemWidth = (width - spacing * (columns - 1)) / columns;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (width >= 620)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [Expanded(child: heading), addButton],
                    )
                  else ...[
                    heading,
                    const SizedBox(height: 20),
                    addButton,
                  ],
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(company.id),
                      child: company.services.isEmpty
                          ? const _EmptyServices()
                          : Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                for (final (i, service) in company.services.indexed)
                                  SizedBox(
                                    key: ValueKey(service.id),
                                    width: itemWidth,
                                    child: FadeSlideIn(
                                      delay: Duration(milliseconds: 70 * math.min(i, 8)),
                                      child: ServiceCard(service: service),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyServices extends StatelessWidget {
  const _EmptyServices();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.pinkMist,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No services yet', style: AppFonts.display(size: 15)),
          const SizedBox(height: 6),
          Text(
            'Add the first service this company offers.',
            style: AppFonts.body(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: AppFonts.body(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sphere = (constraints.maxWidth * 0.12).clamp(50.0, 140.0);

              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text('VISTA', style: AppFonts.brand(size: 200, color: AppColors.pink)),
                        ),
                      ),
                      Positioned(
                        right: constraints.maxWidth * 0.06,
                        top: -sphere * 0.3,
                        child: Floating(
                          phase: 0.25,
                          child: GlossySphere(size: sphere, chrome: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Vista technical test', style: AppFonts.body(size: 10, color: AppColors.grey)),
                      Text('Built with Flutter', style: AppFonts.body(size: 10, color: AppColors.grey)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
