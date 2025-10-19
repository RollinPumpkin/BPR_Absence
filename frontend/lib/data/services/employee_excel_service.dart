import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../services/user_service.dart';

class EmployeeExcelService {
  static final EmployeeExcelService _instance = EmployeeExcelService._internal();
  factory EmployeeExcelService() => _instance;
  EmployeeExcelService._internal();

  final UserService _userService = UserService();

  /// Export employees to Excel file
  Future<ApiResponse<String>> exportEmployeesToExcel(List<User> employees) async {
    try {
      print('📊 EXCEL EXPORT: Starting export of ${employees.length} employees...');
      
      // Create Excel workbook
      var excel = Excel.createExcel();
      Sheet sheet = excel['Employees'];
      excel.delete('Sheet1'); // Remove default sheet
      
      // Define headers
      final headers = [
        'Employee ID',
        'Full Name', 
        'Email',
        'Role',
        'Position',
        'Department',
        'Phone',
        'Status',
        'Is Active',
        'Created Date',
        'Updated Date'
      ];
      
      // Add headers to first row
      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }
      
      // Add employee data
      for (int rowIndex = 0; rowIndex < employees.length; rowIndex++) {
        final employee = employees[rowIndex];
        final row = rowIndex + 1; // Start from row 1 (0 is header)
        
        final rowData = [
          employee.employeeId ?? '',
          employee.fullName,
          employee.email,
          employee.role,
          employee.position ?? '',
          employee.department ?? '',
          employee.phone ?? '',
          employee.status,
          employee.isActive ? 'Active' : 'Inactive',
          employee.createdAt?.toString().substring(0, 19) ?? '',
          employee.updatedAt?.toString().substring(0, 19) ?? '',
        ];
        
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: row));
          cell.value = TextCellValue(rowData[colIndex]);
          
