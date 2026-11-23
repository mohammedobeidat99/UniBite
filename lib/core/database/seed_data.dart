import 'package:unibite/core/utils/password_hasher.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/orders/domain/entities/order_item.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/orders/domain/entities/order_type.dart';
import 'package:unibite/features/universities/domain/entities/campus.dart';
import 'package:unibite/features/universities/domain/entities/university.dart';

/// Deterministic initial dataset for GP1 first-run seeding and demo reset.
class SeedData {
  SeedData._();

  /// Fixed simulated OTP/verification code accepted for GP1 auth flows.
  static const String demoVerificationCode = '123456';

  /// Canonical meal category keys supported across menus.
  static const List<String> mealCategories = [
    'Sandwiches',
    'Hot Meals',
    'Salads',
    'Beverages',
    'Desserts',
  ];

  /// Built-in preset image keys for meal illustrations.
  static const List<String> presetMealImages = [
    'preset:sandwich',
    'preset:hotmeal',
    'preset:salad',
    'preset:beverage',
    'preset:dessert',
  ];

  /// Initial 2 universities required for GP1 seed data.
  static List<University> universities() => const [
    University(
      id: 'uni_just',
      name: 'Jordan University of Science & Technology (JUST)',
      logo: 'assets/images/logo.jpg',
      isActive: true,
    ),
    University(
      id: 'uni_uj',
      name: 'The University of Jordan (UJ)',
      logo: 'assets/images/logo.jpg',
      isActive: true,
    ),
  ];

  /// Initial 4 campuses (2 per university) required for GP1 seed data.
  static List<Campus> campuses() => const [
    Campus(
      id: 'camp_just_main',
      universityId: 'uni_just',
      name: 'Main Campus (Al-Ramtha)',
      location: 'Irbid – Al-Ramtha Highway',
      isActive: true,
    ),
    Campus(
      id: 'camp_just_city',
      universityId: 'uni_just',
      name: 'Medical City Branch',
      location: 'King Abdullah University Hospital Complex',
      isActive: true,
    ),
    Campus(
      id: 'camp_uj_main',
      universityId: 'uni_uj',
      name: 'Amman Main Campus',
      location: 'Queen Rania Street, Amman',
      isActive: true,
    ),
    Campus(
      id: 'camp_uj_aqaba',
      universityId: 'uni_uj',
      name: 'Aqaba Branch',
      location: 'Al-Aqaba University District',
      isActive: true,
    ),
  ];

  /// Initial 3 cafeterias distributed across the seeded campuses.
  static List<Cafeteria> cafeterias() => const [
    Cafeteria(
      id: 'cafe_olive',
      universityId: 'uni_just',
      campusId: 'camp_just_main',
      name: 'Green Olive Grill',
      logo: 'assets/images/logo.jpg',
      workingHours: '07:00-23:59',
      isActive: true,
      ownerId: 'user_cafe_admin_olive',
      prepTimeMinutes: 12,
      orderTimeoutSeconds: 180,
    ),
    Cafeteria(
      id: 'cafe_engbites',
      universityId: 'uni_just',
      campusId: 'camp_just_main',
      name: 'EngBites Express',
      logo: 'assets/images/logo.jpg',
      workingHours: '08:00-22:00',
      isActive: true,
      ownerId: 'user_cafe_admin_eng',
      prepTimeMinutes: 15,
      orderTimeoutSeconds: 180,
    ),
    Cafeteria(
      id: 'cafe_roastery',
      universityId: 'uni_uj',
      campusId: 'camp_uj_main',
      name: 'Campus Roastery & Bakery',
      logo: 'assets/images/logo.jpg',
      workingHours: '07:00-23:59',
      isActive: true,
      ownerId: 'user_cafe_admin_uj',
      prepTimeMinutes: 10,
      orderTimeoutSeconds: 180,
    ),
  ];

