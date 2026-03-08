// family_member_model.dart

import 'package:employee_connect/domain/entities/family_member.dart';
import 'package:employee_connect/data/datasources/local/database_constants.dart';

class FamilyMemberModel extends FamilyMember {
  FamilyMemberModel({
    super.id,
    required super.name,
    super.nationalId,
    required super.birthday,
    required super.age,
    required super.nationality,
    required super.religion,
    super.educationQualification,
    super.jobType,
    super.isSamurdiAid = false,
    super.isAswasumaAid = false,
    super.isWedihitiAid = false,
    super.isMahajanadaraAid = false,
    super.isAbhadithaAid = false,
    super.isShishshyadaraAid = false,
    super.isPilikadaraAid = false,
    super.isAnyAid = false,
    super.isTuberculosisAid = false,
    required super.householdNumber,
    required super.familyHeadType,
    required super.relationshipToHead,
    required super.dateOfModified,
    super.grade,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colName: name,
      DatabaseConstants.colNationalId: nationalId,
      DatabaseConstants.colBirthday: birthday.toIso8601String(),
      DatabaseConstants.colAge: age,
      DatabaseConstants.colNationality: nationality,
      DatabaseConstants.colReligion: religion,
      DatabaseConstants.colEducationQualification: educationQualification,
      DatabaseConstants.colJobType: jobType,
      DatabaseConstants.colIsSamurdhiAid: isSamurdiAid ? 1 : 0,
      DatabaseConstants.colIsAswasumaAid: isAswasumaAid ? 1 : 0,
      DatabaseConstants.colIsWedihitiAid: isWedihitiAid ? 1 : 0,
      DatabaseConstants.colIsMahajanadaraAid: isMahajanadaraAid ? 1 : 0,
      DatabaseConstants.colIsAbhadithaAid: isAbhadithaAid ? 1 : 0,
      DatabaseConstants.colIsShishshyadaraAid: isShishshyadaraAid ? 1 : 0,
      DatabaseConstants.colIsPilikadaraAid: isPilikadaraAid ? 1 : 0,
      DatabaseConstants.colIsTuberculosisAid: isTuberculosisAid ? 1 : 0,
      DatabaseConstants.colIsAnyAid: isAnyAid ? 1 : 0,
      DatabaseConstants.colHouseholdNumber: householdNumber,
      DatabaseConstants.colFamilyHeadType: familyHeadType,
      DatabaseConstants.colRelationshipToHead: relationshipToHead,
      DatabaseConstants.colDateOfModified: formatCurrentDate(),
      DatabaseConstants.colGrade: grade,
    };
  }

  factory FamilyMemberModel.fromMap(Map<String, dynamic> map) {
    return FamilyMemberModel(
      id: map[DatabaseConstants.colId],
      name: map[DatabaseConstants.colName] ?? '',
      nationalId: map[DatabaseConstants.colNationalId],
      birthday: DateTime.parse(map[DatabaseConstants.colBirthday]),
      age: map[DatabaseConstants.colAge] ?? 0,
      nationality: map[DatabaseConstants.colNationality],
      religion: map[DatabaseConstants.colReligion],
      educationQualification: map[DatabaseConstants.colEducationQualification],
      jobType: map[DatabaseConstants.colJobType],
      isSamurdiAid: map[DatabaseConstants.colIsSamurdhiAid] == 1,
      isAswasumaAid: map[DatabaseConstants.colIsAswasumaAid] == 1,
      isWedihitiAid: map[DatabaseConstants.colIsWedihitiAid] == 1,
      isMahajanadaraAid: map[DatabaseConstants.colIsMahajanadaraAid] == 1,
      isAbhadithaAid: map[DatabaseConstants.colIsAbhadithaAid] == 1,
      isShishshyadaraAid: map[DatabaseConstants.colIsShishshyadaraAid] == 1,
      isPilikadaraAid: map[DatabaseConstants.colIsPilikadaraAid] == 1,
      isAnyAid: map[DatabaseConstants.colIsAnyAid] == 1,
      isTuberculosisAid: map[DatabaseConstants.colIsTuberculosisAid] == 1,
      householdNumber: map[DatabaseConstants.colHouseholdNumber] ?? '',
      familyHeadType: map[DatabaseConstants.colFamilyHeadType] ?? '',
      relationshipToHead: map[DatabaseConstants.colRelationshipToHead],
      dateOfModified: map[DatabaseConstants.colDateOfModified] ?? DateTime.now().toIso8601String(),
      grade: map[DatabaseConstants.colGrade],
    );
  }


  // Helper method to convert Entity to Model
  factory FamilyMemberModel.fromEntity(FamilyMember entity) {
    return FamilyMemberModel(
      id: entity.id,
      name: entity.name,
      nationalId: entity.nationalId,
      birthday: entity.birthday,
      age: entity.age,
      nationality: entity.nationality,
      religion: entity.religion,
      educationQualification: entity.educationQualification,
      jobType: entity.jobType,
      isSamurdiAid: entity.isSamurdiAid,
      isAswasumaAid: entity.isAswasumaAid,
      isWedihitiAid: entity.isWedihitiAid,
      isMahajanadaraAid: entity.isMahajanadaraAid,
      isAbhadithaAid: entity.isAbhadithaAid,
      isShishshyadaraAid: entity.isShishshyadaraAid,
      isPilikadaraAid: entity.isPilikadaraAid,
      isAnyAid: entity.isAnyAid,
      isTuberculosisAid: entity.isTuberculosisAid,
      householdNumber: entity.householdNumber,
      familyHeadType: entity.familyHeadType,
      relationshipToHead: entity.relationshipToHead,
      dateOfModified: entity.dateOfModified,
      grade: entity.grade,
    );
  }
}
