import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/state_views.dart';
import 'package:unibite/core/widgets/unibite_logo.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/universities/domain/entities/campus.dart';
import 'package:unibite/features/universities/domain/entities/university.dart';
import 'package:uuid/uuid.dart';

/// Web-responsive administration dashboard for managing universities, campuses,
/// cafeterias, cafeteria owners, and platform user accounts.
class SystemAdminDashboardScreen extends ConsumerStatefulWidget {
  /// Creates a [SystemAdminDashboardScreen].
  const SystemAdminDashboardScreen({super.key});

  @override
  ConsumerState<SystemAdminDashboardScreen> createState() =>
      _SystemAdminDashboardScreenState();
}

class _SystemAdminDashboardScreenState
    extends ConsumerState<SystemAdminDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actor = ref.watch(currentUserProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    if (actor == null) {
      return const Scaffold(
        backgroundColor: AppColors.green50,
        body: SizedBox.shrink(),
      );
    }

    final destinations = [
      NavigationRailDestination(
        icon: const Icon(LucideIcons.graduationCap),
        label: Text(l10n.tabUniversities),
      ),
      NavigationRailDestination(
        icon: const Icon(LucideIcons.mapPin),
        label: Text(l10n.tabCampuses),
      ),
      NavigationRailDestination(
        icon: const Icon(LucideIcons.store),
        label: Text(l10n.tabCafeterias),
      ),
      NavigationRailDestination(
        icon: const Icon(LucideIcons.users),
        label: Text(l10n.tabUsers),
      ),
    ];

    final body = IndexedStack(
      index: _selectedTab,
      children: [
        _UniversitiesTab(actor: actor),
        _CampusesTab(actor: actor),
        _CafeteriasTab(actor: actor),
        _UsersTab(actor: actor),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const UniBiteLogo(size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${l10n.appTitle} — ${l10n.roleSystemAdmin}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (isWide) ...[
            StatusBadge(
              label: l10n.liveConnectedBadge,
              backgroundColor: UniBiteColors.primary100,
              textColor: UniBiteColors.primary700,
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: l10n.screenAwakeBadge,
              backgroundColor: UniBiteColors.primary50,
              textColor: UniBiteColors.inkMuted,
            ),
            const SizedBox(width: 6),
          ],
          IconButton(
            tooltip: l10n.languageLabel,
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
            icon: const Icon(LucideIcons.languages),
          ),
          IconButton(
            tooltip: l10n.logoutButton,
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(LucideIcons.logOut),
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedTab,
                  extended: MediaQuery.sizeOf(context).width >= 1120,
                  backgroundColor: UniBiteColors.primary900,
                  indicatorColor: UniBiteColors.secondary,
                  selectedIconTheme: const IconThemeData(
                    color: UniBiteColors.surface,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: UniBiteColors.primary100,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: UniBiteColors.surface,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: UniBiteColors.primary100,
                    fontWeight: FontWeight.w500,
                  ),
                  onDestinationSelected: (idx) =>
                      setState(() => _selectedTab = idx),
                  destinations: destinations,
                ),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedTab,
              onDestinationSelected: (idx) =>
                  setState(() => _selectedTab = idx),
              destinations: [
                NavigationDestination(
                  icon: const Icon(LucideIcons.graduationCap),
                  label: l10n.tabUniversities,
                ),
                NavigationDestination(
                  icon: const Icon(LucideIcons.mapPin),
                  label: l10n.tabCampuses,
                ),
                NavigationDestination(
                  icon: const Icon(LucideIcons.store),
                  label: l10n.tabCafeterias,
                ),
                NavigationDestination(
                  icon: const Icon(LucideIcons.users),
                  label: l10n.tabUsers,
                ),
              ],
            ),
    );
  }
}

class _UniversitiesTab extends ConsumerWidget {
  const _UniversitiesTab({required this.actor});

