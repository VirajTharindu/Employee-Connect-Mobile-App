// service_locator.dart

import 'package:employee_connect/data/datasources/local/database_helper.dart';
import 'package:employee_connect/data/repositories/family_repository_impl.dart';
import 'package:employee_connect/domain/repositories/family_repository.dart';
import 'package:employee_connect/data/services/family_report_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final FamilyRepository familyRepository;
  late final FamilyReportService familyReportService;

  void setup() {
    final dbHelper = DatabaseHelper.instance;
    familyRepository = FamilyRepositoryImpl(dbHelper);
    familyReportService = FamilyReportService(familyRepository);
  }
}

final locator = ServiceLocator();
