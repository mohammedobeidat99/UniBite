import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/database/seed_data.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/meal_image_widget.dart';
import 'package:unibite/core/widgets/state_views.dart';
import 'package:unibite/core/widgets/unibite_logo.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/orders/presentation/live_order_board_widget.dart';
import 'package:unibite/features/orders/presentation/qr_lookup_view.dart';
import 'package:unibite/features/orders/presentation/walk_in_order_view.dart';
import 'package:uuid/uuid.dart';

/// Web-responsive dashboard for Cafeteria Admins owning a single cafeteria.
class CafeteriaAdminDashboardScreen extends ConsumerStatefulWidget {
  /// Creates a [CafeteriaAdminDashboardScreen].
  const CafeteriaAdminDashboardScreen({super.key});

  @override
  ConsumerState<CafeteriaAdminDashboardScreen> createState() =>
      _CafeteriaAdminDashboardScreenState();
}

class _CafeteriaAdminDashboardScreenState
    extends ConsumerState<CafeteriaAdminDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actor = ref.watch(currentUserProvider);
    if (actor == null || actor.cafeteriaId == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final cafeteriaId = actor.cafeteriaId!;
    final cafeAsync = ref.watch(cafeteriaByIdStreamProvider(cafeteriaId));
    final cafe = cafeAsync.valueOrNull;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final body = IndexedStack(
      index: _selectedTab,
      children: [
        LiveOrderBoardWidget(
          cafeteriaId: cafeteriaId,
          actor: actor,
          onCreateWalkIn: () => setState(() => _selectedTab = 4),
        ),
        _MenuManagerTab(cafeteriaId: cafeteriaId, actor: actor),
        _WorkingHoursTab(cafeteriaId: cafeteriaId, actor: actor),
        _StaffAccountsTab(cafeteriaId: cafeteriaId, actor: actor),
        WalkInOrderView(cafeteriaId: cafeteriaId, actor: actor),
        QrLookupView(cafeteriaId: cafeteriaId, actor: actor),
        _OrderHistoryTab(cafeteriaId: cafeteriaId),
      ],
    );

    final railDestinations = [
      NavigationRailDestination(
        icon: const Icon(LucideIcons.layoutDashboard),
        label: Text(l10n.tabLiveBoard),
      ),
      NavigationRailDestination(
        icon: const Icon(LucideIcons.utensils),
        label: Text(l10n.tabMenuManager),
      ),
      NavigationRailDestination(
        icon: const Icon(LucideIcons.clock),
        label: Text(l10n.tabWorkingHours),
      ),
      NavigationRailDestination(
        icon: const Icon(LucideIcons.badgeCheck),
        label: Text(l10n.tabStaffAccounts),
      ),
      NavigationRailDestination(
        icon: const Icon(LucideIcons.receipt),
        label: Text(l10n.tabWalkInOrder),
      ),
      NavigationRailDestination(
        icon: const Icon(LucideIcons.qrCode),
        label: Text(l10n.tabQrLookup),
      ),
      NavigationRailDestination(
        icon: const Icon(LucideIcons.history),
        label: Text(l10n.tabOrderHistory),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const UniBiteLogo(size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${cafe?.name ?? l10n.appTitle} — ${l10n.roleCafeteriaAdmin}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (cafe != null && isWide) ...[
            UbOpenClosedPill(isOpen: cafe.isOpenAt(DateTime.now())),
            const SizedBox(width: 8),
            UbStatusBadge(
              label: l10n.liveConnectedBadge,
              backgroundColor: AppColors.green100,
              textColor: AppColors.green700,
            ),
            const SizedBox(width: 8),
            UbStatusBadge(
              label: l10n.screenAwakeBadge,
              backgroundColor: AppColors.green50,
              textColor: AppColors.inkMuted,
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
                  extended: MediaQuery.sizeOf(context).width >= 1160,
                  backgroundColor: AppColors.green900,
                  indicatorColor: AppColors.orange,
                  selectedIconTheme: const IconThemeData(
                    color: AppColors.ink,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: AppColors.green100,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.green100,
                    fontWeight: FontWeight.w500,
                  ),
                  onDestinationSelected: (idx) =>
                      setState(() => _selectedTab = idx),
                  destinations: railDestinations,
                ),
                Expanded(child: body),
              ],
            )
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < railDestinations.length; i++)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            selected: _selectedTab == i,
                            label: railDestinations[i].label,
                            onSelected: (_) => setState(() => _selectedTab = i),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            ),
    );
  }
}