          // Style active/inactive status
          if (colIndex == 8) { // Is Active column
            if (employee.isActive) {
              cell.cellStyle = CellStyle(fontColorHex: ExcelColor.green);
            } else {
              cell.cellStyle = CellStyle(fontColorHex: ExcelColor.red);
            }
          }
        }
      }
      
      // Auto-fit column widths
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15.0);
      }
      
      // Generate file name with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'employees_export_$timestamp.xlsx';
      
      // Save file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        try {
          final bytes = Uint8List.fromList(fileBytes);
          
          // Use FileSaver for all platforms
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: bytes,
            ext: 'xlsx',
          );
          
          print('✅ EXCEL EXPORT: File saved successfully as $fileName');
          return ApiResponse<String>(
            success: true,
            message: 'Employees exported successfully! Check your downloads folder.',
            data: fileName,
          );
        } catch (saveError) {
          print('❌ EXCEL EXPORT: Save error: $saveError');
          return ApiResponse<String>(
            success: false,
            message: 'Failed to save file: $saveError',
            error: saveError.toString(),
          );
        }
      } else {
        throw Exception('Failed to generate Excel file bytes');
      }
      
    } catch (e) {
      print('❌ EXCEL EXPORT: Error: $e');
      return ApiResponse<String>(
        success: false,
        message: 'Failed to export employees: $e',
        error: e.toString(),
      );
    }
  }

  /// Import employees from Excel file
  Future<ApiResponse<List<User>>> importEmployeesFromExcel() async {
    try {
      print('📥 EXCEL IMPORT: Starting import process...');
      
      // Pick Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return ApiResponse<List<User>>(
          success: false,
          message: 'No file selected',
        );
      }
      
      final file = result.files.first;
      Uint8List? fileBytes;
      
      if (kIsWeb) {
        fileBytes = file.bytes;
      } else {
        if (file.path != null) {
          final fileData = File(file.path!);
          fileBytes = await fileData.readAsBytes();
        }
      }
      
      if (fileBytes == null) {
        throw Exception('Failed to read file bytes');
      }
      
      // Parse Excel file
      var excel = Excel.decodeBytes(fileBytes);
      
      if (excel.tables.isEmpty) {
        throw Exception('Excel file contains no sheets');
      }
      
      // Get first sheet
      var sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) {
        throw Exception('Failed to read Excel sheet');
      }
      
      print('📥 EXCEL IMPORT: Processing ${sheet.maxRows} rows...');
      
      List<User> importedUsers = [];
      List<String> errors = [];
      
      // Process rows (skip header row)
      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        try {
          final row = sheet.rows[rowIndex];
          if (row.isEmpty || _isRowEmpty(row)) continue;
          
          // Extract data from row
          final employeeId = _getCellValue(row, 0);
          final fullName = _getCellValue(row, 1);
          final email = _getCellValue(row, 2);
          final role = _getCellValue(row, 3);
          final position = _getCellValue(row, 4);
          final department = _getCellValue(row, 5);
          final phone = _getCellValue(row, 6);
          final status = _getCellValue(row, 7);
          final isActiveStr = _getCellValue(row, 8);
          
          // Validate required fields
          if (fullName.isEmpty || email.isEmpty) {
            errors.add('Row ${rowIndex + 1}: Full Name and Email are required');
            continue;
          }
          
          // Create User object
          final user = User(
            id: '', // Will be generated by backend
            employeeId: employeeId.isNotEmpty ? employeeId : '',
            fullName: fullName,
            email: email,
            role: role.isNotEmpty ? role : 'employee',
            position: position.isNotEmpty ? position : null,
            department: department.isNotEmpty ? department : null,
            phone: phone.isNotEmpty ? phone : null,
            status: status.isNotEmpty ? status : 'active',
            isActive: isActiveStr.toLowerCase() == 'active' || isActiveStr.toLowerCase() == 'true',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          importedUsers.add(user);
          print('📥 EXCEL IMPORT: Processed user: ${user.fullName} (${user.email})');
          
        } catch (e) {
          errors.add('Row ${rowIndex + 1}: Error processing row - $e');
          print('❌ EXCEL IMPORT: Error in row ${rowIndex + 1}: $e');
        }
      }
      
      if (importedUsers.isEmpty) {
        return ApiResponse<List<User>>(
          success: false,
          message: 'No valid employee data found in Excel file.\nErrors:\n${errors.join('\n')}',
        );
      }
      
      print('✅ EXCEL IMPORT: Successfully processed ${importedUsers.length} employees');
      
      String message = 'Successfully imported ${importedUsers.length} employees';
      if (errors.isNotEmpty) {
        message += '\n\nWarnings:\n${errors.take(5).join('\n')}';
        if (errors.length > 5) {
          message += '\n... and ${errors.length - 5} more errors';
        }
      }
      
      return ApiResponse<List<User>>(
        success: true,
        message: message,
        data: importedUsers,
      );
      
    } catch (e) {
      print('❌ EXCEL IMPORT: Error: $e');
      return ApiResponse<List<User>>(
        success: false,
        message: 'Failed to import employees: $e',
        error: e.toString(),
      );
    }
  }

  /// Save imported employees to database
  Future<ApiResponse<int>> saveImportedEmployees(List<User> employees) async {
    try {
      print('💾 EXCEL IMPORT: Saving ${employees.length} employees to database...');
      
      int successCount = 0;
      List<String> errors = [];
      
      for (final employee in employees) {
        try {
          // Convert User object to Map for API
          final userData = {
            'employee_id': employee.employeeId,
            'full_name': employee.fullName,
            'email': employee.email,
            'role': employee.role,
            'position': employee.position,
            'department': employee.department,
            'phone': employee.phone,
            'status': employee.status,
            'is_active': employee.isActive,
          };
          
          final response = await _userService.createUser(userData);
          if (response.success) {
            successCount++;
            print('✅ EXCEL IMPORT: Saved ${employee.fullName}');
          } else {
            errors.add('${employee.fullName}: ${response.message}');
            print('❌ EXCEL IMPORT: Failed to save ${employee.fullName}: ${response.message}');
          }
        } catch (e) {
          errors.add('${employee.fullName}: $e');
          print('❌ EXCEL IMPORT: Exception saving ${employee.fullName}: $e');
        }
      }
      
      String message = 'Successfully saved $successCount out of ${employees.length} employees';
      if (errors.isNotEmpty) {
        message += '\n\nErrors:\n${errors.take(3).join('\n')}';
        if (errors.length > 3) {
          message += '\n... and ${errors.length - 3} more errors';
        }
      }
      
      return ApiResponse<int>(
        success: successCount > 0,
        message: message,
        data: successCount,
      );
      
    } catch (e) {
      print('❌ EXCEL IMPORT: Save error: $e');
      return ApiResponse<int>(
        success: false,
        message: 'Failed to save employees: $e',
        error: e.toString(),
      );
    }
  }

  /// Generate Excel template for import
  Future<ApiResponse<String>> generateImportTemplate() async {
    try {
      print('📋 EXCEL TEMPLATE: Generating import template...');
      
      var excel = Excel.createExcel();
      Sheet sheet = excel['Employee_Template'];
      excel.delete('Sheet1');
      
      // Headers
      final headers = [
        'Employee ID',
        'Full Name*', 
        'Email*',
        'Role',
        'Position',
        'Department',
        'Phone',
        'Status',
        'Is Active'
      ];
      
      // Add headers
      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }
      
      // Add sample data
      final sampleData = [
        ['EMP001', 'John Doe', 'john.doe@company.com', 'employee', 'Software Developer', 'IT', '081234567890', 'active', 'Active'],
        ['EMP002', 'Jane Smith', 'jane.smith@company.com', 'admin', 'HR Manager', 'HR', '081234567891', 'active', 'Active'],
      ];
      
      for (int rowIndex = 0; rowIndex < sampleData.length; rowIndex++) {
        final row = rowIndex + 1;
        for (int colIndex = 0; colIndex < sampleData[rowIndex].length; colIndex++) {
          var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: row));
          cell.value = TextCellValue(sampleData[rowIndex][colIndex]);
        }
      }
      
      // Add instructions sheet
      Sheet instructionsSheet = excel['Instructions'];
      final instructions = [
        ['Employee Import Template - Instructions'],
        [''],
        ['Required Fields (marked with *):'],
        ['- Full Name: Employee\'s complete name'],
        ['- Email: Valid email address (must be unique)'],
        [''],
        ['Optional Fields:'],
        ['- Employee ID: Unique identifier (auto-generated if empty)'],
        ['- Role: employee, admin, super_admin (default: employee)'],
        ['- Position: Job title/position'],
        ['- Department: Department name'],
        ['- Phone: Contact phone number'],
        ['- Status: active, inactive (default: active)'],
        ['- Is Active: Active, Inactive (default: Active)'],
        [''],
        ['Notes:'],
        ['- Remove sample data before importing your data'],
        ['- Ensure email addresses are unique'],
        ['- Role values: employee, admin, super_admin'],
        ['- Status values: active, inactive'],
        ['- Is Active values: Active, Inactive, true, false'],
      ];
      
      for (int i = 0; i < instructions.length; i++) {
        var cell = instructionsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
        cell.value = TextCellValue(instructions[i][0]);
        if (i == 0) {
          cell.cellStyle = CellStyle(bold: true, fontSize: 14);
        }
      }
      
      // Auto-fit columns
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15.0);
      }
      instructionsSheet.setColumnWidth(0, 50.0);
      
      // Save template
      final fileName = 'employee_import_template.xlsx';
      var fileBytes = excel.save();
      
      if (fileBytes != null) {
        try {
          final bytes = Uint8List.fromList(fileBytes);
          
          // Use FileSaver for all platforms
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: bytes,
            ext: 'xlsx',
          );
          
          print('✅ EXCEL TEMPLATE: Template saved successfully as $fileName');
          return ApiResponse<String>(
            success: true,
            message: 'Import template downloaded successfully! Check your downloads folder.',
            data: fileName,
          );
        } catch (saveError) {
          print('❌ EXCEL TEMPLATE: Save error: $saveError');
          return ApiResponse<String>(
            success: false,
            message: 'Failed to download template: $saveError',
            error: saveError.toString(),
          );
        }
      } else {
        throw Exception('Failed to generate template file bytes');
      }
      
    } catch (e) {
      print('❌ EXCEL TEMPLATE: Error: $e');
      return ApiResponse<String>(
        success: false,
        message: 'Failed to generate template: $e',
        error: e.toString(),
      );
    }
  }

  // Helper methods
  String _getCellValue(List<Data?> row, int index) {
    if (index < row.length && row[index] != null) {
      return row[index]?.value?.toString() ?? '';
    }
    return '';
  }

  bool _isRowEmpty(List<Data?> row) {
    for (final cell in row) {
      if (cell?.value != null && cell!.value.toString().trim().isNotEmpty) {
        return false;
      }
    }
    return true;
  }
}