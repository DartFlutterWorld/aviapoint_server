enum SubscriptionType {
  monthly('monthly', 'Месячная подписка', 30),
  quarterly('quarterly', 'Квартальная подписка', 90),
  yearly('yearly', 'Годовая подписка', 365),
  custom('custom', 'Произвольная подписка', 0);

  final String code;
  final String name;
  final int defaultDays;

  const SubscriptionType(this.code, this.name, this.defaultDays);

  static SubscriptionType? fromCode(String code) {
    return SubscriptionType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => SubscriptionType.custom,
    );
  }
}