class _MenuManagerTab extends ConsumerStatefulWidget {
  const _MenuManagerTab({required this.cafeteriaId, required this.actor});

  final String cafeteriaId;
  final AppUser actor;

  @override
  ConsumerState<_MenuManagerTab> createState() => _MenuManagerTabState();
}

class _MenuManagerTabState extends ConsumerState<_MenuManagerTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mealsAsync = ref.watch(
      cafeteriaMealsStreamProvider(widget.cafeteriaId),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openMealDialog(context, ref),
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.ink,
        icon: const Icon(LucideIcons.plus),
        label: Text(l10n.addMealButton),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(LucideIcons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          Expanded(
            child: mealsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorStateView(message: e.toString()),
              data: (meals) {
                final filtered = _searchQuery.isEmpty
                    ? meals
                    : meals
                          .where(
                            (m) => m.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return EmptyStateView(
                    icon: LucideIcons.utensilsCrossed,
                    title: l10n.noMealsInCategory,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final meal = filtered[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: MealImageWidget(
                          imagePath: meal.imagePath,
                          width: 64,
                          height: 64,
                        ),
                        title: Text(
                          meal.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.localizedMealCategory(meal.category)} • ${meal.price.toStringAsFixed(2)} ${l10n.currencyJod}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.orangeText,
                              ),
                            ),
                            if (meal.description.isNotEmpty)
                              Text(
                                meal.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: meal.isAvailable,
                              onChanged: (val) async {
                                await ref
                                    .read(mealRepositoryProvider)
                                    .setMealAvailability(
                                      mealId: meal.id,
                                      isAvailable: val,
                                      actor: widget.actor,
                                    );
                              },
                            ),
                            IconButton(
                              tooltip: l10n.edit,
                              onPressed: () =>
                                  _openMealDialog(context, ref, existing: meal),
                              icon: const Icon(LucideIcons.pencil),
                            ),
                            IconButton(
                              tooltip: l10n.delete,
                              onPressed: () async {
                                await ref
                                    .read(mealRepositoryProvider)
                                    .deleteMeal(
                                      mealId: meal.id,
                                      actor: widget.actor,
                                    );
                              },
                              icon: const Icon(
                                LucideIcons.trash2,
                                color: AppColors.dangerText,
                              ),
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

  Future<void> _openMealDialog(
    BuildContext context,
    WidgetRef ref, {
    Meal? existing,
  }) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(2) : '',
    );
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String selectedCategory =
        existing?.category ?? SeedData.mealCategories.first;
    String imagePath = existing?.imagePath ?? 'preset:sandwich';
    bool isAvailable = existing?.isAvailable ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text(
            existing == null ? l10n.addMealButton : l10n.editMealTitle,
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        MealImageWidget(
                          imagePath: imagePath,
                          width: 72,
                          height: 72,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UbSecondaryButton(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 640,
                                    imageQuality: 75,
                                  );
                                  if (picked != null) {
                                    final bytes = await picked.readAsBytes();
                                    final encoded = base64Encode(bytes);
                                    setModalState(() {
                                      imagePath =
                                          'data:image/jpeg;base64,$encoded';
                                    });
                                  }
                                },
                                icon: LucideIcons.imagePlus,
                                label: l10n.pickImageButton,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.orChoosePreset,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: SeedData.presetMealImages
                          .map(
                            (preset) => InkWell(
                              onTap: () =>
                                  setModalState(() => imagePath = preset),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: imagePath == preset
                                        ? AppColors.orange
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: MealImageWidget(
                                  imagePath: preset,
                                  width: 44,
                                  height: 44,
                                  borderRadius: 10,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.mealNameLabel,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.fieldRequired
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n.mealCategoryLabel,
                      ),
                      items: SeedData.mealCategories
                          .map(
                            (cat) => DropdownMenuItem<String>(
                              value: cat,
                              child: Text(l10n.localizedMealCategory(cat)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.mealPriceLabel,
                      ),
                      validator: (v) {
                        final parsed = double.tryParse(v?.trim() ?? '');
                        if (parsed == null || parsed <= 0) {
                          return l10n.invalidPrice;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.mealDescriptionLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.available),
                      value: isAvailable,
                      onChanged: (v) => setModalState(() => isAvailable = v),
                    ),
                  ],
                ),
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
      final meal = Meal(
        id: existing?.id ?? 'meal_${const Uuid().v4()}',
        cafeteriaId: widget.cafeteriaId,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        price: double.parse(priceCtrl.text.trim()),
        imagePath: imagePath,
        category: selectedCategory,
        isAvailable: isAvailable,
      );
      await ref
          .read(mealRepositoryProvider)
          .saveMeal(meal, actor: widget.actor);
    }

    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
  }
}

class _WorkingHoursTab extends ConsumerStatefulWidget {
  const _WorkingHoursTab({required this.cafeteriaId, required this.actor});

  final String cafeteriaId;
  final AppUser actor;

  @override
  ConsumerState<_WorkingHoursTab> createState() => _WorkingHoursTabState();
}

class _WorkingHoursTabState extends ConsumerState<_WorkingHoursTab> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _openTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 22, minute: 0);
  final _prepCtrl = TextEditingController();
  final _timeoutCtrl = TextEditingController();
  bool _syncedFromCafe = false;
  bool _saving = false;

  @override
  void dispose() {
    _prepCtrl.dispose();
    _timeoutCtrl.dispose();
    super.dispose();
  }

  void _syncInitial(Cafeteria cafe) {
    if (_syncedFromCafe) return;
    final parsed = Cafeteria.parseWorkingHours(cafe.workingHours);
    if (parsed != null) {
      _openTime = TimeOfDay(hour: parsed.$1 ~/ 60, minute: parsed.$1 % 60);
      _closeTime = TimeOfDay(hour: parsed.$2 ~/ 60, minute: parsed.$2 % 60);
    }
    _prepCtrl.text = cafe.prepTimeMinutes.toString();
    _timeoutCtrl.text = cafe.orderTimeoutSeconds.toString();
    _syncedFromCafe = true;
  }

  String _formatTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final hours = '${_formatTime(_openTime)}-${_formatTime(_closeTime)}';
      await ref
          .read(cafeteriaRepositoryProvider)
          .updateWorkingHours(
            cafeteriaId: widget.cafeteriaId,
            workingHours: hours,
            prepTimeMinutes: int.parse(_prepCtrl.text.trim()),
            orderTimeoutSeconds: int.parse(_timeoutCtrl.text.trim()),
            actor: widget.actor,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.settingsSavedMessage)),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cafeAsync = ref.watch(
      cafeteriaByIdStreamProvider(widget.cafeteriaId),
    );

    return cafeAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorStateView(message: e.toString()),
      data: (cafe) {
        if (cafe == null) {
          return EmptyStateView(
            icon: LucideIcons.store,
            title: l10n.noCafeteriasOnCampus,
          );
        }
        _syncInitial(cafe);

        final isOpenNow = cafe.isOpenAt(DateTime.now());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.workingHoursTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            UbOpenClosedPill(isOpen: isOpenNow),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: UbSecondaryButton(
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _openTime,
                                  );
                                  if (picked != null) {
                                    setState(() => _openTime = picked);
                                  }
                                },
                                icon: LucideIcons.sunrise,
                                label:
                                    '${l10n.openingTimeLabel}: ${_formatTime(_openTime)}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: UbSecondaryButton(
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _closeTime,
                                  );
                                  if (picked != null) {
                                    setState(() => _closeTime = picked);
                                  }
                                },
                                icon: LucideIcons.sunset,
                                label:
                                    '${l10n.closingTimeLabel}: ${_formatTime(_closeTime)}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _prepCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.prepMinutesLabel,
                          ),
                          validator: (v) {
                            final parsed = int.tryParse(v?.trim() ?? '');
                            if (parsed == null || parsed <= 0) {
                              return l10n.invalidNumber;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _timeoutCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.timeoutSecondsLabel,
                          ),
                          validator: (v) {
                            final parsed = int.tryParse(v?.trim() ?? '');
                            if (parsed == null || parsed < 30) {
                              return l10n.invalidNumber;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        UbPrimaryButton(
                          isLoading: _saving,
                          onPressed: _save,
                          icon: LucideIcons.save,
                          label: l10n.saveSettingsButton,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StaffAccountsTab extends ConsumerWidget {
  const _StaffAccountsTab({required this.cafeteriaId, required this.actor});

  final String cafeteriaId;
  final AppUser actor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final usersAsync = ref.watch(
      usersStreamProvider((cafeteriaId: cafeteriaId)),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openAddStaffDialog(context, ref),
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.ink,
        icon: const Icon(LucideIcons.userPlus),
        label: Text(l10n.addStaffButton),
      ),
      body: usersAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (users) {
          final staff = users
              .where((u) => u.role == UserRole.cafeteriaStaff)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.green100,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.info,
                      color: AppColors.green700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.staffPermissionNote,
                        style: const TextStyle(color: AppColors.green700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (staff.isEmpty)
                EmptyStateView(icon: LucideIcons.users, title: l10n.noStaffYet)
              else
                ...staff.map(
                  (member) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.orangeSoft,
                          child: Icon(
                            LucideIcons.chefHat,
                            color: AppColors.orangeText,
                          ),
                        ),
                        title: Text(
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${member.email}${member.phone != null ? ' • ${member.phone}' : ''}',
                        ),
                        trailing: Switch(
                          value: member.isActive,
                          onChanged: (val) async {
                            await ref
                                .read(userRepositoryProvider)
                                .setUserActive(
                                  userId: member.id,
                                  isActive: val,
                                  actor: actor,
                                );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openAddStaffDialog(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Staff@123');
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text(l10n.addStaffButton),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dialogError != null) ...[
                    Text(
                      dialogError!,
                      style: const TextStyle(color: AppColors.dangerText),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: l10n.fullNameLabel),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: InputDecoration(labelText: l10n.emailLabel),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? l10n.invalidEmail
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.phoneOptionalLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    decoration: InputDecoration(labelText: l10n.passwordLabel),
                    validator: (v) => (v == null || v.length < 6)
                        ? l10n.passwordTooShort
                        : null,
                  ),
                ],
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
                  await ref
                      .read(userRepositoryProvider)
                      .createCafeteriaStaff(
                        name: nameCtrl.text,
                        email: emailCtrl.text,
                        password: passCtrl.text,
                        phone: phoneCtrl.text,
                        cafeteriaId: cafeteriaId,
                        actor: actor,
                      );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } on AppException catch (e) {
                  setModalState(() => dialogError = e.message);
                }
              },
              label: l10n.save,
            ),
          ],
        ),
      ),
    );

    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
  }
}

