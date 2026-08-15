class IngredientAwareness {
  const IngredientAwareness({
    required this.category,
    required this.likelyAdditives,
    required this.healthierSwaps,
    required this.disclaimer,
  });

  final String category;
  final List<String> likelyAdditives;
  final List<String> healthierSwaps;
  final String disclaimer;

  static const String defaultDisclaimer =
      'Based on typical preparation for this dish category — not a lab analysis of this plate.';

  factory IngredientAwareness.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return IngredientAwareness.forFoodName('Unknown food');
    }
    return IngredientAwareness(
      category: json['category']?.toString() ?? 'General meal',
      likelyAdditives: _stringList(json['likelyAdditives']),
      healthierSwaps: _stringList(json['healthierSwaps']),
      disclaimer: json['disclaimer']?.toString() ?? defaultDisclaimer,
    );
  }

  /// Client-side category tips so tips refresh when the user renames a dish.
  factory IngredientAwareness.forFoodName(String foodName) {
    final name = foodName.trim().toLowerCase();

    if (_any(name, [
      'butter masala',
      'butter chicken',
      'makhani',
      'tikka masala',
      'korma',
      'gravy',
    ])) {
      return const IngredientAwareness(
        category: 'Restaurant-style gravy',
        likelyAdditives: [
          'Artificial orange/red food colors are sometimes used for richer gravy look',
          'Flavor enhancers (e.g. MSG) may be added in commercial kitchens',
          'Cream, butter, and excess oil are common in restaurant versions',
        ],
        healthierSwaps: [
          'Ask for less oil/butter, or choose a tomato-based home-style curry',
          'Pair with salad or grilled sides instead of fried starters',
          'Prefer homemade versions with natural tomato/spice color',
        ],
        disclaimer: defaultDisclaimer,
      );
    }

    if (_any(name, [
      'samosa',
      'pakora',
      'french fries',
      'fried',
      'nugget',
      'bhaji',
      'puri',
    ])) {
      return const IngredientAwareness(
        category: 'Deep-fried foods',
        likelyAdditives: [
          'Reused frying oil can degrade and form unwanted compounds over time',
          'Commercial coatings may include artificial color for golden appearance',
          'Often high in refined flour and salt',
        ],
        healthierSwaps: [
          'Choose baked/air-fried options when available',
          'Limit portion size and balance with vegetables or dal',
          'Prefer freshly fried oil over leftover oil when cooking at home',
        ],
        disclaimer: defaultDisclaimer,
      );
    }

    if (_any(name, [
      'pizza',
      'burger',
      'hamburger',
      'sandwich',
      'hot dog',
    ])) {
      return const IngredientAwareness(
        category: 'Processed / fast food',
        likelyAdditives: [
          'Processed meats and sauces may include preservatives and color additives',
          'Refined flour bases and high sodium are common',
          'Cheese analogues or flavor boosters can appear in cheaper versions',
        ],
        healthierSwaps: [
          'Choose thinner crust, extra veggies, and lighter cheese',
          'Skip sugary drinks; drink water',
          'Prefer grilled over deep-fried sides',
        ],
        disclaimer: defaultDisclaimer,
      );
    }

    if (_any(name, [
      'biryani',
      'pulao',
      'fried rice',
      'noodles',
      'pasta',
    ])) {
      return const IngredientAwareness(
        category: 'Rice / grain mains',
        likelyAdditives: [
          'Restaurant coloring (yellow/orange) is sometimes used for visual appeal',
          'Excess oil/ghee and salt are common in commercial batches',
          'Flavor enhancers may be used in takeaway versions',
        ],
        healthierSwaps: [
          'Ask for less oil and less salt',
          'Add a side of raita, salad, or dal for balance',
          'Prefer brown rice / millet versions when available',
        ],
        disclaimer: defaultDisclaimer,
      );
    }

    if (_any(name, [
      'sweet',
      'ladoo',
      'halwa',
      'ice cream',
      'cake',
      'mithai',
      'dessert',
      'gulab',
    ])) {
      return const IngredientAwareness(
        category: 'Sweets & desserts',
        likelyAdditives: [
          'Bright artificial colors are frequently used in commercial sweets',
          'High refined sugar and sometimes non-dairy fat substitutes',
          'Silver leaf / decorative coatings may be cosmetic rather than nutritious',
        ],
        healthierSwaps: [
          'Share a smaller portion or choose fruit-based desserts',
          'Prefer homemade sweets with less sugar and natural color',
          'Check packaged labels for E-number colors when buying boxed sweets',
        ],
        disclaimer: defaultDisclaimer,
      );
    }

    if (_any(name, [
      'salad',
      'grilled',
      'idli',
      'idly',
      'steamed',
      'soup',
      'dal',
    ])) {
      return const IngredientAwareness(
        category: 'Generally lighter choice',
        likelyAdditives: [
          'Dressings/chutneys can still hide added sugar, salt, or color',
          'Store-bought sauces may include preservatives',
        ],
        healthierSwaps: [
          'Keep dressings on the side',
          'Favor steamed/grilled preparations',
          'Watch portion of oily tadka or creamy dressings',
        ],
        disclaimer: defaultDisclaimer,
      );
    }

    return const IngredientAwareness(
      category: 'General meal',
      likelyAdditives: [
        'Restaurant and packaged versions may include artificial colors or flavor enhancers',
        'Oil, salt, and sugar levels vary widely by kitchen',
      ],
      healthierSwaps: [
        'Prefer home-cooked meals with whole ingredients when possible',
        'For packaged foods, read the ingredient list for colors and preservatives',
        'Balance richer dishes with vegetables, yogurt, or salad',
      ],
      disclaimer: defaultDisclaimer,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).where((s) => s.isNotEmpty).toList();
  }

  static bool _any(String name, List<String> keywords) {
    for (final keyword in keywords) {
      if (name.contains(keyword)) return true;
    }
    return false;
  }
}
