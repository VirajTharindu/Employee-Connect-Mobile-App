// family_repository_impl.dart

import 'package:employee_connect/domain/entities/family_member.dart';
import 'package:employee_connect/domain/repositories/family_repository.dart';
import 'package:employee_connect/data/datasources/local/database_helper.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final DatabaseHelper _dbHelper;

  FamilyRepositoryImpl(this._dbHelper);

  @override
  Future<void> insertFamilyMember(FamilyMember member) async {
    await _dbHelper.insertFamilyMember(member);
  }

  @override
  Future<List<FamilyMember>> retrieveAllFamilyMembers() async {
    return await _dbHelper.retrieveAllFamilyMembers();
  }

  @override
  Future<List<FamilyMember>> retrieveFamilyMembersByHousehold(String householdNumber) async {
    return await _dbHelper.retrieveFamilyMembersByHousehold(householdNumber);
  }

  @override
  Future<void> deleteFamilyByHousehold(String householdNumber) async {
    await _dbHelper.deleteFamilyByHousehold(householdNumber);
  }

  @override
  Future<void> deleteFamilyMemberById(int id) async {
    await _dbHelper.deleteFamilyMemberById(id);
  }

  @override
  Future<void> updateFamilyData(String householdNumber, Map<String, dynamic> updatedData) async {
    await _dbHelper.updateFamilyData(householdNumber, updatedData);
  }

  @override
  Future<int> updateFamilyMember(FamilyMember member) async {
    return await _dbHelper.updateFamilyMember(member);
  }

  @override
  Future<int> updateDateOfModified(FamilyMember member) async {
    return await _dbHelper.updateDateOfModified(member);
  }

  @override
  Future<void> updateFamilyDateOfModified(String householdNumber) async {
    await _dbHelper.updateFamilyDateOfModified(householdNumber);
  }

  @override
  Future<Map<String, dynamic>> getFamilyMemberData(String householdNumber) async {
    return await _dbHelper.getFamilyMemberData(householdNumber);
  }

  @override
  Future<bool> isHouseholdNumberUnique(String householdNumber) async {
    return await _dbHelper.isHouseholdNumberUnique(householdNumber);
  }

  @override
  Future<bool> isNationalIdUnique(String? nationalId) async {
    return await _dbHelper.isNationalIdUnique(nationalId);
  }

  @override
  Future<List<Map<String, dynamic>>> querySamurdhiFamilies() async {
    return await _dbHelper.querySamurdhiFamilies();
  }

  @override
  Future<List<Map<String, dynamic>>> queryAswasumaFamilies() async {
    return await _dbHelper.queryAswasumaFamilies();
  }

  @override
  Future<List<Map<String, dynamic>>> queryWedihitiFamilies() async {
    return await _dbHelper.queryWedihitiFamilies();
  }

  @override
  Future<List<Map<String, dynamic>>> queryMahajanadaraFamilies() async {
    return await _dbHelper.queryMahajanadaraFamilies();
  }

  @override
  Future<List<Map<String, dynamic>>> queryAbhadithaFamilies() async {
    return await _dbHelper.queryAbhadithaFamilies();
  }

  @override
  Future<List<Map<String, dynamic>>> queryShishshyadaraFamilies() async {
    return await _dbHelper.queryShishshyadaraFamilies();
  }

  @override
  Future<List<Map<String, dynamic>>> queryPilikadaraFamilies() async {
    return await _dbHelper.queryPilikadaraFamilies();
  }

  @override
  Future<List<Map<String, dynamic>>> queryTuberculosisAidFamilies() async {
    return await _dbHelper.queryTuberculosisAidFamilies();
  }

  @override
  Future<List<Map<String, dynamic>>> queryAnyAidFamilies() async {
    return await _dbHelper.queryAnyAidFamilies();
  }

  @override
  Future<List<Map<String, dynamic>>> queryAllStudentFamilyMembers({
    required int minAge,
    required int maxAge,
    required String dateOfModifiedPattern,
  }) async {
    return await _dbHelper.queryAllStudentFamilyMembers(
      minAge: minAge,
      maxAge: maxAge,
      dateOfModifiedPattern: dateOfModifiedPattern,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> queryReligionFamilyMembers() async {
    return await _dbHelper.queryReligionFamilyMembers();
  }

  @override
  Future<List<Map<String, dynamic>>> queryNationalityFamilyMembers() async {
    return await _dbHelper.queryNationalityFamilyMembers();
  }

  @override
  Future<List<Map<String, dynamic>>> queryHigherEducationFamilyMembers() async {
    return await _dbHelper.queryHigherEducationFamilyMembers();
  }

  @override
  Future<List<FamilyMember>> queryGovernmentEmployees() async {
    return await _dbHelper.queryGovernmentEmployees();
  }

  @override
  Future<List<FamilyMember>> queryPrivateEmployees() async {
    return await _dbHelper.queryPrivateEmployees();
  }

  @override
  Future<List<FamilyMember>> querySemiGovernmentEmployees() async {
    return await _dbHelper.querySemiGovernmentEmployees();
  }

  @override
  Future<List<FamilyMember>> queryCorporationEmployees() async {
    return await _dbHelper.queryCorporationEmployees();
  }

  @override
  Future<List<FamilyMember>> queryForcesEmployees() async {
    return await _dbHelper.queryForcesEmployees();
  }

  @override
  Future<List<FamilyMember>> queryPoliceEmployees() async {
    return await _dbHelper.queryPoliceEmployees();
  }

  @override
  Future<List<FamilyMember>> querySelfEmployedEmployees() async {
    return await _dbHelper.querySelfEmployedEmployees();
  }

  @override
  Future<List<FamilyMember>> queryNoJobEmployees() async {
    return await _dbHelper.queryNoJobEmployees();
  }
}