class _OrderHistoryTab extends ConsumerWidget {
  const _OrderHistoryTab({required this.cafeteriaId});

  final String cafeteriaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ordersAsync = ref.watch(cafeteriaOrdersStreamProvider(cafeteriaId));

    return ordersAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorStateView(message: e.toString()),
      data: (orders) {
        final history = orders.where((o) => o.status.isTerminal).toList();
        if (history.isEmpty) {
          return EmptyStateView(
            icon: LucideIcons.history,
            title: l10n.noHistoryYet,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: history.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = history[index];
            return Card(
              child: ListTile(
                title: Text(
                  '${l10n.orderNumberLabel(order.orderNumber)} • ${order.total.toStringAsFixed(2)} ${l10n.currencyJod}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${DateFormat.yMd().add_Hm().format(order.createdAt)} • ${l10n.orderTypeLabel(order.type)}'
                  '${order.rejectReason != null ? '\n${l10n.rejectReasonLabel(order.rejectReason!)}' : ''}',
                ),
                trailing: UbStatusBadge(
                  label: l10n.orderStatusLabel(order.status),
                  backgroundColor: order.status == OrderStatus.completed
                      ? AppColors.green50
                      : AppColors.dangerSoft,
                  textColor: order.status == OrderStatus.completed
                      ? AppColors.inkMuted
                      : AppColors.dangerText,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
