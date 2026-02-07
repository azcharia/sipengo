import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyModel {
  final String id;
  final String kkNumber;
  final String address;
  final String headOfHousehold;
  final String? housePhotoUrl;
  final double? latitude;
  final double? longitude;
  final String? gmapsLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyModel({
    required this.id,
    required this.kkNumber,
    required this.address,
    required this.headOfHousehold,
    this.housePhotoUrl,
    this.latitude,
    this.longitude,
    this.gmapsLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'] as String,
      kkNumber: json['kk_number'] as String,
      address: json['address'] as String,
      headOfHousehold: json['head_of_household'] as String,
      housePhotoUrl: json['house_photo_url'] as String?,
      latitude:
          json['latitude'] != null
              ? (json['latitude'] as num).toDouble()
              : null,
      longitude:
          json['longitude'] != null
              ? (json['longitude'] as num).toDouble()
              : null,
      gmapsLink: json['gmaps_link'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kk_number': kkNumber,
      'address': address,
      'head_of_household': headOfHousehold,
      'house_photo_url': housePhotoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'gmaps_link': gmapsLink,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'kk_number': kkNumber,
      'address': address,
      'head_of_household': headOfHousehold,
      'house_photo_url': housePhotoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'gmaps_link': gmapsLink,
      'created_by': Supabase.instance.client.auth.currentUser?.id,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'kk_number': kkNumber,
      'address': address,
      'head_of_household': headOfHousehold,
      'house_photo_url': housePhotoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'gmaps_link': gmapsLink,
    };
  }

  FamilyModel copyWith({
    String? id,
    String? kkNumber,
    String? address,
    String? headOfHousehold,
    String? housePhotoUrl,
    double? latitude,
    double? longitude,
    String? gmapsLink,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyModel(
      id: id ?? this.id,
      kkNumber: kkNumber ?? this.kkNumber,
      address: address ?? this.address,
      headOfHousehold: headOfHousehold ?? this.headOfHousehold,
      housePhotoUrl: housePhotoUrl ?? this.housePhotoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gmapsLink: gmapsLink ?? this.gmapsLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