  final AppUser actor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final universitiesAsync = ref.watch(universitiesStreamProvider(false));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showUniversityDialog(context, ref),
        backgroundColor: UniBiteColors.secondary,
        foregroundColor: UniBiteColors.surface,
        icon: const Icon(LucideIcons.plus),
        label: Text(l10n.addUniversityButton),
      ),
      body: universitiesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (universities) {
          if (universities.isEmpty) {
            return EmptyStateView(
              icon: LucideIcons.graduationCap,
              title: l10n.tabUniversities,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            itemCount: universities.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final uni = universities[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: UniBiteColors.primary100,
                    child: Icon(
                      LucideIcons.graduationCap,
                      color: UniBiteColors.primary700,
                    ),
                  ),
                  title: Text(
                    uni.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: StatusBadge(
                        label: uni.isActive ? l10n.active : l10n.inactive,
                        backgroundColor: uni.isActive
                            ? UniBiteColors.primary100
                            : UniBiteColors.dangerSoft,
                        textColor: uni.isActive
                            ? UniBiteColors.primary700
                            : UniBiteColors.dangerText,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n.edit,
                        onPressed: () =>
                            _showUniversityDialog(context, ref, existing: uni),
                        icon: const Icon(LucideIcons.pencil),
                      ),
                      Switch(
                        value: uni.isActive,
                        onChanged: (value) async {
                          await ref
                              .read(universityRepositoryProvider)
                              .setUniversityActive(
                                id: uni.id,
                                isActive: value,
                                actor: actor,
                              );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showUniversityDialog(
    BuildContext context,
    WidgetRef ref, {
    University? existing,
  }) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? l10n.addUniversityButton : l10n.edit),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: l10n.universityNameLabel),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          UbPrimaryButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
            label: l10n.save,
          ),
        ],
      ),
    );

    if (saved == true) {
      final record = University(
        id: existing?.id ?? 'uni_${const Uuid().v4()}',
        name: nameCtrl.text.trim(),
        logo: existing?.logo ?? 'assets/images/logo.jpg',
        isActive: existing?.isActive ?? true,
      );
      await ref
          .read(universityRepositoryProvider)
          .saveUniversity(record, actor: actor);
    }
    nameCtrl.dispose();
  }
}

class _CampusesTab extends ConsumerStatefulWidget {
  const _CampusesTab({required this.actor});

  final AppUser actor;

  @override
  ConsumerState<_CampusesTab> createState() => _CampusesTabState();
}

class _CampusesTabState extends ConsumerState<_CampusesTab> {
  String? _filterUniversityId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final universities =
        ref.watch(universitiesStreamProvider(false)).valueOrNull ?? [];
    final campusesAsync = ref.watch(
      campusesStreamProvider((
        universityId: _filterUniversityId,
        activeOnly: false,
      )),
    );

