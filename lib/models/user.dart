class User {
  final String username;
  final String password;

  // Recycling game scores (3 levels)
  int recycleLevel1Score;
  int recycleLevel2Score;
  int recycleLevel3Score;

  // Plant game scores (3 levels)
  int plantLevel1Score;
  int plantLevel2Score;
  int plantLevel3Score;

  // Clean game scores (3 levels)
  int cleanLevel1Score;
  int cleanLevel2Score;
  int cleanLevel3Score;

  // Energy game scores (3 levels)
  int energyLevel1Score;
  int energyLevel2Score;
  int energyLevel3Score;

  User({
    required this.username,
    required this.password,
    this.recycleLevel1Score = 0,
    this.recycleLevel2Score = 0,
    this.recycleLevel3Score = 0,
    this.plantLevel1Score = 0,
    this.plantLevel2Score = 0,
    this.plantLevel3Score = 0,
    this.cleanLevel1Score = 0,
    this.cleanLevel2Score = 0,
    this.cleanLevel3Score = 0,
    this.energyLevel1Score = 0,
    this.energyLevel2Score = 0,
    this.energyLevel3Score = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'recycleLevel1Score': recycleLevel1Score,
      'recycleLevel2Score': recycleLevel2Score,
      'recycleLevel3Score': recycleLevel3Score,
      'plantLevel1Score': plantLevel1Score,
      'plantLevel2Score': plantLevel2Score,
      'plantLevel3Score': plantLevel3Score,
      'cleanLevel1Score': cleanLevel1Score,
      'cleanLevel2Score': cleanLevel2Score,
      'cleanLevel3Score': cleanLevel3Score,
      'energyLevel1Score': energyLevel1Score,
      'energyLevel2Score': energyLevel2Score,
      'energyLevel3Score': energyLevel3Score,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
      recycleLevel1Score: json['recycleLevel1Score'] ?? 0,
      recycleLevel2Score: json['recycleLevel2Score'] ?? 0,
      recycleLevel3Score: json['recycleLevel3Score'] ?? 0,
      plantLevel1Score: json['plantLevel1Score'] ?? 0,
      plantLevel2Score: json['plantLevel2Score'] ?? 0,
      plantLevel3Score: json['plantLevel3Score'] ?? 0,
      cleanLevel1Score: json['cleanLevel1Score'] ?? 0,
      cleanLevel2Score: json['cleanLevel2Score'] ?? 0,
      cleanLevel3Score: json['cleanLevel3Score'] ?? 0,
      energyLevel1Score: json['energyLevel1Score'] ?? 0,
      energyLevel2Score: json['energyLevel2Score'] ?? 0,
      energyLevel3Score: json['energyLevel3Score'] ?? 0,
    );
  }

  int getTotalScore() {
    return recycleLevel1Score +
        recycleLevel2Score +
        recycleLevel3Score +
        plantLevel1Score +
        plantLevel2Score +
        plantLevel3Score +
        cleanLevel1Score +
        cleanLevel2Score +
        cleanLevel3Score +
        energyLevel1Score +
        energyLevel2Score +
        energyLevel3Score;
  }
}