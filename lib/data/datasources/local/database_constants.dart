// database_constants.dart

class DatabaseConstants {
  static const String tableFamilyMembers = 'family_members';

  // Column names
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colNationalId = 'nationalId';
  static const String colBirthday = 'birthday';
  static const String colAge = 'age';
  static const String colNationality = 'nationality';
  static const String colReligion = 'religion';
  static const String colEducationQualification = 'educationQualification';
  static const String colJobType = 'jobType';
  static const String colIsSamurdhiAid = 'isSamurdiAid';
  static const String colIsAswasumaAid = 'isAswasumaAid';
  static const String colIsWedihitiAid = 'isWedihitiAid';
  static const String colIsMahajanadaraAid = 'isMahajanadaraAid';
  static const String colIsAbhadithaAid = 'isAbhadithaAid';
  static const String colIsShishshyadaraAid = 'isShishshyadaraAid';
  static const String colIsPilikadaraAid = 'isPilikadaraAid';
  static const String colIsTuberculosisAid = 'isTuberculosisAid';
  static const String colIsAnyAid = 'isAnyAid';
  static const String colHouseholdNumber = 'householdNumber';
  static const String colFamilyHeadType = 'familyHeadType';
  static const String colRelationshipToHead = 'relationshipToHead';
  static const String colGrade = 'grade';
  static const String colDateOfModified = 'dateOfModified';

  // SQL Queries
  static const String createTableFamilyMembers = '''
    CREATE TABLE $tableFamilyMembers(
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colName TEXT,
      $colNationalId TEXT UNIQUE,
      $colBirthday TEXT,
      $colAge INTEGER,
      $colNationality TEXT,
      $colReligion TEXT,
      $colEducationQualification TEXT,
      $colJobType TEXT,
      $colIsSamurdhiAid INTEGER,
      $colIsAswasumaAid INTEGER,
      $colIsWedihitiAid INTEGER,
      $colIsMahajanadaraAid INTEGER,
      $colIsAbhadithaAid INTEGER,
      $colIsShishshyadaraAid INTEGER,
      $colIsPilikadaraAid INTEGER,
      $colIsTuberculosisAid INTEGER,
      $colIsAnyAid INTEGER,
      $colHouseholdNumber TEXT,
      $colFamilyHeadType TEXT,
      $colRelationshipToHead TEXT,
      $colGrade TEXT,
      $colDateOfModified TEXT DEFAULT (datetime('now', 'localtime'))
    )
  ''';
}
