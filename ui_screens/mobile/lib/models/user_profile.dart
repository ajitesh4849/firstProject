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

class UserProfile {
  const UserProfile({
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.goal,
  });

  final int age;
  final double weightKg;
  final double heightCm;
  final FitnessGoal goal;

  UserProfile copyWith({
    int? age,
    double? weightKg,
    double? heightCm,
    FitnessGoal? goal,
  }) {
    return UserProfile(
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      goal: goal ?? this.goal,
    );
  }
}