  /// Initial 10 meals spanning all categories and cafeterias.
  static List<Meal> meals() => const [
    Meal(
      id: 'meal_shawarma',
      cafeteriaId: 'cafe_olive',
      name: 'Chicken Shawarma Wrap',
      description:
          'Charcoal-grilled chicken slices, garlic sauce, pickles in saj bread.',
      price: 2.50,
      imagePath: 'preset:sandwich',
      category: 'Sandwiches',
      isAvailable: true,
    ),
    Meal(
      id: 'meal_falafel',
      cafeteriaId: 'cafe_olive',
      name: 'Falafel Supreme Sandwich',
      description: 'Crispy herb falafel with tahini, tomato, and fresh mint.',
      price: 1.25,
      imagePath: 'preset:sandwich',
      category: 'Sandwiches',
      isAvailable: true,
    ),
    Meal(
      id: 'meal_mansaf_bowl',
      cafeteriaId: 'cafe_olive',
      name: 'Mansaf Express Bowl',
      description:
          'Steamed saffron rice with tender lamb, jameed sauce, and toasted almonds.',
      price: 4.50,
      imagePath: 'preset:hotmeal',
      category: 'Hot Meals',
      isAvailable: true,
    ),
    Meal(
      id: 'meal_greek_salad',
      cafeteriaId: 'cafe_olive',
      name: 'Mediterranean Greek Salad',
      description:
          'Crisp cucumber, tomatoes, olives, feta cheese, and olive oil oregano dressing.',
      price: 2.20,
      imagePath: 'preset:salad',
      category: 'Salads',
      isAvailable: true,
    ),
    Meal(
      id: 'meal_orange_juice',
      cafeteriaId: 'cafe_olive',
      name: 'Fresh Pressed Orange Juice',
      description:
          'Chilled 100% natural seasonal Valencia orange juice (350ml).',
      price: 1.50,
      imagePath: 'preset:beverage',
      category: 'Beverages',
      isAvailable: true,
    ),
    Meal(
      id: 'meal_kunafa_cup',
      cafeteriaId: 'cafe_olive',
      name: 'Warm Kunafa Cup',
      description:
          'Golden shredded kataifi pastry with sweet cheese and pistachio.',
      price: 1.80,
      imagePath: 'preset:dessert',
      category: 'Desserts',
      isAvailable: false,
    ),
    Meal(
      id: 'meal_zinger_plate',
      cafeteriaId: 'cafe_engbites',
      name: 'Crispy Zinger Plate',
      description:
          'Spiced crispy chicken fillet served with seasoned fries and coleslaw.',
      price: 3.40,
      imagePath: 'preset:hotmeal',
      category: 'Hot Meals',
      isAvailable: true,
    ),
    Meal(
      id: 'meal_halloumi',
      cafeteriaId: 'cafe_engbites',
      name: 'Grilled Halloumi Panini',
      description:
          'Pressed ciabatta with grilled halloumi, pesto, and sun-dried tomatoes.',
      price: 2.60,
      imagePath: 'preset:sandwich',
      category: 'Sandwiches',
      isAvailable: true,
    ),
    Meal(
      id: 'meal_spanish_latte',
      cafeteriaId: 'cafe_roastery',
      name: 'Iced Spanish Latte',
      description:
          'Double espresso poured over cold milk and sweetened condensed cream.',
      price: 2.40,
      imagePath: 'preset:beverage',
      category: 'Beverages',
      isAvailable: true,
    ),
    Meal(
      id: 'meal_fudge_brownie',
      cafeteriaId: 'cafe_roastery',
      name: 'Dark Chocolate Brownie',
      description:
          'Rich baked cocoa brownie topped with sea-salt caramel drizzle.',
      price: 1.75,
      imagePath: 'preset:dessert',
      category: 'Desserts',
      isAvailable: true,
    ),
  ];

