import '../models/daily_summary.dart';
import '../models/food_item.dart';
import '../models/ingredient_awareness.dart';
import '../models/meal.dart';
import '../models/nutrition_info.dart';
import '../models/user_profile.dart';
import 'api_client.dart';
import 'placeholder_image.dart';

class FoodApiService {
  FoodApiService({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final body = await _client.postJson(
      '/api/v1/auth/login',
      body: {'email': email, 'password': password},
    );
    await _storeToken(body);
  }

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    final body = await _client.postJson(
      '/api/v1/auth/signup',
      body: {'email': email, 'password': password},
    );
    await _storeToken(body);
  }

  Future<void> _storeToken(Map<String, dynamic> body) async {
    final token = body['accessToken']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Auth response missing accessToken');
    }
    await _client.setAccessToken(token);
  }

  Future<FoodItem> createScan({
    List<int>? imageBytes,
    String filename = 'meal.jpg',
  }) async {
    final bytes = imageBytes ?? PlaceholderImage.jpegBytes;
    final body = await _client.postMultipart(
      path: '/api/v1/scans',
      fieldName: 'image',
      bytes: bytes,
      filename: filename,
    );

    final food = body['food'] as Map<String, dynamic>? ?? {};
    final awarenessJson = food['awareness'] as Map<String, dynamic>?;
    return FoodItem(
      name: food['name']?.toString() ?? 'Unknown food',
      confidence: (food['confidence'] as num?)?.toDouble() ?? 0,
      scanId: body['scanId']?.toString(),
      awareness: awarenessJson == null
          ? null
          : IngredientAwareness.fromJson(awarenessJson),
    );
  }

  Future<NutritionInfo> fetchNutrition({
    required String scanId,
    required int portionGrams,
  }) async {
    final body = await _client.postJson(
      '/api/v1/scans/$scanId/nutrition',
      body: {'portionGrams': portionGrams},
    );
    return NutritionInfo(
      foodName: body['foodName']?.toString() ?? '',
      portionGrams: (body['portionGrams'] as num?)?.toInt() ?? portionGrams,
      calories: (body['calories'] as num?)?.toInt() ?? 0,
      proteinGrams: (body['proteinGrams'] as num?)?.toDouble() ?? 0,
      carbsGrams: (body['carbsGrams'] as num?)?.toDouble() ?? 0,
      fatGrams: (body['fatGrams'] as num?)?.toDouble() ?? 0,
      estimated: body['estimated'] as bool? ?? true,
    );
  }

  Future<void> addMeal(NutritionInfo nutrition) async {
    await _client.postJson(
      '/api/v1/meals',
      body: {
        'foodName': nutrition.foodName,
        'portionGrams': nutrition.portionGrams,
        'calories': nutrition.calories,
        'proteinGrams': nutrition.proteinGrams,
        'carbsGrams': nutrition.carbsGrams,
        'fatGrams': nutrition.fatGrams,
      },
    );
  }

  Future<({int consumedKcal, int goalKcal, List<Meal> meals})> fetchToday() async {
    final body = await _client.getJson('/api/v1/me/today');
    final mealsJson = body['meals'] as List<dynamic>? ?? [];
    final meals = mealsJson.map((item) {
      final map = item as Map<String, dynamic>;
      return Meal(
        name: map['name']?.toString() ?? 'Meal',
        calories: (map['calories'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return (
      consumedKcal: (body['consumedKcal'] as num?)?.toInt() ?? 0,
      goalKcal: (body['goalKcal'] as num?)?.toInt() ?? 2200,
      meals: meals,
    );
  }

  Future<({List<DailySummary> days, double weeklyAverage})> fetchHistory() async {
    final body = await _client.getJson('/api/v1/me/history');
    final daysJson = body['days'] as List<dynamic>? ?? [];
    final days = daysJson.map((item) {
      final map = item as Map<String, dynamic>;
      DateTime? date;
      final rawDate = map['date']?.toString();
      if (rawDate != null && rawDate.isNotEmpty) {
        date = DateTime.tryParse(rawDate);
      }
      return DailySummary(
        label: map['label']?.toString() ?? '',
        calories: (map['calories'] as num?)?.toInt() ?? 0,
        date: date,
      );
    }).toList();

    return (
      days: days,
      weeklyAverage: (body['weeklyAverage'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<UserProfile> fetchProfile() async {
    final body = await _client.getJson('/api/v1/me/profile');
    return UserProfile(
      age: (body['age'] as num?)?.toInt() ?? 30,
      weightKg: (body['weightKg'] as num?)?.toDouble() ?? 70,
      heightCm: (body['heightCm'] as num?)?.toDouble() ?? 170,
      gender: _genderFromApi(body['gender']?.toString()),
      activityLevel: _activityFromApi(body['activityLevel']?.toString()),
      goal: _goalFromApi(body['goal']?.toString()),
      dailyGoalKcal: (body['dailyGoalKcal'] as num?)?.toInt() ?? 2200,
    );
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final body = await _client.putJson(
      '/api/v1/me/profile',
      body: {
        'age': profile.age,
        'weightKg': profile.weightKg,
        'heightCm': profile.heightCm,
        'gender': _genderToApi(profile.gender),
        'activityLevel': _activityToApi(profile.activityLevel),
        'goal': _goalToApi(profile.goal),
      },
    );
    return UserProfile(
      age: (body['age'] as num?)?.toInt() ?? profile.age,
      weightKg: (body['weightKg'] as num?)?.toDouble() ?? profile.weightKg,
      heightCm: (body['heightCm'] as num?)?.toDouble() ?? profile.heightCm,
      gender: _genderFromApi(body['gender']?.toString()),
      activityLevel: _activityFromApi(body['activityLevel']?.toString()),
      goal: _goalFromApi(body['goal']?.toString()),
      dailyGoalKcal:
          (body['dailyGoalKcal'] as num?)?.toInt() ?? profile.dailyGoalKcal,
    );
  }

  FitnessGoal _goalFromApi(String? value) {
    switch (value) {
      case 'MAINTAIN':
        return FitnessGoal.maintain;
      case 'GAIN_MUSCLE':
        return FitnessGoal.gainMuscle;
      case 'LOSE_WEIGHT':
      default:
        return FitnessGoal.loseWeight;
    }
  }

  String _goalToApi(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.maintain:
        return 'MAINTAIN';
      case FitnessGoal.gainMuscle:
        return 'GAIN_MUSCLE';
      case FitnessGoal.loseWeight:
        return 'LOSE_WEIGHT';
    }
  }

  ProfileGender _genderFromApi(String? value) {
    switch (value) {
      case 'MALE':
        return ProfileGender.male;
      case 'FEMALE':
        return ProfileGender.female;
      case 'UNSPECIFIED':
      default:
        return ProfileGender.unspecified;
    }
  }

  String _genderToApi(ProfileGender gender) {
    switch (gender) {
      case ProfileGender.male:
        return 'MALE';
      case ProfileGender.female:
        return 'FEMALE';
      case ProfileGender.unspecified:
        return 'UNSPECIFIED';
    }
  }

  ActivityLevel _activityFromApi(String? value) {
    switch (value) {
      case 'LIGHTLY_ACTIVE':
        return ActivityLevel.lightlyActive;
      case 'MODERATELY_ACTIVE':
        return ActivityLevel.moderatelyActive;
      case 'VERY_ACTIVE':
        return ActivityLevel.veryActive;
      case 'SEDENTARY':
      default:
        return ActivityLevel.sedentary;
    }
  }

  String _activityToApi(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'SEDENTARY';
      case ActivityLevel.lightlyActive:
        return 'LIGHTLY_ACTIVE';
      case ActivityLevel.moderatelyActive:
        return 'MODERATELY_ACTIVE';
      case ActivityLevel.veryActive:
        return 'VERY_ACTIVE';
    }
  }
}

final foodApi = FoodApiService();
