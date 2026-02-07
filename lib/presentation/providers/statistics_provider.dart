import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/family_repository.dart';
import '../../data/repositories/resident_repository.dart';
import '../providers/family_provider.dart';
import '../providers/resident_provider.dart';

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
  final familyRepo = ref.watch(familyRepositoryProvider);
  final residentRepo = ref.watch(residentRepositoryProvider);

  // Get all families
  final families = await familyRepo.getAllFamilies();
  final totalFamilies = families.length;

  // Count verified photos
  final verifiedPhotos =
      families
          .where((f) => f.housePhotoUrl != null && f.housePhotoUrl!.isNotEmpty)
          .length;

  final photoPercentage =
      totalFamilies > 0 ? (verifiedPhotos / totalFamilies * 100) : 0.0;

  // Get all residents from all families
  int totalResidents = 0;
  int maleCount = 0;
  int femaleCount = 0;

  for (var family in families) {
    final residents = await residentRepo.getResidentsByFamily(family.id);
    totalResidents += residents.length;

    final males = residents.where((r) => r.gender.value == 'male').length;
    final females = residents.where((r) => r.gender.value == 'female').length;

    maleCount += males;
    femaleCount += females;
  }

  return StatisticsData(
    totalFamilies: totalFamilies,
    totalResidents: totalResidents,
    maleCount: maleCount,
    femaleCount: femaleCount,
    verifiedPhotos: verifiedPhotos,
    photoVerificationPercentage: photoPercentage,
  );
});
