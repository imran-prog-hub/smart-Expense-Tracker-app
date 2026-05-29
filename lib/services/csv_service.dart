import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/expense_model.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';

class CsvService {
  static Future<String?> exportExpensesToCsv(List<ExpenseModel> expenses, DateTime month) async {
    final buffer = StringBuffer();
    // Headers matching the model
    buffer.writeln('Date,Title,Amount (₹),Category,Payment Method,Type,Note');
    
    for (final exp in expenses) {
      final categoryName = AppConstants.getCategoryName(exp.categoryId);
      final typeStr = exp.isIncome ? 'Income' : 'Expense';
      
      // Escape title and note in case they contain commas
      final title = exp.title.contains(',') ? '"${exp.title}"' : exp.title;
      final note = (exp.note ?? '').contains(',') ? '"${exp.note}"' : (exp.note ?? '');
      
      buffer.writeln('${exp.date.toIso8601String().substring(0, 10)},$title,${exp.amount},$categoryName,${exp.paymentMethod},$typeStr,$note');
    }
    
    try {
      Directory? directory;
      if (Platform.isWindows) {
        final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOMEPATH'];
        if (home != null) {
          directory = Directory('$home\\Downloads');
        }
      } else if (Platform.isAndroid) {
        // Try standard downloads directory
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to external files directory if Android permissions/storage restricts direct writing
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        return null;
      }
      
      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final formattedMonth = AppUtils.formatMonthYear(month).replaceAll(' ', '_');
      final filePath = '${directory.path}/expenses_$formattedMonth.csv';
      final file = File(filePath);
      await file.writeAsString(buffer.toString());
      return filePath;
    } catch (e) {
      // Log or print the error
      print('Error exporting CSV: $e');
      return null;
    }
  }
}
