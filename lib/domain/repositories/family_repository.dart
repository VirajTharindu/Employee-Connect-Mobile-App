// family_repository.dart

import 'package:employee_connect/domain/entities/family_member.dart';

abstract class FamilyRepository {
  Future<void> insertFamilyMember(FamilyMember member);
  Future<List<FamilyMember>> retrieveAllFamilyMembers();
  Future<List<FamilyMember>> retrieveFamilyMembersByHousehold(String householdNumber);
  Future<void> deleteFamilyByHousehold(String householdNumber);
  Future<void> deleteFamilyMemberById(int id);
  Future<void> updateFamilyData(String householdNumber, Map<String, dynamic> updatedData);
  Future<int> updateFamilyMember(FamilyMember member);
  Future<int> updateDateOfModified(FamilyMember member);
  Future<void> updateFamilyDateOfModified(String householdNumber);
  Future<Map<String, dynamic>> getFamilyMemberData(String householdNumber);
  Future<bool> isHouseholdNumberUnique(String householdNumber);
  Future<bool> isNationalIdUnique(String? nationalId);
  
  // Aid Specific Queries (returning raw maps for now to keep logic unchanged in UI)
  Future<List<Map<String, dynamic>>> querySamurdhiFamilies();
  Future<List<Map<String, dynamic>>> queryAswasumaFamilies();
  Future<List<Map<String, dynamic>>> queryWedihitiFamilies();
  Future<List<Map<String, dynamic>>> queryMahajanadaraFamilies();
  Future<List<Map<String, dynamic>>> queryAbhadithaFamilies();
  Future<List<Map<String, dynamic>>> queryShishshyadaraFamilies();
  Future<List<Map<String, dynamic>>> queryPilikadaraFamilies();
  Future<List<Map<String, dynamic>>> queryTuberculosisAidFamilies();
  Future<List<Map<String, dynamic>>> queryAnyAidFamilies();
  
  // Statistics Queries
  Future<List<Map<String, dynamic>>> queryAllStudentFamilyMembers({
    required int minAge,
    required int maxAge,
    required String dateOfModifiedPattern,
  });
  Future<List<Map<String, dynamic>>> queryReligionFamilyMembers();
  Future<List<Map<String, dynamic>>> queryNationalityFamilyMembers();
  Future<List<Map<String, dynamic>>> queryHigherEducationFamilyMembers();
  
  // Job Specific Queries
  Future<List<FamilyMember>> queryGovernmentEmployees();
  Future<List<FamilyMember>> queryPrivateEmployees();
  Future<List<FamilyMember>> querySemiGovernmentEmployees();
  Future<List<FamilyMember>> queryCorporationEmployees();
  Future<List<FamilyMember>> queryForcesEmployees();
  Future<List<FamilyMember>> queryPoliceEmployees();
  Future<List<FamilyMember>> querySelfEmployedEmployees();
  Future<List<FamilyMember>> queryNoJobEmployees();
}
