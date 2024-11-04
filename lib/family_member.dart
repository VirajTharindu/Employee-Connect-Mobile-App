// family_member.dart

class FamilyMember {
  String name;
  String nationalId;
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
  bool isAnyAid;

  // New properties
  String householdNumber; // Common for the whole family
  String familyHeadType; // 'family head male' or 'family head female'
  String relationshipToHead; // Relationship to family head

  String? grade; // Optional grade field for non-family head members

  FamilyMember({
    required this.name,
    required this.nationalId,
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
    required this.householdNumber,
    required this.familyHeadType,
    required this.relationshipToHead,
    this.grade, // Nullable grade
  });

  // Convert a FamilyMember object to a Map to insert into SQLite
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nationalId': nationalId,
      'birthday': birthday.toIso8601String(),
      'age': age,
      'nationality': nationality,
      'religion': religion,
      'educationQualification': educationQualification,
      'jobType': jobType,
      'isSamurdiAid': isSamurdiAid ? 1 : 0,
      'isAswasumaAid': isAswasumaAid ? 1 : 0,
      'isWedihitiAid': isWedihitiAid ? 1 : 0,
      'isMahajanadaraAid': isMahajanadaraAid ? 1 : 0,
      'isAbhadithaAid': isAbhadithaAid ? 1 : 0,
      'isShishshyadaraAid': isShishshyadaraAid ? 1 : 0,
      'isPilikadaraAid': isPilikadaraAid ? 1 : 0,
      'isAnyAid': isAnyAid ? 1 : 0,

      'householdNumber': householdNumber,
      'familyHeadType': familyHeadType,
      'relationshipToHead': relationshipToHead,

      'grade': grade, // Nullable grade
    };
  }

  // Create a FamilyMember object from a Map (from SQLite)
  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      name: map['name'],
      nationalId: map['nationalId'],
      birthday: DateTime.parse(map['birthday']),
      age: map['age'],
      nationality: map['nationality'],
      religion: map['religion'],
      educationQualification: map['educationQualification'],
      jobType: map['jobType'],
      isSamurdiAid: map['isSamurdiAid'] == 1,
      isAswasumaAid: map['isAswasumaAid'] == 1,
      isWedihitiAid: map['isWedihitiAid'] == 1,
      isMahajanadaraAid: map['isMahajanadaraAid'] == 1,
      isAbhadithaAid: map['isAbhadithaAid'] == 1,
      isShishshyadaraAid: map['isShishshyadaraAid'] == 1,
      isPilikadaraAid: map['isPilikadaraAid'] == 1,
      isAnyAid: map['isAnyAid'] == 1,

      householdNumber: map['householdNumber'],
      familyHeadType: map['familyHeadType'],
      relationshipToHead: map['relationshipToHead'],

      grade: map['grade'], // Initialize grade from Map
    );
  }
}
