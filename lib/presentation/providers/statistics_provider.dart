import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_service.dart';

class StatisticsData {
  final int totalFamilies;
  final int totalResidents;
  final int maleCount;
  final int femaleCount;
  final int verifiedPhotos;
  final double photoVerificationPercentage;

  StatisticsData({
    required this.totalFamilies,
    required this.totalResidents,
    required this.maleCount,
    required this.femaleCount,
    required this.verifiedPhotos,
    required this.photoVerificationPercentage,
  });
}

final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  // Query only house_photo_url from families table to count families and verified photos
  final familiesResponse = await SupabaseService.families.select('house_photo_url');
  final familiesList = familiesResponse as List;
  final totalFamilies = familiesList.length;

  final verifiedPhotos = familiesList.where((f) {
    final url = f['house_photo_url'] as String?;
    return url != null && url.isNotEmpty;
  }).length;

  final photoPercentage =
      totalFamilies > 0 ? (verifiedPhotos / totalFamilies * 100) : 0.0;

  // Query only gender from residents table to count residents and gender distribution
  final residentsResponse = await SupabaseService.residents.select('gender');
  final residentsList = residentsResponse as List;
  final totalResidents = residentsList.length;

  final maleCount = residentsList.where((r) => r['gender'] == 'male').length;
  final femaleCount = residentsList.where((r) => r['gender'] == 'female').length;

  return StatisticsData(
    totalFamilies: totalFamilies,
    totalResidents: totalResidents,
    maleCount: maleCount,
    femaleCount: femaleCount,
    verifiedPhotos: verifiedPhotos,
    photoVerificationPercentage: photoPercentage,
  );
});

