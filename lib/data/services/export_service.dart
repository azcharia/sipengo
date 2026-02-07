import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../repositories/family_repository.dart';
import '../repositories/resident_repository.dart';

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

      // Get all families
      final families = await _familyRepo.getAllFamilies();

      // Add data
      for (var family in families) {
        final residents = await _residentRepo.getResidentsByFamily(family.id);

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
      final filePath = '${directory.path}/SIPENGO_Data_$timestamp.xlsx';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // Share file
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Data Penduduk SIPENGO',
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

      // Get all families
      final families = await _familyRepo.getAllFamilies();

      // Statistics
      int totalResidents = 0;
      int maleCount = 0;
      int femaleCount = 0;

      for (var family in families) {
        final residents = await _residentRepo.getResidentsByFamily(family.id);
        totalResidents += residents.length;
        maleCount += residents.where((r) => r.gender.value == 'male').length;
        femaleCount +=
            residents.where((r) => r.gender.value == 'female').length;
      }

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
                    'SIPENGO',
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
        final residents = await _residentRepo.getResidentsByFamily(family.id);

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
                        }).toList(),
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
      final filePath = '${directory.path}/SIPENGO_Laporan_$timestamp.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Laporan Penduduk SIPENGO',
        text: 'Laporan data penduduk Desa Gombang',
      );
    } catch (e) {
      throw Exception('Gagal export ke PDF: $e');
    }
  }
}
