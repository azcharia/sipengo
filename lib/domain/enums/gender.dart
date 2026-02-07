enum Gender {
  male('male', 'Laki-laki'),
  female('female', 'Perempuan');

  final String value;
  final String label;

  const Gender(this.value, this.label);

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Gender.male,
    );
  }
}