  /// Initial users covering every GP1 role with salted SHA-256 password hashes.
  static List<AppUser> users() => [
    AppUser(
      id: 'user_sys_admin',
      name: 'Tariq Al-Mansoor',
      email: 'sysadmin@unibite.edu',
      passwordHash: PasswordHasher.hashPassword(
        'Admin@123',
        salt: 'unibite_seed_sysadmin',
      ),
      phone: '0790000001',
      role: UserRole.systemAdmin,
      isActive: true,
    ),
    AppUser(
      id: 'user_cafe_admin_olive',
      name: 'Layla Haddad',
      email: 'admin.olive@just.edu.jo',
      passwordHash: PasswordHasher.hashPassword(
        'Cafe@123',
        salt: 'unibite_seed_olive_admin',
      ),
      phone: '0790000002',
      role: UserRole.cafeteriaAdmin,
      universityId: 'uni_just',
      campusId: 'camp_just_main',
      cafeteriaId: 'cafe_olive',
      isActive: true,
    ),
    AppUser(
      id: 'user_cafe_admin_eng',
      name: 'Omar Khoury',
      email: 'admin.engbites@just.edu.jo',
      passwordHash: PasswordHasher.hashPassword(
        'Cafe@123',
        salt: 'unibite_seed_eng_admin',
      ),
      phone: '0790000003',
      role: UserRole.cafeteriaAdmin,
      universityId: 'uni_just',
      campusId: 'camp_just_main',
      cafeteriaId: 'cafe_engbites',
      isActive: true,
    ),
    AppUser(
      id: 'user_cafe_admin_uj',
      name: 'Rania Ziad',
      email: 'admin.roastery@uj.edu.jo',
      passwordHash: PasswordHasher.hashPassword(
        'Cafe@123',
        salt: 'unibite_seed_uj_admin',
      ),
      phone: '0790000004',
      role: UserRole.cafeteriaAdmin,
      universityId: 'uni_uj',
      campusId: 'camp_uj_main',
      cafeteriaId: 'cafe_roastery',
      isActive: true,
    ),
    AppUser(
      id: 'user_cafe_staff_olive',
      name: 'Zaid Al-Qudah',
      email: 'staff.olive@just.edu.jo',
      passwordHash: PasswordHasher.hashPassword(
        'Staff@123',
        salt: 'unibite_seed_olive_staff',
      ),
      phone: '0790000005',
      role: UserRole.cafeteriaStaff,
      universityId: 'uni_just',
      campusId: 'camp_just_main',
      cafeteriaId: 'cafe_olive',
      isActive: true,
    ),
    AppUser(
      id: 'user_student_1',
      name: 'Nour Al-Din Ahmad',
      email: 'student@just.edu.jo',
      passwordHash: PasswordHasher.hashPassword(
        'Student@123',
        salt: 'unibite_seed_student1',
      ),
      phone: '0790000006',
      role: UserRole.student,
      universityId: 'uni_just',
      campusId: 'camp_just_main',
      isActive: true,
    ),
  ];

  /// Initial orders demonstrating live board columns and student order tracking.
  static List<Order> orders({DateTime? referenceTime}) {
    final now = referenceTime ?? DateTime.now();
    return [
      Order(
        id: 'order_seed_1',
        orderNumber: 'UB-1001',
        studentId: 'user_student_1',
        cafeteriaId: 'cafe_olive',
        items: const [
          OrderItem(
            mealId: 'meal_shawarma',
            name: 'Chicken Shawarma Wrap',
            price: 2.50,
            qty: 2,
            note: 'Extra garlic sauce',
          ),
          OrderItem(
            mealId: 'meal_orange_juice',
            name: 'Fresh Pressed Orange Juice',
            price: 1.50,
            qty: 1,
          ),
        ],
        total: 6.50,
        status: OrderStatus.ready,
        type: OrderType.app,
        qrCode: 'UNIBITE|order_seed_1|UB-1001|cafe_olive',
        paymentMethod: 'cash',
        createdAt: now.subtract(const Duration(minutes: 14)),
        updatedAt: now.subtract(const Duration(minutes: 2)),
      ),
      Order(
        id: 'order_seed_2',
        orderNumber: 'UB-1002',
        studentId: 'user_student_1',
        cafeteriaId: 'cafe_olive',
        items: const [
          OrderItem(
            mealId: 'meal_mansaf_bowl',
            name: 'Mansaf Express Bowl',
            price: 4.50,
            qty: 1,
          ),
        ],
        total: 4.50,
        status: OrderStatus.preparing,
        type: OrderType.app,
        qrCode: 'UNIBITE|order_seed_2|UB-1002|cafe_olive',
        paymentMethod: 'cash',
        createdAt: now.subtract(const Duration(minutes: 6)),
        updatedAt: now.subtract(const Duration(minutes: 3)),
      ),
      Order(
        id: 'order_seed_3',
        orderNumber: 'UB-1003',
        cafeteriaId: 'cafe_olive',
        items: const [
          OrderItem(
            mealId: 'meal_falafel',
            name: 'Falafel Supreme Sandwich',
            price: 1.25,
            qty: 2,
            note: 'Walk-in counter ticket',
          ),
        ],
        total: 2.50,
        status: OrderStatus.accepted,
        type: OrderType.walkin,
        qrCode: 'UNIBITE|order_seed_3|UB-1003|cafe_olive',
        paymentMethod: 'cash',
        createdAt: now.subtract(const Duration(minutes: 4)),
        updatedAt: now.subtract(const Duration(minutes: 3)),
      ),
    ];
  }
}