    final uniNames = {for (final u in universities) u.id: u.name};

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: universities.isEmpty
            ? null
            : () => _showCampusDialog(context, universities),
        backgroundColor: UniBiteColors.secondary,
        foregroundColor: UniBiteColors.surface,
        icon: const Icon(LucideIcons.plus),
        label: Text(l10n.addCampusButton),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: DropdownButtonFormField<String?>(
              key: ValueKey('filter_uni_$_filterUniversityId'),
              initialValue: _filterUniversityId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.filterByUniversity,
                prefixIcon: const Icon(LucideIcons.filter),
              ),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text(l10n.all)),
                ...universities.map(
                  (u) => DropdownMenuItem<String?>(
                    value: u.id,
                    child: Text(u.name, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => _filterUniversityId = val),
            ),
          ),
          Expanded(
            child: campusesAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorStateView(message: e.toString()),
              data: (campuses) {
                if (campuses.isEmpty) {
                  return EmptyStateView(
                    icon: LucideIcons.mapPin,
                    title: l10n.tabCampuses,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                  itemCount: campuses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final campus = campuses[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: UniBiteColors.secondarySoft,
                          child: Icon(
                            LucideIcons.mapPin,
                            color: UniBiteColors.secondaryText,
                          ),
                        ),
                        title: Text(
                          campus.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${uniNames[campus.universityId] ?? campus.universityId}\n${campus.location}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l10n.edit,
                              onPressed: () => _showCampusDialog(
                                context,
                                universities,
                                existing: campus,
                              ),
                              icon: const Icon(LucideIcons.pencil),
                            ),
                            Switch(
                              value: campus.isActive,
                              onChanged: (val) async {
                                await ref
                                    .read(universityRepositoryProvider)
                                    .setCampusActive(
                                      id: campus.id,
                                      isActive: val,
                                      actor: widget.actor,
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCampusDialog(
    BuildContext context,
    List<University> universities, {
    Campus? existing,
  }) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    String uniId =
        existing?.universityId ?? _filterUniversityId ?? universities.first.id;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final locCtrl = TextEditingController(text: existing?.location ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text(existing == null ? l10n.addCampusButton : l10n.edit),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: uniId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.selectUniversityLabel,
                    ),
                    items: universities
                        .map(
                          (u) => DropdownMenuItem<String>(
                            value: u.id,
                            child: Text(
                              u.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => uniId = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.campusNameLabel,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.campusLocationLabel,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            UbPrimaryButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop(true);
                }
              },
              label: l10n.save,
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      final record = Campus(
        id: existing?.id ?? 'camp_${const Uuid().v4()}',
        universityId: uniId,
        name: nameCtrl.text.trim(),
        location: locCtrl.text.trim(),
        isActive: existing?.isActive ?? true,
      );
      await ref
          .read(universityRepositoryProvider)
          .saveCampus(record, actor: widget.actor);
    }
    nameCtrl.dispose();
    locCtrl.dispose();
  }
}

class _CafeteriasTab extends ConsumerWidget {
  const _CafeteriasTab({required this.actor});

  final AppUser actor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cafeteriasAsync = ref.watch(
      cafeteriasStreamProvider((campusId: null, activeOnly: false)),
    );
    final campuses =
        ref
            .watch(
              campusesStreamProvider((universityId: null, activeOnly: false)),
            )
            .valueOrNull ??
        [];
    final universities =
        ref.watch(universitiesStreamProvider(false)).valueOrNull ?? [];
    final users =
        ref.watch(usersStreamProvider((cafeteriaId: null))).valueOrNull ?? [];

    final campusMap = {for (final c in campuses) c.id: c};
    final uniMap = {for (final u in universities) u.id: u};
    final userMap = {for (final u in users) u.id: u};

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: campuses.isEmpty
            ? null
            : () => _showCreateCafeteriaDialog(
                context,
                ref,
                universities,
                campuses,
              ),
        backgroundColor: UniBiteColors.secondary,
        foregroundColor: UniBiteColors.surface,
        icon: const Icon(LucideIcons.plus),
        label: Text(l10n.addCafeteriaButton),
      ),
      body: cafeteriasAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (cafeterias) {
          if (cafeterias.isEmpty) {
            return EmptyStateView(
              icon: LucideIcons.store,
              title: l10n.tabCafeterias,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            itemCount: cafeterias.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cafe = cafeterias[index];
              final campus = campusMap[cafe.campusId];
              final uni = uniMap[cafe.universityId];
              final owner = userMap[cafe.ownerId];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: UniBiteColors.primary100,
                        child: Icon(
                          LucideIcons.store,
                          color: UniBiteColors.primary700,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cafe.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${uni?.name ?? cafe.universityId} • ${campus?.name ?? cafe.campusId}',
                              style: const TextStyle(
                                color: UniBiteColors.inkMuted,
                              ),
                            ),
                            Text(
                              '${owner?.name ?? cafe.ownerId} (${owner?.email ?? ''}) • ${cafe.workingHours}',
                              style: const TextStyle(
                                color: UniBiteColors.inkMuted,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge(
                            label: cafe.isActive ? l10n.active : l10n.suspended,
                            backgroundColor: cafe.isActive
                                ? UniBiteColors.primary100
                                : UniBiteColors.dangerSoft,
                            textColor: cafe.isActive
                                ? UniBiteColors.primary700
                                : UniBiteColors.dangerText,
                          ),
                          Switch(
                            value: cafe.isActive,
                            onChanged: (val) async {
                              await ref
                                  .read(cafeteriaRepositoryProvider)
                                  .setCafeteriaActive(
                                    id: cafe.id,
                                    isActive: val,
                                    actor: actor,
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateCafeteriaDialog(
    BuildContext context,
    WidgetRef ref,
    List<University> universities,
    List<Campus> campuses,
  ) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    String selectedUniId = universities.first.id;
    List<Campus> matchingCampuses = campuses
        .where((c) => c.universityId == selectedUniId)
        .toList();
    String selectedCampusId = matchingCampuses.isNotEmpty
        ? matchingCampuses.first.id
        : campuses.first.id;

    final cafeNameCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: '08:00-22:00');
    final ownerNameCtrl = TextEditingController();
    final ownerEmailCtrl = TextEditingController();
    final ownerPassCtrl = TextEditingController(text: 'Cafe@123');
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final uniCampuses = campuses
              .where((c) => c.universityId == selectedUniId)
              .toList();
          if (uniCampuses.isNotEmpty &&
              !uniCampuses.any((c) => c.id == selectedCampusId)) {
            selectedCampusId = uniCampuses.first.id;
          }

          return AlertDialog(
            title: Text(l10n.addCafeteriaButton),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dialogError != null) ...[
                        Text(
                          dialogError!,
                          style: const TextStyle(
                            color: UniBiteColors.dangerText,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      DropdownButtonFormField<String>(
                        initialValue: selectedUniId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.selectUniversityLabel,
                        ),
                        items: universities
                            .map(
                              (u) => DropdownMenuItem<String>(
                                value: u.id,
                                child: Text(
                                  u.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() => selectedUniId = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          'dlg_campus_${selectedUniId}_$selectedCampusId',
                        ),
                        initialValue: selectedCampusId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.selectCampusLabel,
                        ),
                        items: uniCampuses
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c.id,
                                child: Text(
                                  c.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() => selectedCampusId = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cafeNameCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.cafeteriaNameLabel,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: hoursCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.workingHoursTitle,
                          hintText: '08:00-22:00',
                        ),
                        validator: (v) =>
                            Cafeteria.parseWorkingHours(v ?? '') == null
                            ? 'HH:mm-HH:mm'
                            : null,
                      ),
                      const Divider(height: 24),
                      TextFormField(
                        controller: ownerNameCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.ownerNameLabel,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ownerEmailCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.ownerEmailLabel,
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? l10n.invalidEmail
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ownerPassCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.ownerPasswordLabel,
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? l10n.passwordTooShort
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.cancel),
              ),
              UbPrimaryButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  try {
                    final cafeId = 'cafe_${const Uuid().v4()}';
                    final owner = await ref
                        .read(userRepositoryProvider)
                        .createCafeteriaAdmin(
                          name: ownerNameCtrl.text,
                          email: ownerEmailCtrl.text,
                          password: ownerPassCtrl.text,
                          universityId: selectedUniId,
                          campusId: selectedCampusId,
                          cafeteriaId: cafeId,
                          actor: actor,
                        );
                    final cafe = Cafeteria(
                      id: cafeId,
                      universityId: selectedUniId,
                      campusId: selectedCampusId,
                      name: cafeNameCtrl.text.trim(),
                      logo: 'assets/images/logo.jpg',
                      workingHours: hoursCtrl.text.trim(),
                      isActive: true,
                      ownerId: owner.id,
                    );
                    await ref
                        .read(cafeteriaRepositoryProvider)
                        .saveCafeteria(cafe, actor: actor);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  } on AppException catch (e) {
                    setModalState(() => dialogError = e.message);
                  }
                },
                label: l10n.save,
              ),
            ],
          );
        },
      ),
    );

    cafeNameCtrl.dispose();
    hoursCtrl.dispose();
    ownerNameCtrl.dispose();
    ownerEmailCtrl.dispose();
    ownerPassCtrl.dispose();
  }
}

class _UsersTab extends ConsumerStatefulWidget {
  const _UsersTab({required this.actor});

  final AppUser actor;

  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  UserRole? _roleFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final usersAsync = ref.watch(usersStreamProvider((cafeteriaId: null)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: DropdownButtonFormField<UserRole?>(
            key: ValueKey('role_filter_$_roleFilter'),
            initialValue: _roleFilter,
            decoration: InputDecoration(
              labelText: l10n.filterByRole,
              prefixIcon: const Icon(LucideIcons.filter),
            ),
            items: [
              DropdownMenuItem<UserRole?>(
                value: null,
                child: Text(l10n.allRoles),
              ),
              ...UserRole.values.map(
                (r) => DropdownMenuItem<UserRole?>(
                  value: r,
                  child: Text(l10n.roleLabel(r)),
                ),
              ),
            ],
            onChanged: (role) => setState(() => _roleFilter = role),
          ),
        ),
        Expanded(
          child: usersAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorStateView(message: e.toString()),
            data: (allUsers) {
              final users = _roleFilter == null
                  ? allUsers
                  : allUsers.where((u) => u.role == _roleFilter).toList();
              if (users.isEmpty) {
                return EmptyStateView(
                  icon: LucideIcons.users,
                  title: l10n.tabUsers,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: UniBiteColors.primary100,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: UniBiteColors.primary700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${user.email} • ${l10n.roleLabel(user.role)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusBadge(
                            label: user.isActive ? l10n.active : l10n.inactive,
                            backgroundColor: user.isActive
                                ? UniBiteColors.primary100
                                : UniBiteColors.dangerSoft,
                            textColor: user.isActive
                                ? UniBiteColors.primary700
                                : UniBiteColors.dangerText,
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: user.isActive,
                            onChanged: user.id == widget.actor.id
                                ? null
                                : (val) async {
                                    await ref
                                        .read(userRepositoryProvider)
                                        .setUserActive(
                                          userId: user.id,
                                          isActive: val,
                                          actor: widget.actor,
                                        );
                                  },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
