// family_member.dart

import 'package:intl/intl.dart';

class FamilyMember {
  int? id;
  String name;
  String? nationalId;
  DateTime birthday;
  int age;
  String nationality;
  String religion;
  String? educationQualification;

  String? jobType;

  bool isSamurdiAid;
  bool isAswasumaAid;
  bool isWedihitiAid;
  bool isMahajanadaraAid;
  bool isAbhadithaAid;
  bool isShishshyadaraAid;
  bool isPilikadaraAid;
  bool isTuberculosisAid;
  bool isAnyAid;

  // New properties
  String householdNumber; // Common for the whole family
  String familyHeadType; // 'family head male' or 'family head female'
  String relationshipToHead; // Relationship to family head
  String dateOfModified;

  String? grade; // Optional grade field for non-family head members

  FamilyMember({
    this.id,
    required this.name,
    this.nationalId,
    required this.birthday,
    required this.age,
    required this.nationality,
    required this.religion,
    this.educationQualification,
    this.jobType,
    this.isSamurdiAid = false,
    this.isAswasumaAid = false,
    this.isWedihitiAid = false,
    this.isMahajanadaraAid = false,
    this.isAbhadithaAid = false,
    this.isShishshyadaraAid = false,
    this.isPilikadaraAid = false,
    this.isAnyAid = false,
    this.isTuberculosisAid = false,
    required this.householdNumber,
    required this.familyHeadType,
    required this.relationshipToHead,
    required this.dateOfModified,
    this.grade, // Nullable grade
  });

  // Format the current date
  String formatCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }
}
