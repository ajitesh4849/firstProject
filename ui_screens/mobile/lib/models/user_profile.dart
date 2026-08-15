enum FitnessGoal {
  loseWeight,
  maintain,
  gainMuscle,
}

extension FitnessGoalLabel on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.loseWeight:
        return 'Lose Weight';
      case FitnessGoal.maintain:
        return 'Maintain';
      case FitnessGoal.gainMuscle:
        return 'Gain Muscle';
    }
  }
}

enum ProfileGender {
  male,
  female,
  unspecified,
}

extension ProfileGenderLabel on ProfileGender {
  String get label {
    switch (this) {
      case ProfileGender.male:
        return 'Male';
      case ProfileGender.female:
        return 'Female';
      case ProfileGender.unspecified:
        return 'Prefer not to say';
    }
  }
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
}

extension ActivityLevelLabel on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately active';
      case ActivityLevel.veryActive:
        return 'Very active';
    }
  }

  String get subtitle {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Desk job, little or no exercise';
      case ActivityLevel.lightlyActive:
        return 'Light exercise 1–3 days/week';
      case ActivityLevel.moderatelyActive:
        return 'Exercise 3–5 days/week';
      case ActivityLevel.veryActive:
        return 'Hard exercise 6–7 days/week';
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    this.dailyGoalKcal = 2200,
  });

  final int age;
  final double weightKg;
  final double heightCm;
  final ProfileGender gender;
  final ActivityLevel activityLevel;
  final FitnessGoal goal;
  final int dailyGoalKcal;

  UserProfile copyWith({
    int? age,
    double? weightKg,
    double? heightCm,
    ProfileGender? gender,
    ActivityLevel? activityLevel,
    FitnessGoal? goal,
    int? dailyGoalKcal,
  }) {
    return UserProfile(
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyGoalKcal: dailyGoalKcal ?? this.dailyGoalKcal,
    );
  }
}
