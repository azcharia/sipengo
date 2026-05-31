import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:sipen_go/data/repositories/family_repository.dart';
import 'package:sipen_go/data/repositories/resident_repository.dart';
import 'package:sipen_go/data/models/resident_model.dart';

class ExportService {
  final FamilyRepository _familyRepo;
  final ResidentRepository _residentRepo;

  ExportService(this._familyRepo, this._residentRepo);

  /// Export all data to Excel
  Future<void> exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Data Penduduk'];

      // Header
      sheet.appendRow([
        TextCellValue('No KK'),
        TextCellValue('Kepala Keluarga'),
        TextCellValue('Alamat'),
        TextCellValue('NIK'),
        TextCellValue('Nama Lengkap'),
        TextCellValue('Tanggal Lahir'),
        TextCellValue('Umur'),
        TextCellValue('Jenis Kelamin'),
        TextCellValue('Hubungan'),
      ]);

      // Get all families and residents in single queries (O(1) database queries)
      final families = await _familyRepo.getAllFamilies();
      final allResidents = await _residentRepo.getAllResidents();

      // Map residents by familyId
      final residentsMap = <String, List<ResidentModel>>{};
      for (var resident in allResidents) {
        residentsMap.putIfAbsent(resident.familyId, () => []).add(resident);
      }

      // Add data
      for (var family in families) {
        final residents = residentsMap[family.id] ?? [];
        
        // Sort by relationship hierarchy in memory to match previous behavior
        residents.sort((a, b) {
          final hierarchyOrder = {
            'head': 0,
            'wife': 1,
            'husband': 1,
            'child': 2,
            'grandchild': 3,
            'parent': 4,
            'grandparent': 5,
            'sibling': 6,
            'other': 7,
          };
          final orderA = hierarchyOrder[a.relationship.value] ?? 99;
          final orderB = hierarchyOrder[b.relationship.value] ?? 99;
          return orderA.compareTo(orderB);
        });

        if (residents.isEmpty) {
          // Add family without residents
          sheet.appendRow([
            TextCellValue(family.kkNumber),
            TextCellValue(family.headOfHousehold),
            TextCellValue(family.address),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
          ]);
        } else {
          // Add family with residents
          for (var resident in residents) {
            sheet.appendRow([
              TextCellValue(family.kkNumber),
              TextCellValue(family.headOfHousehold),
              TextCellValue(family.address),
              TextCellValue(resident.nik),
              TextCellValue(resident.fullName),
              TextCellValue(
                DateFormat('dd/MM/yyyy').format(resident.birthDate),
              ),
              TextCellValue('${resident.age} tahun'),
              TextCellValue(resident.gender.label),
              TextCellValue(resident.relationship.label),
            ]);
          }
        }
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/SIPEN-GO_Data_$timestamp.xlsx';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // Share file
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Data Penduduk SIPEN-GO',
          text: 'Export data penduduk Desa Gombang',
        );
      }
    } catch (e) {
      throw Exception('Gagal export ke Excel: $e');
    }
  }

  /// Export all data to PDF
  Future<void> exportToPDF() async {
    try {
      final pdf = pw.Document();

      // Get all families and residents in single queries
      final families = await _familyRepo.getAllFamilies();
      final allResidents = await _residentRepo.getAllResidents();

      // Map residents by familyId
      final residentsMap = <String, List<ResidentModel>>{};
      for (var resident in allResidents) {
        residentsMap.putIfAbsent(resident.familyId, () => []).add(resident);
      }

      // Statistics
      final totalResidents = allResidents.length;
      final maleCount = allResidents.where((r) => r.gender.value == 'male').length;
      final femaleCount = allResidents.where((r) => r.gender.value == 'female').length;

      // Cover Page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'SIPEN-GO',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Sistem Informasi Penduduk Gombang',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'LAPORAN DATA PENDUDUK',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 2),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total Keluarga: ${families.length}'),
                        pw.SizedBox(height: 8),
                        pw.Text('Total Penduduk: $totalResidents'),
                        pw.SizedBox(height: 8),
                        pw.Text('Laki-laki: $maleCount'),
                        pw.SizedBox(height: 8),
                        pw.Text('Perempuan: $femaleCount'),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Data Pages
      for (var family in families) {
        final residents = residentsMap[family.id] ?? [];
        
        // Sort in memory to match previous relationship ordering
        residents.sort((a, b) {
          final hierarchyOrder = {
            'head': 0,
            'wife': 1,
            'husband': 1,
            'child': 2,
            'grandchild': 3,
            'parent': 4,
            'grandparent': 5,
            'sibling': 6,
            'other': 7,
          };
          final orderA = hierarchyOrder[a.relationship.value] ?? 99;
          final orderB = hierarchyOrder[b.relationship.value] ?? 99;
          return orderA.compareTo(orderB);
        });

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Family Header
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'KARTU KELUARGA',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'No. KK: ${family.kkNumber}',
                          style: const pw.TextStyle(color: PdfColors.white),
                        ),
                        pw.Text(
                          'Kepala: ${family.headOfHousehold}',
                          style: const pw.TextStyle(color: PdfColors.white),
                        ),
                        pw.Text(
                          'Alamat: ${family.address}',
                          style: const pw.TextStyle(color: PdfColors.white),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Residents Table
                  pw.Text(
                    'Anggota Keluarga (${residents.length} orang)',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  if (residents.isEmpty)
                    pw.Text('Belum ada anggota keluarga')
                  else
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        // Header
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'NIK',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'Nama',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'L/P',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'Umur',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'Hubungan',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Data
                        ...residents.map((resident) {
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  resident.nik,
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  resident.fullName,
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  resident.gender.value == 'male' ? 'L' : 'P',
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  '${resident.age}',
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  resident.relationship.label,
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                ],
              );
            },
          ),
        );
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/SIPEN-GO_Laporan_$timestamp.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Laporan Penduduk SIPEN-GO',
        text: 'Laporan data penduduk Desa Gombang',
      );
    } catch (e) {
      throw Exception('Gagal export ke PDF: $e');
    }
  }
}
