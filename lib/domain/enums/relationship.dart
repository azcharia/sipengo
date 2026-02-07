enum Relationship {
  head('head', 'Kepala Keluarga'),
  wife('wife', 'Istri'),
  husband('husband', 'Suami'),
  child('child', 'Anak'),
  grandchild('grandchild', 'Cucu'),
  parent('parent', 'Orang Tua'),
  grandparent('grandparent', 'Kakek/Nenek'),
  sibling('sibling', 'Saudara'),
  other('other', 'Lainnya');

  final String value;
  final String label;

  const Relationship(this.value, this.label);

  static Relationship fromString(String value) {
    return Relationship.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Relationship.other,
    );
  }
}
