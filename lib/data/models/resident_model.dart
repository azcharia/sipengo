import '../../domain/enums/gender.dart';
import '../../domain/enums/relationship.dart';

class ResidentModel {
  final String id;
  final String familyId;
  final String nik;
  final String fullName;
  final DateTime birthDate;
  final Gender gender;
  final Relationship relationship;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResidentModel({
    required this.id,
    required this.familyId,
    required this.nik,
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.relationship,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      nik: json['nik'] as String,
      fullName: json['full_name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      gender: Gender.fromString(json['gender'] as String),
      relationship: Relationship.fromString(json['relationship'] as String),
      parentId: json['parent_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'nik': nik,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'gender': gender.value,
      'relationship': relationship.value,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'family_id': familyId,
      'nik': nik,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'gender': gender.value,
      'relationship': relationship.value,
      'parent_id': parentId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nik': nik,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'gender': gender.value,
      'relationship': relationship.value,
      'parent_id': parentId,
    };
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  ResidentModel copyWith({
    String? id,
    String? familyId,
    String? nik,
    String? fullName,
    DateTime? birthDate,
    Gender? gender,
    Relationship? relationship,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResidentModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      nik: nik ?? this.nik,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      relationship: relationship ?? this.relationship,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
